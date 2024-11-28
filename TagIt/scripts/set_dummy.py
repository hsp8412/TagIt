import firebase_admin
from firebase_admin import credentials, firestore
import json
from datetime import datetime
import os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
SERVICE_ACCOUNT_PATH = os.path.join(
    SCRIPT_DIR, "tagit-39035-firebase-adminsdk-hugo8-9c33455468.json"
)
JSON_FILE_PATH = os.path.join(SCRIPT_DIR, "dummy_data.json")

# Initialize Firebase Admin SDK
cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
firebase_admin.initialize_app(cred)

# Firestore database reference
db = firestore.client()


# Load JSON file and replace placeholders
def load_and_replace_json(file_path):
    with open(file_path, "r") as f:
        data = json.load(f)
    return replace_timestamps(data)


# Recursively replace `__SERVER_TIMESTAMP__` with `firestore.SERVER_TIMESTAMP`
def replace_timestamps(data):
    if isinstance(data, dict):
        return {key: replace_timestamps(value) for key, value in data.items()}
    elif isinstance(data, list):
        return [replace_timestamps(item) for item in data]
    elif data == "__SERVER_TIMESTAMP__":
        return firestore.SERVER_TIMESTAMP
    return data


# Check if document already exists before adding
def document_exists(collection, doc_id, db):
    doc_ref = db.collection(collection).document(doc_id)
    doc = doc_ref.get()
    return doc.exists


# Populate a Firestore collection with data
def populate_collection(collection_name, data_list, db):
    print(f"Populating {collection_name} collection...")
    for item in data_list:
        doc_id = item["id"]
        if not document_exists(collection_name, doc_id, db):
            try:
                db.collection(collection_name).document(doc_id).set(item)
                print(f"Added {collection_name}: {doc_id}")
            except Exception as e:
                print(f"Error adding {collection_name}: {doc_id}: {e}")
        else:
            print(f"Skipped {collection_name}: {doc_id} (already exists)")


# Populate UserProfile and create a mapping of usernames to IDs
def populate_user_profiles(user_profiles, db):
    user_profile_map = {}
    print("Populating UserProfile collection...")
    for profile in user_profiles:
        doc_id = profile["id"]
        if not document_exists("UserProfile", doc_id, db):
            try:
                db.collection("UserProfile").document(doc_id).set(profile)
                user_profile_map[profile["username"]] = doc_id
                print(f"Added UserProfile: {doc_id}")
            except Exception as e:
                print(f"Error adding UserProfile: {e}")
        else:
            print(f"Skipped UserProfile: {doc_id} (already exists)")
    return user_profile_map


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
                print(
                    f"Error: Store {deal['locationId']} for deal {doc_id} does not exist."
                )
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

            try:
                db.collection("UserComments").document(doc_id).set(comment)
                print(f"Added UserComment: {doc_id} with userID {comment['userID']}")
            except Exception as e:
                print(f"Error adding UserComment: {e}")
        else:
            print(f"Skipped UserComment: {doc_id} (already exists)")



# Main function to initialize data
def initialize_data(json_file_path):
    # Load JSON data
    collections = load_and_replace_json(json_file_path)

    # Populate collections
    user_profile_map = populate_user_profiles(collections["UserProfile"], db)
    populate_stores(collections["Stores"], db)
    populate_deals(collections["Deals"], db, user_profile_map)
    populate_user_comments(collections["UserComments"], db, user_profile_map)
    print("Data initialization completed.")


# Run the initialization
initialize_data(JSON_FILE_PATH)
