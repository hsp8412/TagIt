"""
Firebase Data Initialization Script

This script initializes Firebase Firestore and Authentication with dummy data for testing or development purposes.
Specifically, it:
1. Downloads and uploads images to Firebase Storage.
2. Populates Firestore collections with data from a JSON file.
3. Creates dummy users in Firebase Authentication.
4. Generates and populates user votes based on data.

WARNING: This script will modify Firebase Firestore, Storage, and Authentication. Use with caution.

Dependencies:
- Firebase Admin SDK service account JSON file.
- Permissions to access Firestore, Storage, and Authentication.
- A `dummy_data.json` file with the following structure:

{
  "UserProfile": [
    {
      "id": "user1",
      "username": "avocado_lover123",
      "email": "user1@example.com",
      "displayName": "Avocado Lover",
      "avatarURL": "https://example.com/image.jpg",
      "score": 0,
      "savedDeals": [],
      "totalUpvotes": 0,
      "totalDownvotes": 0,
      "totalDeals": 0,
      "totalComments": 0,
      "rankingPoints": 0,
      "isDummy": true
    },
    ...
  ],
  "Stores": [
    {
      "id": "loc123",
      "latitude": 51.0776,
      "longitude": -114.1471,
      "name": "Store Name",
      "isDummy": true
    },
    ...
  ],
  "Deals": [
    {
      "id": "deal1",
      "userID": "user1",
      "photoURL": "https://example.com/deal.jpg",
      "productText": "Deal description",
      "postText": "Post description",
      "price": 1.49,
      "location": "Store Name",
      "locationId": "loc123",
      "date": "2024-11-03",
      "commentIDs": ["comment1", "comment2"],
      "upvote": 30,
      "downvote": 2,
      "dateTime": "__SERVER_TIMESTAMP__",
      "isDummy": true
    },
    ...
  ],
  "UserComments": [
    {
      "id": "comment1",
      "commentText": "Comment text",
      "downvote": 0,
      "commentType": "deal",
      "upvote": 10,
      "date": "2024-11-03",
      "dateTime": "__SERVER_TIMESTAMP__",
      "itemID": "deal1",
      "userID": "user1",
      "isDummy": true
    },
    ...
  ]
}

Author: Peter Tran
"""


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

def download_image(url: str) -> bytes:
    """
    Download an image from a given URL.

    Args:
        url (str): The URL of the image to download.

    Returns:
        bytes: The content of the image if downloaded successfully, otherwise None.
    """
    print(f"Downloading image from URL: {url}")
    response = requests.get(url)
    if response.status_code != 200:
        print(f"Error downloading image from URL: {url}")
        return None
    return response.content

def upload_image_to_storage(image_content: bytes, folder: str, fileName: str, timeout: int = 30) -> str:
    """
    Upload an image to Firebase Storage and return the public URL of the resized image.

    Args:
        image_content (bytes): The content of the image to upload.
        folder (str): The folder in Firebase Storage to upload the image to.
        fileName (str): The name of the file to upload.
        timeout (int): The timeout for polling the resized image.

    Returns:
        str: The public URL of the resized image.
    """
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

def generate_date_range() -> list[str]:
    """
    Generate a date range from the current date to 6 days ago.

    Returns:
        list[str]: A list of date strings in ISO format.
    """
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

def load_and_replace_json(file_path: str, update_existing: bool, process_images: bool, db: firestore.Client) -> dict:
    """
    Load JSON file and replace placeholders with actual data.

    Args:
        file_path (str): The path to the JSON file.
        update_existing (bool): Whether to update existing entries.
        process_images (bool): Whether to process images.
        db (firestore.Client): The Firestore client.

    Returns:
        dict: The loaded and processed JSON data.
    """
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

def replace_timestamps(deals: list[dict]) -> list[dict]:
    """
    Recursively replace `__SERVER_TIMESTAMP__` with generated dates.

    Args:
        deals (list[dict]): The list of deals to process.

    Returns:
        list[dict]: The list of deals with replaced timestamps.
    """
    date_range = generate_date_range()
    date_index = 0

    def replace(value: any) -> any:
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

