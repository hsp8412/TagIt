import firebase_admin
from firebase_admin import credentials, firestore, auth, storage
import json
from datetime import datetime, timedelta
import os
import random
import requests
from io import BytesIO
import uuid
import time
from google.cloud.firestore_v1 import SERVER_TIMESTAMP

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
SERVICE_ACCOUNT_PATH = os.path.join(SCRIPT_DIR, "tagit-39035-firebase-adminsdk-hugo8-9c33455468.json")
JSON_FILE_PATH = os.path.join(SCRIPT_DIR, "dummy_data.json")
BUCKET_NAME = 'tagit-39035.appspot.com'

# Initialize Firebase Admin SDK
cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
firebase_admin.initialize_app(cred, {'storageBucket': BUCKET_NAME})

# Firestore database reference
db = firestore.client()

# Enum-like structure for image folders
class ImageFolder:
    AVATAR = "avatar"
    DEAL_IMAGE = "dealImage"
    PRODUCT_IMAGE = "productImage"
    REVIEW_IMAGE = "reviewImage"

# Function to download an image
def download_image(url):
    print(f"Downloading image from URL: {url}")
    response = requests.get(url)
    if response.status_code != 200:
        print(f"Error downloading image from URL: {url}")
        return None
    return response.content

def upload_image_to_storage(image_content, folder, fileName, timeout=30):
    print(f"Uploading image to folder: {folder}, file name: {fileName}")
    bucket = storage.bucket()
    original_blob = bucket.blob(f"{folder}/{fileName}.jpg")
    original_blob.upload_from_string(image_content, content_type='image/jpeg')

    # Poll for resized image
    resized_blob = bucket.blob(f"{folder}/{fileName}_1080x1080.jpeg")
    elapsed_time = 0
    interval = 2  # Check every 2 seconds
    while elapsed_time < timeout:
        if resized_blob.exists():
            # Use Firebase public URL for resized image
            resized_url = f"https://firebasestorage.googleapis.com/v0/b/{BUCKET_NAME}/o/{folder}%2F{fileName}_1080x1080.jpeg?alt=media"
            print(f"Resized image found. Public URL: {resized_url}")
            return resized_url
        time.sleep(interval)
        elapsed_time += interval

    # Fallback to original image signed URL
    original_url = original_blob.generate_signed_url(timedelta(seconds=300))
    print(f"Resized image not found after {timeout} seconds. Using original image URL: {original_url}")
    return original_url

# Function to generate a date range from the current date to 6 days ago
def generate_date_range():
    # Get the current date
    current_date = datetime.now().date()

    # Calculate the date 6 days ago
    six_days_ago = current_date - timedelta(days=6)

    # Generate the list of dates
    date_range = []
    current = current_date
    while current >= six_days_ago:
        date_range.append(current.isoformat())
        current -= timedelta(days=1)

    return date_range

# Load JSON file and replace placeholders
def load_and_replace_json(file_path, update_existing, process_images):
    with open(file_path, "r") as f:
        data = json.load(f)

    # Process images only if the user opted in
    if process_images:
        print("Processing images...")
        for profile in data["UserProfile"]:
            image_content = download_image(profile["avatarURL"])
            if image_content:
                fileName = f"{uuid.uuid4()}"
                profile["avatarURL"] = upload_image_to_storage(image_content, ImageFolder.AVATAR, fileName)
            else:
                print(f"Skipping profile {profile['id']} due to image download error.")

        for deal in data["Deals"]:
            image_content = download_image(deal["photoURL"])
            if image_content:
                fileName = f"{uuid.uuid4()}"
                deal["photoURL"] = upload_image_to_storage(image_content, ImageFolder.DEAL_IMAGE, fileName)
            else:
                print(f"Skipping deal {deal['id']} due to image download error.")
    else:
        print("Skipping image processing as per user choice.")

    # Replace timestamps in Deals
    data = replace_timestamps(data)

    # Extract deal timestamps for comment timestamp generation
    deal_timestamps = {deal["id"]: deal["dateTime"] for deal in data["Deals"]}

    # Replace timestamps in UserComments based on deal timestamps
    data = replace_comment_timestamps(data, deal_timestamps)

    return data


# Recursively replace `__SERVER_TIMESTAMP__` with generated dates
def replace_timestamps(data):
    date_range = generate_date_range()
    date_index = 0

    def replace(value):
        nonlocal date_index
        if isinstance(value, dict):
            return {key: replace(val) for key, val in value.items()}
        elif isinstance(value, list):
            return [replace(item) for item in value]
        elif value == "__SERVER_TIMESTAMP__":
            if date_index < len(date_range):
                date_value = date_range[date_index]
                date_index += 1
                # Convert the date to a Firestore timestamp format
                timestamp = datetime.fromisoformat(date_value)
                return timestamp
            else:
                return datetime.now()
        return value

    return replace(data)

