import firebase_admin
from firebase_admin import credentials, firestore, storage, auth

import json
from datetime import datetime
import os
import requests
from PIL import Image
from io import BytesIO
import uuid

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
SERVICE_ACCOUNT_PATH = os.path.join(SCRIPT_DIR, "tagit-39035-firebase-adminsdk-hugo8-9c33455468.json")
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

# Function to delete an image from Firebase Storage
def delete_image_from_storage(image_url):
    try:
        bucket = storage.bucket()
        # Extract the blob name from the image URL
        if 'storage.googleapis.com' in image_url:
            blob_name = image_url.split('/o/')[1].split('?')[0]
        elif 'firebasestorage.googleapis.com' in image_url:
            blob_name = image_url.split('/o/')[1].split('?')[0]
        else:
            print(f"Unsupported URL format: {image_url}")
            return

        blob = bucket.blob(blob_name)
        blob.delete()
        print(f"Deleted image: {image_url}")
    except Exception as e:
        print(f"Error deleting image {image_url}: {e}")

# Function to delete images associated with dummy data
def delete_dummy_images():
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
        query = collection_ref.where(filter=firestore.FieldFilter("isDummy", "==", True))

        # Get all documents marked as dummy
        docs = query.stream()
        deleted_count = 0
        for doc in docs:
            doc_id = doc.id
            doc_data = doc.to_dict()
            try:
                # Delete associated images from Firebase Storage
                if "avatarURL" in doc_data:
                    delete_image_from_storage(doc_data["avatarURL"])
                if "photoURL" in doc_data:
                    delete_image_from_storage(doc_data["photoURL"])
                deleted_count += 1
                print(f"Deleted images for document {doc_id} from {collection_name}.")
            except Exception as e:
                print(f"Error deleting images for document {doc_id} from {collection_name}: {e}")

        print(f"Deleted images for {deleted_count} dummy documents from {collection_name}.\n")

    print("Dummy data image cleanup completed.")

# Function to delete dummy data and associated images
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
        query = collection_ref.where(filter=firestore.FieldFilter("isDummy", "==", True))

        # Get and delete all documents marked as dummy
        docs = query.stream()
        deleted_count = 0
        for doc in docs:
            doc_id = doc.id
            try:
                # Delete the document from Firestore
                db.collection(collection_name).document(doc_id).delete()
                deleted_count += 1
                print(f"Deleted document {doc_id} from {collection_name}.")
            except Exception as e:
                print(f"Error deleting document {doc_id} from {collection_name}: {e}")

        print(f"Deleted {deleted_count} dummy documents from {collection_name}.\n")

    print("Dummy data cleanup completed.")

# Function to delete dummy users from Firebase Authentication
def delete_dummy_users():
    try:
        # Fetch all users
        users = auth.list_users().iterate_all()
        for user in users:
            # Check if the user is a dummy user
            if user.display_name.endswith("_dummy"):
                try:
                    auth.delete_user(user.uid)
                    print(f"Deleted user: {user.uid}")
                except Exception as e:
                    print(f"Error deleting user {user.uid}: {e}")
    except Exception as e:
        print(f"Error fetching users: {e}")

# Run the cleanup script
if __name__ == "__main__":
    delete_dummy_images()
    delete_dummy_data()
    delete_dummy_users()
