"""
Firestore Export Script

This script exports all collections and documents from Firestore into a JSON file.
It supports nested subcollections and serializes Firestore-specific data types (e.g., `datetime`)
into JSON-friendly formats.

The exported data is written to `firestore_export.json` in the current directory.

WARNING: This script fetches all Firestore data, which could be time-consuming for large databases.

Dependencies:
- Firebase Admin SDK service account JSON file with proper permissions.
- Permissions to access Firestore.

"""

import firebase_admin
from firebase_admin import credentials, firestore
import json
from datetime import datetime
from typing import Any, Dict

# Path to your Firebase service account JSON file
SERVICE_ACCOUNT_PATH = (
    "/Users/petertran/Downloads/tagit-39035-firebase-adminsdk-hugo8-9c33455468.json"
)

# Initialize Firebase Admin with your service account
cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
firebase_admin.initialize_app(cred)

# Firestore database client
db: firestore.Client = firestore.client()

def export_firestore_data() -> Dict[str, Any]:
    """
    Recursively exports all collections and documents from the root of Firestore.

    Returns:
        Dict[str, Any]: A dictionary representing the entire Firestore database,
                        where keys are collection names and values are their documents and subcollections.
    """
    export_data: Dict[str, Any] = {}
    root_collections = db.collections()  # Retrieve all top-level collections

    print("Exporting top-level collections...")
    # Iterate over all root collections and export their data
    for collection in root_collections:
        print(f"Exporting collection: {collection.id}")
        export_data[collection.id] = export_collection(collection)

    return export_data


def export_collection(collection: firestore.CollectionReference) -> Dict[str, Any]:
    """
    Exports all documents and subcollections in a given Firestore collection.

    Args:
        collection (firestore.CollectionReference): The Firestore collection to export.

    Returns:
        Dict[str, Any]: A dictionary containing document data and nested subcollection data.
    """
    collection_data: Dict[str, Any] = {}
    documents = collection.stream()  # Retrieve all documents in the collection

    print(f"Processing documents in collection: {collection.id}")
    for doc in documents:
        print(f"Exporting document: {doc.id}")
        document_data = doc.to_dict()  # Convert Firestore document to a dictionary
        subcollections = doc.reference.collections()  # Retrieve subcollections

        # Recursively export each subcollection
        for subcollection in subcollections:
            print(f"Exporting subcollection: {subcollection.id} for document: {doc.id}")
            document_data[subcollection.id] = export_collection(subcollection)
        
        # Add document data to the collection's dictionary
        collection_data[doc.id] = document_data

    return collection_data


def serialize_firestore_data(data: Any) -> Any:
    """
    Custom serialization for Firestore data to handle non-serializable types like `datetime`.

    Args:
        data (Any): The Firestore data to serialize (can be a dict, list, or primitive).

    Returns:
        Any: Serialized data with `datetime` objects converted to ISO 8601 strings.
    """
    if isinstance(data, datetime):
        return data.isoformat()  # Convert datetime to ISO 8601 string
    elif isinstance(data, dict):
        # Recursively serialize dictionary values
        return {key: serialize_firestore_data(value) for key, value in data.items()}
    elif isinstance(data, list):
        # Recursively serialize list elements
        return [serialize_firestore_data(item) for item in data]
    return data  # Return data as-is for other types


if __name__ == "__main__":
    try:
        print("Starting Firestore export...")
        # Export all Firestore data
        data = export_firestore_data()

        print("Serializing Firestore data for JSON output...")
        # Serialize data for JSON output
        serialized_data = serialize_firestore_data(data)

        output_file = "firestore_export.json"
        # Write serialized data to a JSON file
        with open(output_file, "w") as json_file:
            json.dump(serialized_data, json_file, indent=4)

        print(f"Firestore data exported successfully to {output_file}.")
    except Exception as e:
        # Print error message if an exception occurs
        print(f"An error occurred during export: {e}")
