import firebase_admin
from firebase_admin import credentials, firestore, auth
import json
import os
import logging

# Set up logging
logging.basicConfig(level=logging.DEBUG)

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
SERVICE_ACCOUNT_PATH = os.path.join(SCRIPT_DIR, "tagit-39035-firebase-adminsdk-hugo8-9c33455468.json")
JSON_FILE_PATH = os.path.join(SCRIPT_DIR, "dummy_data.json")
BUCKET_NAME = 'tagit-39035.appspot.com'

# Initialize Firebase Admin SDK
cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
firebase_admin.initialize_app(cred, {'storageBucket': BUCKET_NAME})

# Firestore database reference
db = firestore.client()

# Check if document already exists before adding
def document_exists(collection, doc_id, db):
    doc_ref = db.collection(collection).document(doc_id)
    doc = doc_ref.get()
    return doc.exists

def populate_user_profiles(user_profiles, db):
    user_profile_map = {}
    print("Populating UserProfile collection...")
    for profile in user_profiles:
        doc_id = profile["id"]
        try:
            user_profile_map[doc_id] = doc_id  # Use the 'id' field as the key
            if not document_exists("UserProfile", doc_id, db):
                db.collection("UserProfile").document(doc_id).set(profile)
                print(f"Added UserProfile: {doc_id}")
            else:
                print(f"Skipped UserProfile: {doc_id} (already exists)")
        except Exception as e:
            logging.error(f"Error processing UserProfile {doc_id}: {e}")
    return user_profile_map

# Create dummy users in Firebase Authentication
def create_dummy_users(user_profiles):
    for profile in user_profiles:
        try:
            user = auth.get_user(profile["id"])  # Check if user exists
            print(f"User already exists: {user.uid}")
        except auth.UserNotFoundError:
            try:
                user = auth.create_user(
                    uid=profile["id"],
                    email=profile["email"],
                    email_verified=False,
                    password='dummy_password',
                    display_name=f"{profile['displayName']}_dummy",
                    disabled=False
                )
                print(f"Created user: {user.uid}")
            except Exception as e:
                logging.error(f"Error creating user {profile['id']}: {e}")


# Main function to initialize user profiles
def initialize_user_profiles(json_file_path):
    # Load JSON data
    with open(json_file_path, "r") as f:
        data = json.load(f)

    # Create dummy users in Firebase Authentication
    create_dummy_users(data["UserProfile"])

    # Populate UserProfile collection and create a mapping of usernames to IDs
    user_profile_map = populate_user_profiles(data["UserProfile"], db)
    print("User Profile Map:", user_profile_map)

    print("UserProfile initialization completed.")
    return user_profile_map

# Function to update votes with correct user IDs, item types, and remove unnecessary fields
def update_votes(votes, user_profile_map, db):
    print("Updating Votes collection...")
    for vote in votes:
        doc_id = vote["id"]
        if document_exists("Votes", doc_id, db):
            try:
                # Ensure itemType is a number
                if isinstance(vote["itemType"], str):
                    if vote["itemType"] == "comment":
                        vote["itemType"] = 0
                    elif vote["itemType"] == "deal":
                        vote["itemType"] = 1

                # Map username to user ID
                username = vote["userId"]
                resolved_id = user_profile_map.get(username)
                if resolved_id:
                    vote["userId"] = resolved_id
                else:
                    logging.warning(f"No UserProfile found for userID {username}")
                    vote["userId"] = "unknown"

                # Remove dateTime field if it exists
                if "dateTime" in vote:
                    del vote["dateTime"]

                # Remove id field
                if "id" in vote:
                    del vote["id"]

                # Update Firestore document
                db.collection("Votes").document(doc_id).set(vote)  # Use .set() to overwrite the document
                print(f"Updated Vote: {doc_id} with userID {vote['userId']}")
            except Exception as e:
                logging.error(f"Error updating Vote {doc_id}: {e}")
        else:
            print(f"Skipped Vote: {doc_id} (does not exist)")


# Run the initialization
user_profile_map = initialize_user_profiles(JSON_FILE_PATH)

# Load JSON data again to update votes
with open(JSON_FILE_PATH, "r") as f:
    data = json.load(f)

# Update votes with correct user IDs and item types
update_votes(data["Votes"], user_profile_map, db)

# Optionally, save the user_profile_map to a file for later use
with open('user_profile_map.json', 'w') as f:
    json.dump(user_profile_map, f)
