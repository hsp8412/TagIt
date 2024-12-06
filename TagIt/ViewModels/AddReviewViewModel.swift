//
//  AddReviewViewModel.swift
//  TagIt
//
//  Created by Angi Shi on 2024-11-25.
//

import FirebaseAuth
import Foundation
import SwiftUI

/**
     A view model responsible for managing the state and logic related to adding reviews within the TagIt application.

     This class handles user input for review details, image uploads, validation of review data, and submission of reviews to the backend.
     It leverages Firebase Authentication to identify the current user and interacts with `ReviewService` to handle review operations.

     The view model conforms to `ObservableObject`, allowing SwiftUI views to reactively update based on its published properties.
 */
class AddReviewViewModel: ObservableObject {
    // MARK: - Published Properties

    /// The title of the review entered by the user.
    @Published var reviewTitle: String = ""

    /// The text content of the review entered by the user.
    @Published var reviewText: String = ""

    /// The rating selected by the user for the review (e.g., number of stars).
    @Published var rating: Int = 0

    /// The image selected by the user to accompany the review. Optional as the user may choose not to add an image.
    @Published var selectedImage: UIImage? = nil

    /// A flag indicating whether a review submission is currently in progress. Used to show loading indicators.
    @Published var isLoading: Bool = false

    /// An optional error message to display if the review submission fails.
    @Published var errorMessage: String? = nil

    /// An optional success message to display upon successful review submission.
    @Published var successMessage: String? = nil

    /// A flag to notify when the review has been successfully submitted. Can be used to trigger navigation or UI updates.
    @Published var reviewSubmitted: Bool = false

    // MARK: - Private Properties

    /// The barcode number associated with the product being reviewed. Used to link the review to the correct product.
    private let barcode: String

    // MARK: - Initializer

    /**
         Initializes the `AddReviewViewModel` with the specified barcode number.

         - Parameter barcode: The barcode number of the product for which the review is being added.

         This initializer sets up the view model with the necessary context to associate the review with the correct product.
     */
    init(barcode: String) {
        self.barcode = barcode
    }

    // MARK: - Public Methods

    /**
         Submits the review after validating the input data.

         This method performs the following steps:
         1. Validates the review input fields.
         2. Sets the loading state to true and clears any previous error or success messages.
         3. Retrieves the current user's ID from Firebase Authentication.
         4. If an image is selected, uploads the image before submitting the review.
         5. If no image is selected, directly submits the review.

         If any step fails, appropriate error messages are set to inform the user.
     */
    func submitReview() {
        guard validateReview() else { return }

        isLoading = true
        errorMessage = nil
        successMessage = nil

        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "User not authenticated."
            isLoading = false
            return
        }

        if let selectedImage {
            // Upload image and submit review
            uploadImageAndSubmitReview(image: selectedImage, userId: userId)
        } else {
            // Submit review without an image
            handleReviewSubmission(userId: userId, photoURL: "")
        }
    }

    // MARK: - Private Methods

    /**
         Uploads the selected image to the server and proceeds to submit the review upon successful upload.

         - Parameters:
             - image: The `UIImage` selected by the user to accompany the review.
             - userId: The unique identifier of the current user submitting the review.

         - Note: Utilizes `ImageService` to handle image uploads. Upon successful upload, it retrieves the image URL and proceeds to submit the review. If the upload fails, it sets an appropriate error message.
     */
    private func uploadImageAndSubmitReview(image: UIImage, userId: String) {
        ImageService.shared.uploadImage(image, folder: .reviewImage, fileName: "review-\(UUID().uuidString)") { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(photoURL):
                    self?.handleReviewSubmission(userId: userId, photoURL: photoURL)
                case let .failure(error):
                    self?.errorMessage = "Failed to upload image: \(error.localizedDescription)"
                    self?.isLoading = false
                }
            }
        }
    }

    /**
         Handles the submission of the review to the backend service.

         - Parameters:
             - userId: The unique identifier of the current user submitting the review.
             - photoURL: The URL of the uploaded image associated with the review. Can be an empty string if no image was uploaded.

         - Note: Utilizes `ReviewService` to handle the actual review submission. Upon success, it sets a success message, clears the form, and notifies that the review has been submitted. On failure, it sets an appropriate error message.
     */
    private func handleReviewSubmission(userId: String, photoURL: String) {
        ReviewService.shared.handleReview(
            userId: userId,
            barcodeNumber: barcode,
            reviewStars: Double(rating),
            productName: "",
            reviewTitle: reviewTitle,
            reviewText: reviewText,
            photoURL: photoURL
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success():
                    self?.successMessage = "Review submitted successfully!"
                    self?.clearForm()
                    self?.reviewSubmitted = true
                case let .failure(error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    /**
         Validates the review input fields to ensure all required data is provided.

         - Returns: A boolean value indicating whether the review data is valid.

         - Note: Checks for non-empty review title and text, and ensures a rating has been selected. If any validation fails, it sets an appropriate error message.
     */
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

    /**
         Clears the review form by resetting all input fields to their default states.

         This method is called after a successful review submission to prepare the form for a new review.
     */
    private func clearForm() {
        reviewTitle = ""
        reviewText = ""
        rating = 0
        selectedImage = nil
    }
}
