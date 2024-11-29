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
def load_and_replace_json(file_path, update_existing, process_images, db):
    with open(file_path, "r") as f:
        data = json.load(f)

    # Process images only if the user opted in
    if process_images:
        print("Processing images...")
        for profile in data["UserProfile"]:
            doc_id = profile["id"]
            if not document_exists("UserProfile", doc_id, db) or update_existing:
                image_content = download_image(profile["avatarURL"])
                if image_content:
                    fileName = f"{uuid.uuid4()}"
                    profile["avatarURL"] = upload_image_to_storage(image_content, ImageFolder.AVATAR, fileName)
                else:
                    print(f"Skipping profile {doc_id} due to image download error.")
            else:
                print(f"Skipping image processing for existing UserProfile: {doc_id}")

        for deal in data["Deals"]:
            doc_id = deal["id"]
            if not document_exists("Deals", doc_id, db) or update_existing:
                image_content = download_image(deal["photoURL"])
                if image_content:
                    fileName = f"{uuid.uuid4()}"
                    deal["photoURL"] = upload_image_to_storage(image_content, ImageFolder.DEAL_IMAGE, fileName)
                else:
                    print(f"Skipping deal {doc_id} due to image download error.")
            else:
                print(f"Skipping image processing for existing Deal: {doc_id}")
    else:
        print("Skipping image processing as per user choice.")

    # Replace timestamps in Deals only
    data["Deals"] = replace_timestamps(data["Deals"])

    # Extract deal timestamps for comment timestamp generation
    deal_timestamps = {deal["id"]: deal["dateTime"] for deal in data["Deals"]}

    # Replace timestamps in UserComments based on deal timestamps
    data = replace_comment_timestamps(data, deal_timestamps)

    return data


# Recursively replace `__SERVER_TIMESTAMP__` with generated dates
def replace_timestamps(deals):
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
                # Convert the date to a datetime object
                timestamp = datetime.fromisoformat(date_value)
                return timestamp
            else:
                return datetime.now()
        return value

    return replace(deals)


# Replace comment timestamps based on deal timestamps
def replace_comment_timestamps(data, deal_timestamps):
    def replace(value, deal_timestamp=None):
        if isinstance(value, dict):
            return {key: replace(val, deal_timestamp) for key, val in value.items()}
        elif isinstance(value, list):
            return [replace(item, deal_timestamp) for item in value]
        elif value == "__SERVER_TIMESTAMP__":
            if deal_timestamp:
                # Since deal_timestamp is already a datetime object, use it directly
                deal_datetime = deal_timestamp
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
        else:
            # Handle the case where the deal_id is not found
            comment["dateTime"] = datetime.now()

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

            # Print the dateTime for debugging
            print(f"Comment {doc_id} dateTime: {comment['dateTime']}")

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

def generate_votes_from_counts(deals, comments, all_user_ids):
    print("Generating Votes based on upvote/downvote counts...")
    votes = []
    used_votes = set()  # To prevent duplicate votes from the same user on the same item

    # Helper function to generate votes for an item
    def generate_votes_for_item(item_id, item_type, upvote_count, downvote_count, exclude_user_id):
        item_votes = []
        total_votes = upvote_count + downvote_count
        available_user_ids = [uid for uid in all_user_ids if uid != exclude_user_id]

        if total_votes > len(available_user_ids):
            print(f"Warning: Not enough unique users to generate votes for {item_type} {item_id}.")
            total_votes = len(available_user_ids)
            upvote_count = min(upvote_count, total_votes)
            downvote_count = total_votes - upvote_count

        random.shuffle(available_user_ids)
        vote_user_ids = available_user_ids[:total_votes]

        # Assign upvotes
        for uid in vote_user_ids[:upvote_count]:
            vote_key = (uid, item_id)
            if vote_key not in used_votes:
                used_votes.add(vote_key)
                votes.append({
                    "userId": uid,
                    "itemId": item_id,
                    "itemType": item_type,
                    "voteType": "upvote",
                    "isDummy": True
                })

        # Assign downvotes
        for uid in vote_user_ids[upvote_count:]:
            vote_key = (uid, item_id)
            if vote_key not in used_votes:
                used_votes.add(vote_key)
                votes.append({
                    "userId": uid,
                    "itemId": item_id,
                    "itemType": item_type,
                    "voteType": "downvote",
                    "isDummy": True
                })

    # Generate votes for Deals
    for deal in deals:
        item_id = deal["id"]
        upvote_count = deal.get("upvote", 0)
        downvote_count = deal.get("downvote", 0)
        exclude_user_id = deal.get("userID", "")
        generate_votes_for_item(item_id, "deal", upvote_count, downvote_count, exclude_user_id)

    # Generate votes for UserComments
    for comment in comments:
        item_id = comment["id"]
        upvote_count = comment.get("upvote", 0)
        downvote_count = comment.get("downvote", 0)
        exclude_user_id = comment.get("userID", "")
        generate_votes_for_item(item_id, "comment", upvote_count, downvote_count, exclude_user_id)

    print(f"Generated {len(votes)} votes.")
    return votes

# Function to populate generated votes into Firestore
def populate_generated_votes(votes, db):
    print("Populating Votes collection...")
    item_type_mapping = {
        "comment": 0,
        "deal": 1,
        "review": 2
    }

    for vote in votes:
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

        vote_data = {
            "userId": user_id,
            "itemId": item_id,
            "itemType": item_type_int,
            "voteType": vote_type,
            "isDummy": True
        }

        try:
            db.collection("Votes").document(doc_id).set(vote_data)
            print(f"Added Vote: {doc_id}")
        except Exception as e:
            print(f"Error adding Vote: {doc_id}: {e}")

# Main function to initialize data
def initialize_data(json_file_path):
    # Ask the user if they want to update existing entries
    update_existing = input("Do you want to update existing entries from the JSON file? (yes/no): ").strip().lower()
    update_existing = update_existing == "yes"

    # Ask the user if they want to process images
    process_images = input("Do you want to process images (download and upload to Firebase)? (yes/no): ").strip().lower()
    process_images = process_images == "yes"

    # Load JSON data
    collections = load_and_replace_json(json_file_path, update_existing, process_images, db)

    # Create dummy users in Firebase Authentication
    create_dummy_users(collections["UserProfile"])

    # Create a mapping of usernames to IDs
    user_profile_map_username, user_profile_map_id = populate_user_profiles(collections["UserProfile"], db)

    # Collect all user IDs
    all_user_ids = list(user_profile_map_id.keys())

    # Populate Stores collection
    populate_stores(collections["Stores"], db)

    # Populate Deals collection
    populate_deals(collections["Deals"], db, user_profile_map_username)

    # Populate UserComments collection
    populate_user_comments(collections["UserComments"], db, user_profile_map_username)

    # Generate Votes based on upvote/downvote counts
    generated_votes = generate_votes_from_counts(
        collections["Deals"],
        collections["UserComments"],
        all_user_ids
    )

    # Populate Votes collection
    populate_generated_votes(generated_votes, db)

    print("Data initialization completed.")

# Run the initialization
initialize_data(JSON_FILE_PATH)
