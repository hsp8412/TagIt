import firebase_admin
from firebase_admin import credentials, firestore
import json
from datetime import datetime

# Path to your Firebase service account JSON file
SERVICE_ACCOUNT_PATH = (
    "/Users/petertran/Downloads/tagit-39035-firebase-adminsdk-hugo8-9c33455468.json"
)

# Initialize Firebase Admin with your service account
cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
firebase_admin.initialize_app(cred)

# Firestore database client
db = firestore.client()


def export_firestore_data():
    """Recursively exports all collections and documents from Firestore."""
    export_data = {}
    root_collections = db.collections()

    for collection in root_collections:
        export_data[collection.id] = export_collection(collection)

    return export_data


def export_collection(collection):
    """Exports all documents and subcollections in a given Firestore collection."""
    collection_data = {}
    documents = collection.stream()

    for doc in documents:
        document_data = doc.to_dict()
        subcollections = doc.reference.collections()
        for subcollection in subcollections:
            document_data[subcollection.id] = export_collection(subcollection)
        collection_data[doc.id] = document_data

    return collection_data


def serialize_firestore_data(data):
    """Custom serialization for Firestore data."""
    if isinstance(data, datetime):
        # Convert Firestore Datetime to ISO 8601 string
        return data.isoformat()
    elif isinstance(data, dict):
        # Recursively serialize dictionary
        return {key: serialize_firestore_data(value) for key, value in data.items()}
    elif isinstance(data, list):
        # Recursively serialize list
        return [serialize_firestore_data(item) for item in data]
    return data


if __name__ == "__main__":
    try:
        # Export all Firestore data
        data = export_firestore_data()

        # Serialize data for JSON output
        serialized_data = serialize_firestore_data(data)

        # Write data to a JSON file
        with open("firestore_export.json", "w") as json_file:
            json.dump(serialized_data, json_file, indent=4)

        print("Firestore data exported successfully.")
    except Exception as e:
        print(f"An error occurred: {e}")
