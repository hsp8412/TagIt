//
//  AddReviewView.swift
//  TagIt
//
//  Created by Angi Shi on 2024-11-25.
//

import SwiftUI

extension View {
    /// Hides the keyboard for SwiftUI
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

/**
 View that allows users to add a review for a product, including rating, title, text, and an optional image.
 */
struct AddReviewView: View {
    // MARK: - Environment & State

    /// Dismiss action to close the view
    @Environment(\.dismiss) var dismiss
    /// The view model managing the review data and logic
    @StateObject var viewModel: AddReviewViewModel
    /// The product's name to display in the title
    let productName: String
    /// The product's barcode to associate with the review
    let barcode: String
    /// Callback function to notify the parent view when the review is submitted
    let onReviewSubmitted: () -> Void

    // MARK: - Initializer

    /**
     Initializes the AddReviewView with the product's barcode, name, and a callback function for when the review is submitted.

     - Parameters:
       - barcode: The barcode of the product being reviewed.
       - productName: The name of the product being reviewed.
       - onReviewSubmitted: A callback function to notify the parent view when the review is successfully submitted.
     */
    init(barcode: String, productName: String, onReviewSubmitted: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: AddReviewViewModel(barcode: barcode))
        self.barcode = barcode
        self.productName = productName
        self.onReviewSubmitted = onReviewSubmitted
    }

    // MARK: - View Body

    var body: some View {
        VStack {
            Text("Add a Review for \(productName)")
                .font(.title2)
                .fontWeight(.semibold)
                .padding()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Upload Image Section
                    VStack(alignment: .leading) {
                        Text("Upload Image (Optional)")
                            .font(.headline)
                            .foregroundColor(.gray)

                        ImageUploadView(
                            imageToUpload: $viewModel.selectedImage,
                            placeholderImage: UIImage(named: "addImageIcon")!,
                            width: 120,
                            height: 120
                        )
                        .padding(.vertical, 10)
                        .padding(.leading, 50)
                    }

                    // Title Section
                    VStack(alignment: .leading) {
                        Text("Title")
                            .font(.headline)
                            .foregroundColor(.gray)

                        TextField("Title", text: $viewModel.reviewTitle)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .padding(.bottom, 10)

                    // Rating Section
                    VStack(alignment: .leading) {
                        Text("Your Rating")
                            .font(.headline)
                            .foregroundColor(.gray)

                        HStack {
                            ForEach(1 ... 5, id: \.self) { star in
                                Image(systemName: star <= viewModel.rating ? "star.fill" : "star")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(star <= viewModel.rating ? .yellow : .gray)
                                    .onTapGesture {
                                        viewModel.rating = star
                                    }
                            }
                        }
                    }
                    .padding(.bottom, 10)

                    // Review Text Section
                    VStack(alignment: .leading) {
                        Text("Your Review")
                            .font(.headline)
                            .foregroundColor(.gray)

                        TextEditor(text: $viewModel.reviewText)
                            .frame(height: 150)
                            .padding(5)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
                    }

                    // Error or Success Message
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 5)
                    }

                    if let successMessage = viewModel.successMessage {
                        Text(successMessage)
                            .foregroundColor(.green)
                            .font(.caption)
                            .padding(.top, 5)
                    }
                }
                .padding(.horizontal, 20)
            }

            Spacer()

            // Submit Button
            Button(action: {
                viewModel.submitReview()
            }) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Image(systemName: "paperplane.fill")
                            .font(.title2)
                        Text("Submit Review")
                            .font(.headline)
                    }
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
            .disabled(viewModel.isLoading)
        }
        .background(Color(.systemGray6).ignoresSafeArea())
        .onTapGesture {
            hideKeyboard() // Hide keyboard when tapping outside text fields
        }
        .onChange(of: viewModel.reviewSubmitted) { submitted in
            if submitted {
                onReviewSubmitted() // Notify parent of successful submission
                dismiss() // Dismiss the view on successful review submission
            }
        }
    }
}
