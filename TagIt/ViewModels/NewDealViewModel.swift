//
//  NewDealViewModel.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-20.
//

import Foundation
import UIKit
import SwiftUI
import FirebaseAuth
import CoreLocation

class NewDealViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var image: UIImage?
    @Published var productText: String = ""
    @Published var postText: String = ""
    @Published var price: String = ""
    @Published var location: Store? = nil
    @Published var submitted: Bool = false
    @Published var errorMessage: String? = nil
    @Published var stores: [Store] = []
    @Published var isLoading: Bool = true
    
    // MARK: - Private Properties
    private var selectedTab: Binding<Int>
    private let locationManager = LocationManager()
    
    // MARK: - Initializer
    init(selectedTab: Binding<Int>) {
        self.selectedTab = selectedTab
        self.getStores()
    }
    
    func getStores(){
        StoreService.shared.getStores{
            [weak self] result in
            switch result {
            case .success(let stores):
                self?.stores = stores
                self?.getClosestStore()
                self?.isLoading = false
            case .failure(let error):
                print("Error fetching stores: \(error)")
                self?.errorMessage = error.localizedDescription
                self?.isLoading = false
            }
        }
    }
    
    func getClosestStore() {
        
        locationManager.requestLocationPermission()
        
        // Check if stores are available
        guard !stores.isEmpty else { return }
        
        guard locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways else {
            
            return
        }
        
        // Check if user location is available
        guard let userLocation = locationManager.userLocation else {
            
            return
        }
        print("123")
        // Find the closest store
        let closestStore = stores.min(by: { store1, store2 in
            let distance1 = calculateDistance(from: userLocation, to: store1)
            let distance2 = calculateDistance(from: userLocation, to: store2)
            return distance1 < distance2
        })
        
        // Set the closest store
        location = closestStore
    }
    
    private func calculateDistance(from userLocation: CLLocation, to store: Store) -> CLLocationDistance {
        // Create a CLLocation instance for the store
        let storeLocation = CLLocation(latitude: store.latitude, longitude: store.longitude)
        // Calculate the distance
        return userLocation.distance(from: storeLocation)
    }
    
    // MARK: - Form Submission
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
        
        if let image = image {
            uploadImageAndSaveDeal(image: image, dealId: newDealId, userId: userId)
        } else {
            saveDeal(dealId: newDealId, userId: userId, photoUrl: "")
        }
    }
    
    // MARK: - Helper Functions
    
    // Uploads image and saves the new deal to Firestore
    private func uploadImageAndSaveDeal(image: UIImage, dealId: String, userId: String) {
        ImageService.shared.uploadImage(image, folder: .dealImage, fileName: "deal-\(dealId)") { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let downloadUrl):
                self.saveDeal(dealId: dealId, userId: userId, photoUrl: downloadUrl)
            case .failure(let error):
                self.errorMessage = "Image upload failed: \(error.localizedDescription)"
                self.submitted = false
            }
        }
    }
    
    // Creates and saves the deal to Firestore
    private func saveDeal(dealId: String, userId: String, photoUrl: String) {
        let newDeal = Deal(
            id: dealId,
            userID: userId,
            photoURL: photoUrl,
            productText: productText,
            postText: postText,
            price: Double(price) ?? 0,
            location: location?.name ?? "",
            date:"",
            commentIDs: [],
            upvote: 0,
            downvote: 0,
            locationId: location?.id as? String
        )
        
        DealService.shared.addDeal(newDeal: newDeal) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success():
                print("Deal added successfully")
                self.selectedTab.wrappedValue = 0
                self.clearForm()
            case .failure(let error):
                self.errorMessage = "Error when creating new deal: \(error.localizedDescription)"
            }
        }
    }
    
    // Clears all form fields
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
    
    // Validates all input fields
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
    
    // Validates price format (allows integers and decimals with up to two decimal places)
    private func isValidPrice(_ price: String) -> Bool {
        let priceRegex = "^[0-9]+(\\.[0-9]{1,2})?$"
        return NSPredicate(format: "SELF MATCHES %@", priceRegex).evaluate(with: price)
    }
}

