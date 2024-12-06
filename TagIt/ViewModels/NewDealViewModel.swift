//
//  NewDealViewModel.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-20.
//

import CoreLocation
import FirebaseAuth
import Foundation
import SwiftUI
import UIKit

/**
 ViewModel responsible for managing the creation of new deals, including handling form inputs,
 image uploads, location selection, and interaction with related services.
 */
class NewDealViewModel: ObservableObject {
    // MARK: - Published Properties

    /// The image associated with the new deal.
    @Published var image: UIImage?
    /// The name of the product being dealt.
    @Published var productText: String = ""
    /// The description or details of the post.
    @Published var postText: String = ""
    /// The price of the product as a string.
    @Published var price: String = ""
    /// The selected store location for the deal.
    @Published var location: Store? = nil
    /// Indicates whether the deal has been successfully submitted.
    @Published var submitted: Bool = false
    /// Stores any error messages to be displayed to the user.
    @Published var errorMessage: String? = nil
    /// A list of available stores for selection.
    @Published var stores: [Store] = []
    /// Indicates whether a loading process is ongoing.
    @Published var isLoading: Bool = true
    /// Indicates whether the location field has been interacted with.
    @Published var locationTouched = false

    // MARK: - Private Properties

    /// Binding to the selected tab in the UI.
    private var selectedTab: Binding<Int>
    /// Manages location-related functionalities.
    private let locationManager = LocationManager()

    // MARK: - Initializer

    /**
     Initializes the NewDealViewModel with a binding to the selected tab and fetches available stores.

     - Parameter selectedTab: A binding to the currently selected tab index.
     */
    init(selectedTab: Binding<Int>) {
        self.selectedTab = selectedTab
        getStores()
    }

    /**
     Fetches the list of available stores from the StoreService.
     */
    func getStores() {
        StoreService.shared.getStores { [weak self] result in
            switch result {
            case let .success(stores):
                self?.stores = stores
                self?.isLoading = false
            case let .failure(error):
                print("Error fetching stores: \(error)")
                self?.errorMessage = error.localizedDescription
                self?.isLoading = false
            }
        }
    }

    /**
     Determines the closest store to the user's current location.
     */
    func getClosestStore() {
        locationManager.requestLocationPermission()

        // Check if stores are available
        guard !stores.isEmpty else { return }

        // Verify location authorization status
        guard locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways else {
            return
        }

        // Ensure user location is available
        guard let userLocation = locationManager.userLocation else {
            return
        }
        print("123")
        // Find the closest store based on distance
        let closestStore = stores.min(by: { store1, store2 in
            let distance1 = calculateDistance(from: userLocation, to: store1)
            let distance2 = calculateDistance(from: userLocation, to: store2)
            return distance1 < distance2
        })

        // Set the closest store
        location = closestStore
    }

    /**
     Calculates the distance between the user's location and a given store.

     - Parameters:
       - userLocation: The user's current location.
       - store: The store to calculate the distance to.
     - Returns: The distance in meters.
     */
    private func calculateDistance(from userLocation: CLLocation, to store: Store) -> CLLocationDistance {
        // Create a CLLocation instance for the store
        let storeLocation = CLLocation(latitude: store.latitude, longitude: store.longitude)
        // Calculate the distance
        return userLocation.distance(from: storeLocation)
    }

    // MARK: - Form Submission

    /**
     Handles the submission of the new deal form, including validation and saving the deal.
     */
    func handleSubmit() {
        submitted = true

        guard validate() else {
            submitted = false
            return
        }

        let newDealId = UUID().uuidString
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "Unable to retrieve user ID."
            submitted = false
            return
        }

        if let image {
            uploadImageAndSaveDeal(image: image, dealId: newDealId, userId: userId)
        } else {
            saveDeal(dealId: newDealId, userId: userId, photoUrl: "")
        }
    }

    // MARK: - Helper Functions

    /**
     Uploads the selected image and saves the new deal to Firestore.

     - Parameters:
       - image: The image to upload.
       - dealId: The unique identifier for the new deal.
       - userId: The ID of the user creating the deal.
     */
    private func uploadImageAndSaveDeal(image: UIImage, dealId: String, userId: String) {
        ImageService.shared.uploadImage(image, folder: .dealImage, fileName: "deal-\(dealId)") { [weak self] result in
            guard let self else { return }

            switch result {
            case let .success(downloadUrl):
                saveDeal(dealId: dealId, userId: userId, photoUrl: downloadUrl)
            case let .failure(error):
                errorMessage = "Image upload failed: \(error.localizedDescription)"
                submitted = false
            }
        }
    }

    /**
     Creates and saves the new deal to Firestore.

     - Parameters:
       - dealId: The unique identifier for the new deal.
       - userId: The ID of the user creating the deal.
       - photoUrl: The URL of the uploaded photo.
     */
    private func saveDeal(dealId: String, userId: String, photoUrl: String) {
        let newDeal = Deal(
            id: dealId,
            userID: userId,
            photoURL: photoUrl,
            productText: productText,
            postText: postText,
            price: Double(price) ?? 0,
            location: location?.name ?? "",
            date: "",
            commentIDs: [],
            upvote: 0,
            downvote: 0,
            locationId: location?.id as? String
        )

        DealService.shared.addDeal(newDeal: newDeal) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success():
                print("Deal added successfully")
                selectedTab.wrappedValue = 0
                clearForm()
            case let .failure(error):
                errorMessage = "Error when creating new deal: \(error.localizedDescription)"
            }
        }
    }

    /**
     Clears all the form fields after successful submission.
     */
    private func clearForm() {
        productText = ""
        postText = ""
        price = ""
        location = nil
        image = nil
        submitted = false
        errorMessage = nil
    }

    // MARK: - Validation

    /**
     Validates all input fields in the form.

     - Returns: A boolean indicating whether the form inputs are valid.
     */
    private func validate() -> Bool {
        errorMessage = nil

        guard !productText.isEmpty, !price.isEmpty, location != nil, !postText.isEmpty, image != nil else {
            errorMessage = "Please fill in all fields and upload an image."
            return false
        }

        guard productText.count >= 3 else {
            errorMessage = "Product name must be at least 3 characters long."
            return false
        }

        guard isValidPrice(price) else {
            errorMessage = "Please enter a valid price."
            return false
        }

        return true
    }

    /**
     Validates the format of the price input.

     - Parameter price: The price string to validate.
     - Returns: A boolean indicating whether the price format is valid.
     */
    private func isValidPrice(_ price: String) -> Bool {
        let priceRegex = "^[0-9]+(\\.[0-9]{1,2})?$"
        return NSPredicate(format: "SELF MATCHES %@", priceRegex).evaluate(with: price)
    }
}
