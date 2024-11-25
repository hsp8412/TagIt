//
//  AddReviewViewModel.swift
//  TagIt
//
//  Created by Angi Shi on 2024-11-25.
//

import Foundation
import SwiftUI

class AddReviewViewModel: ObservableObject {
    @Published var reviewTitle: String = ""
    @Published var reviewText: String = ""
    @Published var rating: Int = 0
    @Published var selectedImage: UIImage? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil

    func submitReview(for barcode: String) {
        guard validateReview() else { return }

        isLoading = true
        errorMessage = nil
        successMessage = nil

        // Simulate async submission
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            DispatchQueue.main.async {
                self.isLoading = false
                self.successMessage = "Review submitted successfully!"
                self.clearForm()
            }
        }
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
