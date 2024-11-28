import firebase_admin 
from firebase_admin import credentials, firestore

SERVICE_ACCOUNT_PATH = "/Users/petertran/Downloads/tagit-39035-firebase-adminsdk-hugo8-9c33455468.json"

# Initialize Firebase Admin SDK
cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
firebase_admin.initialize_app(cred)

# Firestore database reference
db = firestore.client()

def delete_dummy_data():
    # Collections to clean up
    collections = [
        "Deals",
        "UserComments",
        "BarcodeItemReview",
        "ReviewStars",
        "Votes",
        "UserProfile",
        "Stores",
    ]

    for collection_name in collections:
        print(f"Checking collection: {collection_name} for dummy data...")
        collection_ref = db.collection(collection_name)
        query = collection_ref.where("isDummy", "==", True)
        
        # Get and delete all documents marked as dummy
        docs = query.stream()
        deleted_count = 0
        for doc in docs:
            doc_id = doc.id
            try:
                db.collection(collection_name).document(doc_id).delete()
                deleted_count += 1
                print(f"Deleted document {doc_id} from {collection_name}.")
            except Exception as e:
                print(f"Error deleting document {doc_id} from {collection_name}: {e}")
        
        print(f"Deleted {deleted_count} dummy documents from {collection_name}.\n")

    print("Dummy data cleanup completed.")

# Run the cleanup script
if __name__ == "__main__":
    delete_dummy_data()
