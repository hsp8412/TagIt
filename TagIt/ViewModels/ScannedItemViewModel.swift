//
//  ScannedItemViewModel.swift
//  TagIt
//
//  Created by Angi Shi on 2024-11-24.
//

import Foundation

class ScannedItemViewModel: ObservableObject {
    @Published var reviews: [Review] = [] // Holds reviews for the scanned item
    @Published var isLoading: Bool = true // Indicates loading state
    @Published var errorMessage: String? = nil // Stores error messages

    // Fetch all reviews for a scanned barcode
    func fetchReviews(for barcode: String) {
        isLoading = true
        errorMessage = nil
        
        // Add your actual fetching logic here
        // Simulate fetching data for now
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Simulate delay
            if barcode.isEmpty {
                self.errorMessage = "Invalid barcode."
                self.isLoading = false
            } else {
                self.reviews = [
                    Review(id: "1", userID: "1B7Ra3hPWbOVr2B96mzp3oGXIiK2", photoURL: "https://i.imgur.com/8ciNZcY.jpeg", reviewText: "Great product!", rating: 5, date: "2 days ago"),
                    Review(id: "2", userID: "1B7Ra3hPWbOVr2B96mzp3oGXIiK2", photoURL: "https://i.imgur.com/8ciNZcY.jpeg", reviewText: "Good quality.", rating: 4, date: "1 week ago")
                ]
                self.isLoading = false
            }
        }
    }
}
