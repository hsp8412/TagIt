import firebase_admin 
from firebase_admin import credentials, firestore
from datetime import datetime
from dummy_data import dummy_data

# Initialize Firebase Admin SDK
SERVICE_ACCOUNT_PATH = "/Users/petertran/Downloads/tagit-39035-firebase-adminsdk-hugo8-9c33455468.json"
cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
firebase_admin.initialize_app(cred)

# Firestore database reference
db = firestore.client()

# Initialize Firebase Admin SDK
def initialize_firebase(service_account_path):
    # Check if the app has already been initialized
    if not firebase_admin._apps:
        cred = credentials.Certificate(service_account_path)
        firebase_admin.initialize_app(cred)
    return firestore.client()

# Populate a Firestore collection with data
def populate_collection(collection_name, data_list, db):
    print(f"Populating {collection_name} collection...")
    for item in data_list:
        try:
            db.collection(collection_name).document(item["id"]).set(item)
            print(f"Added {collection_name}: {item['id']}")
        except Exception as e:
            print(f"Error adding {collection_name}: {item['id']}: {e}")

# Populate UserProfile and create a mapping of usernames to IDs
def populate_user_profiles(user_profiles, db):
    user_profile_map = {}
    print("Populating UserProfile collection...")
    for profile in user_profiles:
        try:
            db.collection("UserProfile").document(profile["id"]).set(profile)
            user_profile_map[profile["username"]] = profile["id"]
            print(f"Added UserProfile: {profile['id']}")
        except Exception as e:
            print(f"Error adding UserProfile: {e}")
    return user_profile_map

# Populate Stores collection
def populate_stores(stores, db):
    print("Populating Stores collection...")
    for store in stores:
        try:
            db.collection("Stores").document(store["id"]).set(store)
            print(f"Added Store: {store['id']} - {store['name']}")
        except Exception as e:
            print(f"Error adding Store {store['id']}: {e}")

# Populate Deals collection
def populate_deals(deals, db, user_profile_map):
    print("Populating Deals collection...")
    for deal in deals:
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
            print(f"Error: Store {deal['locationId']} for deal {deal['id']} does not exist.")
            continue

        # Ensure date field is valid
        deal["date"] = deal.get("date", datetime.now().isoformat())

        try:
            db.collection("Deals").document(deal["id"]).set(deal)
            print(f"Added Deal: {deal['id']} with userID {deal['userID']}")
        except Exception as e:
            print(f"Error adding Deal {deal['id']}: {e}")

# Populate UserComments collection
def populate_user_comments(comments, db, user_profile_map):
    print("Populating UserComments collection...")
    for comment in comments:
        username = comment["userID"]
        resolved_id = user_profile_map.get(username)
        if resolved_id:
            comment["userID"] = resolved_id
        else:
            print(f"Warning: No UserProfile found for userID {username}")
            comment["userID"] = "unknown"

        try:
            db.collection("UserComments").document(comment["id"]).set(comment)
            print(f"Added UserComment: {comment['id']} with userID {comment['userID']}")
        except Exception as e:
            print(f"Error adding UserComment: {e}")

# Main function to initialize data
def initialize_data(service_account_path, collections):
    db = initialize_firebase(service_account_path)

    # Populate collections
    user_profile_map = populate_user_profiles(collections["UserProfile"], db)
    populate_stores(collections["Stores"], db)
    populate_deals(collections["Deals"], db, user_profile_map)
    populate_user_comments(collections["UserComments"], db, user_profile_map)
    print("Data initialization completed.")

initialize_data(SERVICE_ACCOUNT_PATH, dummy_data)
