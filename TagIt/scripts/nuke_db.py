import firebase_admin
from firebase_admin import credentials, firestore, storage, auth

# Initialize Firebase Admin SDK
SERVICE_ACCOUNT_PATH = "/Users/petertran/Downloads/tagit-39035-firebase-adminsdk-hugo8-9c33455468.json"
cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
firebase_admin.initialize_app(cred, {'storageBucket': 'tagit-39035.appspot.com'})

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

# List of folders to clear in Firebase Storage
folders_to_clear = [
    "avatar/",
    "dealImage/",
    "productImage/",
    "reviewImage/"
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

def delete_files_in_folders():
    """
    Deletes all files in the specified folders in Firebase Storage.
    """
    bucket = storage.bucket()
    try:
        for folder in folders_to_clear:
            print(f"Deleting files in folder: {folder}")
            blobs = bucket.list_blobs(prefix=folder)
            deleted_count = 0
            for blob in blobs:
                print(f"Deleting file: {blob.name}")
                blob.delete()
                deleted_count += 1
            print(f"Deleted {deleted_count} files from folder: {folder}")
    except Exception as e:
        print(f"Error deleting files in folders: {e}")

def delete_all_users():
    """
    Deletes all users in Firebase Authentication.
    """
    try:
        print("Fetching users from Firebase Authentication...")
        users = auth.list_users().iterate_all()
        deleted_count = 0
        for user in users:
            try:
                print(f"Deleting user: {user.uid}")
                auth.delete_user(user.uid)
                deleted_count += 1
            except Exception as e:
                print(f"Error deleting user {user.uid}: {e}")
        print(f"Deleted {deleted_count} users from Firebase Authentication.")
    except Exception as e:
        print(f"Error fetching users from Firebase Authentication: {e}")

if __name__ == "__main__":
    print("WARNING: THIS WILL DELETE ALL DOCUMENTS, FILES, AND USERS IN THE TAG IT DB AND STORAGE.")
    confirmation = input("Are you sure you want to proceed? Type 'yes' to confirm: ").strip().lower()
    if confirmation == 'yes':
        for collection in collections_to_clear:
            print(f"Clearing collection: {collection}")
            delete_collection(collection)
        
        print("Clearing storage folders...")
        delete_files_in_folders()

        print("Deleting users from Firebase Authentication...")
        delete_all_users()

        print("All specified collections, storage folders, and users have been cleared.")
    else:
        print("Operation canceled. No documents, files, or users were deleted.")
