//
//  AddReviewViewModel.swift
//  TagIt
//
//  Created by Angi Shi on 2024-11-25.
//

import Foundation
import SwiftUI
import FirebaseAuth

class AddReviewViewModel: ObservableObject {
    @Published var reviewTitle: String = ""
    @Published var reviewText: String = ""
    @Published var rating: Int = 0
    @Published var selectedImage: UIImage? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil
    private let barcode: String

    init(barcode: String) {
        self.barcode = barcode
    }

    func submitReview() {
        guard validateReview() else { return }

        isLoading = true
        errorMessage = nil
        successMessage = nil

        guard let userId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User not authenticated."
            self.isLoading = false
            return
        }

        let photoURL = "" // Handle image upload if necessary

        ReviewService.shared.handleReview(
            userId: userId,
            barcodeNumber: barcode,
            reviewStars: Double(rating),
            productName: "", // Provide the product name if available
            reviewTitle: reviewTitle,
            reviewText: reviewText,
            photoURL: photoURL,
            completion: { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch result {
                    case .success():
                        self?.successMessage = "Review submitted successfully!"
                        self?.clearForm()
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                    }
                }
            }
        )
    }

    private func validateReview() -> Bool {
        errorMessage = nil

        guard !reviewTitle.isEmpty else {
            errorMessage = "Review title cannot be empty."
            return false
        }

        guard !reviewText.isEmpty else {
            errorMessage = "Review text cannot be empty."
            return false
        }

        guard rating > 0 else {
            errorMessage = "Please select a rating."
            return false
        }

        return true
    }

    private func clearForm() {
        reviewTitle = ""
        reviewText = ""
        rating = 0
        selectedImage = nil
    }
}
