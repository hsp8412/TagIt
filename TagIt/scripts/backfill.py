import firebase_admin
from firebase_admin import credentials, firestore

# Path to your Firebase service account JSON file
SERVICE_ACCOUNT_PATH = "/Users/petertran/Downloads/tagit-39035-firebase-adminsdk-hugo8-9c33455468.json"

# Initialize Firebase Admin with your service account
cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
firebase_admin.initialize_app(cred)

# Firestore database client
db = firestore.client()

def backfill_user_profiles():
    # Reference the UserProfile collection
    users_ref = db.collection("UserProfile")
    docs = users_ref.stream()

    for doc in docs:
        user_data = doc.to_dict()
        updates = {}

        # Check and add missing fields with default values
        if "totalUpvotes" not in user_data:
            updates["totalUpvotes"] = 0
        if "totalDownvotes" not in user_data:
            updates["totalDownvotes"] = 0
        if "totalDeals" not in user_data:
            updates["totalDeals"] = 0
        if "totalComments" not in user_data:
            updates["totalComments"] = 0
        if "rankingPoints" not in user_data:
            updates["rankingPoints"] = 0

        # Update Firestore document if any missing fields are found
        if updates:
            print(f"Updating user {doc.id} with {updates}")
            users_ref.document(doc.id).update(updates)

if __name__ == "__main__":
    backfill_user_profiles()
