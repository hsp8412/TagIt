"""
DISCLAIMER: THIS SCRIPT WILL NUKE ALL DOCUMENTS IN THE TAGIT DB
"""

import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase Admin SDK
SERVICE_ACCOUNT_PATH = "/Users/petertran/Downloads/tagit-39035-firebase-adminsdk-hugo8-9c33455468.json"
cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
firebase_admin.initialize_app(cred)

# Firestore database reference
db = firestore.client()

# List of collections to clear
collections_to_clear = [
    "BarcodeItemReview",
    "Deals",
    "Stores",
    "UserComments",
    "UserProfile",
    "Votes",
    "barcodes"
]

def delete_collection(collection_name, batch_size=500):
    """
    Deletes all documents in a Firestore collection.
    
    Args:
        collection_name (str): The name of the collection to delete.
        batch_size (int): The number of documents to delete per batch.
    """
    collection_ref = db.collection(collection_name)
    try:
        while True:
            # Get a batch of documents
            docs = collection_ref.limit(batch_size).stream()
            deleted = 0

            for doc in docs:
                print(f"Deleting {doc.id} from {collection_name}")
                doc.reference.delete()
                deleted += 1

            if deleted < batch_size:
                break
    except Exception as e:
        print(f"Error deleting documents in {collection_name}: {e}")

if __name__ == "__main__":
    print("WARNING: THIS WILL DELETE ALL DOCUMENTS IN THE TAG IT DB.")
    confirmation = input("Are you sure you want to proceed? Type 'yes' to confirm: ").strip().lower()
    if confirmation == 'yes':
        for collection in collections_to_clear:
            print(f"Clearing collection: {collection}")
            delete_collection(collection)
        print("All specified collections have been cleared.")
    else:
        print("Operation canceled. No documents were deleted.")