def replace_comment_timestamps(data: dict, deal_timestamps: dict[str, datetime]) -> dict:
    """
    Replace comment timestamps based on deal timestamps.

    Args:
        data (dict): The data to process.
        deal_timestamps (dict[str, datetime]): The mapping of deal IDs to timestamps.

    Returns:
        dict: The data with replaced comment timestamps.
    """
    def replace(value: any, deal_timestamp: datetime = None) -> any:
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

def document_exists(collection: str, doc_id: str, db: firestore.Client) -> bool:
    """
    Check if a document already exists in a Firestore collection.

    Args:
        collection (str): The name of the collection.
        doc_id (str): The ID of the document.
        db (firestore.Client): The Firestore client.

    Returns:
        bool: True if the document exists, False otherwise.
    """
    doc_ref = db.collection(collection).document(doc_id)
    doc = doc_ref.get()
    return doc.exists

def update_collection(collection_name: str, data_list: list[dict], db: firestore.Client) -> None:
    """
    Update a Firestore collection with data.

    Args:
        collection_name (str): The name of the collection.
        data_list (list[dict]): The list of data to update.
        db (firestore.Client): The Firestore client.
    """
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

def populate_user_profiles(user_profiles: list[dict], db: firestore.Client) -> tuple[dict[str, str], dict[str, str]]:
    """
    Populate UserProfile collection and create a mapping of usernames to IDs.

    Args:
        user_profiles (list[dict]): The list of user profiles to populate.
        db (firestore.Client): The Firestore client.

    Returns:
        tuple[dict[str, str], dict[str, str]]: Mappings of usernames to IDs and IDs to IDs.
    """
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

def populate_stores(stores: list[dict], db: firestore.Client) -> None:
    """
    Populate Stores collection.

    Args:
        stores (list[dict]): The list of stores to populate.
        db (firestore.Client): The Firestore client.
    """
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

def populate_deals(deals: list[dict], db: firestore.Client, user_profile_map: dict[str, str]) -> None:
    """
    Populate Deals collection.

    Args:
        deals (list[dict]): The list of deals to populate.
        db (firestore.Client): The Firestore client.
        user_profile_map (dict[str, str]): The mapping of usernames to IDs.
    """
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

def populate_user_comments(comments: list[dict], db: firestore.Client, user_profile_map: dict[str, str]) -> None:
    """
    Populate UserComments collection.

    Args:
        comments (list[dict]): The list of comments to populate.
        db (firestore.Client): The Firestore client.
        user_profile_map (dict[str, str]): The mapping of usernames to IDs.
    """
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

def populate_votes(votes: list[dict], db: firestore.Client, user_profile_map_id: dict[str, str]) -> None:
    """
    Populate Votes collection.

    Args:
        votes (list[dict]): The list of votes to populate.
        db (firestore.Client): The Firestore client.
        user_profile_map_id (dict[str, str]): The mapping of user IDs to IDs.
    """
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

def create_dummy_users(user_profiles: list[dict]) -> None:
    """
    Create dummy users in Firebase Authentication.

    Args:
        user_profiles (list[dict]): The list of user profiles to create.
    """
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

def generate_votes_from_counts(deals: list[dict], comments: list[dict], all_user_ids: list[str]) -> list[dict]:
    """
    Generate votes based on upvote/downvote counts.

    Args:
        deals (list[dict]): The list of deals.
        comments (list[dict]): The list of comments.
        all_user_ids (list[str]): The list of all user IDs.

    Returns:
        list[dict]: The list of generated votes.
    """
    print("Generating Votes based on upvote/downvote counts...")
    votes = []
    used_votes = set()  # To prevent duplicate votes from the same user on the same item

    # Helper function to generate votes for an item
    def generate_votes_for_item(item_id: str, item_type: str, upvote_count: int, downvote_count: int, exclude_user_id: str) -> None:
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

def populate_generated_votes(votes: list[dict], db: firestore.Client) -> None:
    """
    Populate generated votes into Firestore.

    Args:
        votes (list[dict]): The list of votes to populate.
        db (firestore.Client): The Firestore client.
    """
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

def initialize_data(json_file_path: str) -> None:
    """
    Main function to initialize data.

    Args:
        json_file_path (str): The path to the JSON file.
    """
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