# Replace comment timestamps based on deal timestamps
def replace_comment_timestamps(data, deal_timestamps):
    def replace(value, deal_timestamp=None):
        if isinstance(value, dict):
            return {key: replace(val, deal_timestamp) for key, val in value.items()}
        elif isinstance(value, list):
            return [replace(item, deal_timestamp) for item in value]
        elif value == "__SERVER_TIMESTAMP__":
            if deal_timestamp:
                # Generate a random timestamp within 12 hours after the deal's timestamp
                deal_datetime = datetime.fromisoformat(deal_timestamp)
                random_hours = random.randint(1, 12)  # Randomly add between 1 and 12 hours
                comment_datetime = deal_datetime + timedelta(hours=random_hours)
                return comment_datetime
            else:
                # Fallback if no deal timestamp exists
                return datetime.now()
        return value

    # Replace timestamps in UserComments based on deal timestamps
    for comment in data["UserComments"]:
        deal_id = comment["itemID"]
        deal_timestamp = deal_timestamps.get(deal_id)
        if deal_timestamp:
            comment["dateTime"] = replace(comment["dateTime"], deal_timestamp)

    return data

# Check if document already exists before adding
def document_exists(collection, doc_id, db):
    doc_ref = db.collection(collection).document(doc_id)
    doc = doc_ref.get()
    return doc.exists

# Update a Firestore collection with data
def update_collection(collection_name, data_list, db):
    print(f"Updating {collection_name} collection...")
    for item in data_list:
        doc_id = item["id"]
        if document_exists(collection_name, doc_id, db):
            try:
                # Ensure dateTime field is set as a Firestore timestamp
                if "dateTime" in item:
                    item["dateTime"] = firestore.SERVER_TIMESTAMP
                db.collection(collection_name).document(doc_id).update(item)
                print(f"Updated {collection_name}: {doc_id}")
            except Exception as e:
                print(f"Error updating {collection_name}: {doc_id}: {e}")
        else:
            print(f"Skipped {collection_name}: {doc_id} (does not exist)")

# Populate UserProfile and create a mapping of usernames to IDs
def populate_user_profiles(user_profiles, db):
    user_profile_map_username = {}
    user_profile_map_id = {}
    print("Populating UserProfile collection...")
    for profile in user_profiles:
        doc_id = profile["id"]
        if not document_exists("UserProfile", doc_id, db):
            try:
                db.collection("UserProfile").document(doc_id).set(profile)
                user_profile_map_username[profile["username"]] = doc_id
                user_profile_map_id[doc_id] = doc_id
                print(f"Added UserProfile: {doc_id}")
            except Exception as e:
                print(f"Error adding UserProfile: {e}")
        else:
            print(f"Skipped UserProfile: {doc_id} (already exists)")
    return user_profile_map_username, user_profile_map_id

# Populate Stores collection
def populate_stores(stores, db):
    print("Populating Stores collection...")
    for store in stores:
        doc_id = store["id"]
        if not document_exists("Stores", doc_id, db):
            try:
                db.collection("Stores").document(doc_id).set(store)
                print(f"Added Store: {doc_id} - {store['name']}")
            except Exception as e:
                print(f"Error adding Store {doc_id}: {e}")
        else:
            print(f"Skipped Store: {doc_id} (already exists)")

# Populate Deals collection
def populate_deals(deals, db, user_profile_map):
    print("Populating Deals collection...")
    for deal in deals:
        doc_id = deal["id"]
        if not document_exists("Deals", doc_id, db):
            username = deal["userID"]
            resolved_id = user_profile_map.get(username)
            if resolved_id:
                deal["userID"] = resolved_id
                deal["username"] = username
            else:
                print(f"Warning: No UserProfile found for userID {username}")
                deal["userID"] = "unknown"
                deal["username"] = "Unknown User"

            # Validate locationId
            store_ref = db.collection("Stores").document(deal["locationId"]).get()
            if not store_ref.exists:
                print(f"Error: Store {deal['locationId']} for deal {doc_id} does not exist.")
                continue

            # Ensure date field is valid
            deal["date"] = deal.get("date", datetime.now().isoformat())

            try:
                db.collection("Deals").document(doc_id).set(deal)
                print(f"Added Deal: {doc_id} with userID {deal['userID']}")
            except Exception as e:
                print(f"Error adding Deal {doc_id}: {e}")
        else:
            print(f"Skipped Deal: {doc_id} (already exists)")

# Populate UserComments collection
def populate_user_comments(comments, db, user_profile_map):
    print("Populating UserComments collection...")
    for comment in comments:
        doc_id = comment["id"]
        if not document_exists("UserComments", doc_id, db):
            username = comment["userID"]
            resolved_id = user_profile_map.get(username)
            if resolved_id:
                comment["userID"] = resolved_id
            else:
                print(f"Warning: No UserProfile found for userID {username}")
                comment["userID"] = "unknown"

            # Include 'isDummy' if present
            if "isDummy" not in comment:
                comment["isDummy"] = True  # Assuming comments are dummy data

            try:
                db.collection("UserComments").document(doc_id).set(comment)
                print(f"Added UserComment: {doc_id} with userID {comment['userID']}")
            except Exception as e:
                print(f"Error adding UserComment {doc_id}: {e}")
        else:
            print(f"Skipped UserComment: {doc_id} (already exists)")
            
