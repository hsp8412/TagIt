# TagIt: A Grocery Deal Sharing App

TagIt is a mobile application built using SwiftUI and Firebase for sharing grocery deals and user reviews.  This README provides comprehensive documentation for developers working with the TagIt codebase.

## Key Features

* **Deal Posting:** Users can post deals including product name, description, price, location, and photos.
* **User Reviews:** Users can submit reviews for products, including star ratings and text reviews with optional photos.
* **Barcode Scanning:** Integrated barcode scanning to easily add product details and reviews.
* **User Authentication:** Secure user accounts managed by Firebase Authentication.
* **User Profiles:** User profiles include display name, avatar image, and ranking points.
* **Ranking System:** User rankings based on deal postings, upvotes, and comments.
* **Search Functionality:** Algolia-powered search for deals based on product names and locations.
* **Location Services:** Displays deals near the user's current location (requires location permission).
* **Saving Deals:** Users can save deals to their profile for later viewing.
* **Comments & Voting:** Upvote/downvote functionality for both deals and comments.

## Technologies Used

* **SwiftUI:**  For the user interface.
* **Firebase:** For backend services (Firestore, Authentication, Storage).
* **Algolia:** For search functionality.
* **Core Location:** For location-based services.
* **PhotosUI:** For image selection from the photo library.
* **AVFoundation:** For barcode scanning.

## Prerequisites

* Xcode 14 or later.
* A Firebase project set up with necessary services (Firestore, Authentication, Storage).  Obtain your `GoogleService-Info.plist` file, and add it to the Xcode project.
* An Algolia account and API Key, configured in `Info.plist` added to the Xcode project.  The Algolia index "search_deals" must be created.  Update `Info.plist` and `.env` with your Algolia API Key and App ID.
* CocoaPods (for dependency management - though appears to now use Swift Package Manager).


## Installation

1. **Clone the repository:**
   ```bash
   git clone <repository_url>
   ```

2. **Install dependencies:**
   * **Swift Package Manager:** Open the project in Xcode and let Xcode manage the dependencies.  You should be prompted to add the dependencies.  Ensure you have the required Firebase and Algolia packages added.

3. **Configure Firebase:**
   * Download your `GoogleService-Info.plist` file from your Firebase project settings and place it in the `TagIt` directory.
   * Add the file to your Xcode project.


4. **Configure Algolia:**
   * Create an Algolia index named "search_deals".
   * Replace placeholders in `TagIt/Info.plist` with your Algolia App ID and API Key.
   * Update `.env` file with `GEMINI_API_KEY` if using a Gemini API Key


5. **Run the project:** Open `TagIt.xcodeproj` in Xcode and run the application on a simulator or device.

## Usage Examples

### Deal Posting

The `NewDealView` allows users to create new deals.  The process involves filling out fields for product name, description, price, location and uploading an image.

### Barcode Scanning

The `BarcodeScannerView` utilizes the device's camera to scan barcodes.  Upon successful scanning, the barcode value will be sent to the next view for review submission.


### Searching Deals

The `SearchView` allows users to search for deals.  The search uses Algolia for quick searching by product name or location.


## Project Structure

The project is organized into the following directories:

* **TagIt:** Contains the main source code, models, services, view models, and views.
    * **Assets.xcassets:** Contains the application assets (images, color sets).
    * **Extensions:** Contains Swift extensions for helper functions.
    * **Models:** Contains data models (e.g., `Deal`, `UserProfile`).
    * **Other:** Contains helper functions (Utils, LocationManager).
    * **Preview Content:** Contains assets for preview.
    * **Services:** Contains classes for interacting with Firebase and Algolia (e.g., `AuthService`, `DealService`, `FirestoreService`, `ImageService`, `ReviewService`, `SearchService`, `StoreService`, `UserService`, `VoteService`).
    * **ViewModels:** Contains view models (e.g., `HomeViewModel`, `LoginViewModel`).
    * **Views:** Contains the user interface components and views.
    * **.env:** Contains environment variables (Algolia API Key).

* **TagIt.xcodeproj:** Xcode project files.


## Scripts

* **`dummy_data.json`:** Contains dummy data for testing.  This is populated by `set_dummy.py` and cleaned up by `delete_dummy.py`.
* **`delete_dummy.py`:** Deletes dummy data and associated images from Firestore and Storage.  Requires Firebase Admin SDK and a service account key file.
* **`dummy_data.json`:**  Contains dummy data for initializing or testing the database.
* **`firestore_export.py`:** Exports Firestore data to a JSON file.
* **`nuke_db.py`:** Deletes all data (deals, users, reviews, etc.) from Firestore and storage. **Use with extreme caution!**
* **`set_dummy.py`:** Populates the Firestore database with dummy data from `dummy_data.json`, creates dummy users and handles image uploads to Storage.

Before running any of the Python scripts, ensure you've installed the Firebase Admin SDK: `pip install firebase-admin` and have a valid service account key file (e.g., `tagit-39035-firebase-adminsdk-hugo8-9c33455468.json`) in the scripts directory.  The `set_dummy.py` script relies on image URLs and will download those images as part of its execution.

## Contributors

Chenghou Si, Ang