# Populate Votes collection
def populate_votes(votes, db, user_profile_map_id):
    print("Populating Votes collection...")

    # Mapping from 'itemType' strings to integers
    item_type_mapping = {
        "comment": 0,
        "deal": 1,
        "review": 2
    }

    for vote in votes:
        # Extract necessary fields
        user_id = vote["userId"]
        item_id = vote["itemId"]
        item_type_str = vote["itemType"]
        vote_type = vote["voteType"]

        # Convert 'itemType' to integer
        item_type_int = item_type_mapping.get(item_type_str)
        if item_type_int is None:
            print(f"Invalid itemType '{item_type_str}' in vote: {vote}")
            continue

        # Construct document ID
        doc_id = f"{user_id}_{item_id}_{item_type_int}"

        # Prepare vote data without 'id'
        vote_data = {
            "userId": user_id,
            "itemId": item_id,
            "voteType": vote_type,
            "itemType": item_type_int
        }

        # Include 'isDummy' if present
        if "isDummy" in vote:
            vote_data["isDummy"] = vote["isDummy"]

        # Verify userId
        if user_id not in user_profile_map_id:
            print(f"Warning: No UserProfile found for userId {user_id}")
            vote_data["userId"] = "unknown"

        try:
            db.collection("Votes").document(doc_id).set(vote_data)
            print(f"Added Vote: {doc_id} with userId {vote_data['userId']}")
        except Exception as e:
            print(f"Error adding Vote: {doc_id}: {e}")


# Update upvote/downvote counts in UserComments and Deals based on Votes
def update_vote_counts(data):
    # Initialize dictionaries to store upvote and downvote counts
    comment_votes = {}
    deal_votes = {}

    # Populate the dictionaries with vote counts
    for vote in data["Votes"]:
        item_id = vote["itemId"]
        item_type = vote["itemType"]  # This is now an integer
        vote_type = vote["voteType"]

        if item_type == 0:  # Comment
            vote_dict = comment_votes
        elif item_type == 1:  # Deal
            vote_dict = deal_votes
        else:
            continue  # Skip if itemType is not recognized

        if item_id not in vote_dict:
            vote_dict[item_id] = {"upvote": 0, "downvote": 0}
        vote_dict[item_id][vote_type] += 1

    # Update UserComments with vote counts
    for comment in data["UserComments"]:
        comment_id = comment["id"]
        if comment_id in comment_votes:
            comment["upvote"] = comment_votes[comment_id]["upvote"]
            comment["downvote"] = comment_votes[comment_id]["downvote"]

    # Update Deals with vote counts
    for deal in data["Deals"]:
        deal_id = deal["id"]
        if deal_id in deal_votes:
            deal["upvote"] = deal_votes[deal_id]["upvote"]
            deal["downvote"] = deal_votes[deal_id]["downvote"]

    return data


# Create dummy users in Firebase Authentication
def create_dummy_users(user_profiles):
    for profile in user_profiles:
        try:
            user = auth.create_user(
                uid=profile["id"],
                email=profile["email"],
                email_verified=False,
                password='dummy_password',
                display_name=f"{profile['displayName']}_dummy",  # Append '_dummy' to the display name
                disabled=False
            )
            print(f"Created user: {user.uid}")
        except Exception as e:
            print(f"Error creating user {profile['id']}: {e}")

# Main function to initialize data
def initialize_data(json_file_path):
    # Ask the user if they want to update existing entries
    update_existing = input("Do you want to update existing entries from the JSON file? (yes/no): ").strip().lower()
    if update_existing == "yes":
        update_existing = True
    else:
        update_existing = False

    # Ask the user if they want to process images
    process_images = input("Do you want to process images (download and upload to Firebase)? (yes/no): ").strip().lower()
    if process_images == "yes":
        process_images = True
    else:
        process_images = False

    # Load JSON data
    collections = load_and_replace_json(json_file_path, update_existing, process_images)

    # Create dummy users in Firebase Authentication
    create_dummy_users(collections["UserProfile"])

    # Create a mapping of usernames to IDs
    user_profile_map_username, user_profile_map_id = populate_user_profiles(collections["UserProfile"], db)

    # Update vote counts in UserComments and Deals
    collections = update_vote_counts(collections)

    if update_existing:
        # Update existing collections
        update_collection("UserProfile", collections["UserProfile"], db)
        update_collection("Stores", collections["Stores"], db)
        update_collection("Deals", collections["Deals"], db)
        update_collection("UserComments", collections["UserComments"], db)
        update_collection("Votes", collections["Votes"], db)

    # Populate collections
    populate_stores(collections["Stores"], db)
    populate_deals(collections["Deals"], db, user_profile_map_username)
    populate_user_comments(collections["UserComments"], db, user_profile_map_username)
    # Update the call to populate_votes
    populate_votes(collections["Votes"], db, user_profile_map_id)
    print("Data initialization completed.")

# Run the initialization
initialize_data(JSON_FILE_PATH)
