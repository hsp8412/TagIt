//
//  ScannedItemView.swift
//  TagIt
//
//  Created by Angi Shi on 2024-11-05.
//

import SwiftUI

struct ScannedItemView: View {
    @StateObject var viewModel: ScannedItemViewModel
    let productName: String
    @State private var navigateToAddReview = false

    init(barcode: String, productName: String) {
        _viewModel = StateObject(wrappedValue: ScannedItemViewModel(barcode: barcode))
        self.productName = productName
    }

    var body: some View {
        VStack {
            if viewModel.isLoading {
                VStack {
                    Spacer()
                    ProgressView("Loading Reviews...")
                        .padding()
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else if viewModel.reviews.isEmpty {
                Text("Reviews for \(productName)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, 50)

                Text("No reviews found for this item.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    Text("Reviews for \(productName)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                        .padding()

                    VStack(spacing: 10) {
                        ForEach(viewModel.reviews) { review in
                            ReviewCardView(review: review)
                        }
                    }
                    .padding()
                }
            }

            Spacer()

            if !viewModel.isLoading {
                Button(action: {
                    navigateToAddReview = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)

                        Text("Add a Review")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                .padding(.bottom, 10)
            }

            NavigationLink(
                destination: AddReviewView(barcode: viewModel.barcode, productName: productName),
                isActive: $navigateToAddReview
            ) {
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .background(Color(.systemGray6))
    }
}

struct ScannedItemView_Previews: PreviewProvider {
    static var previews: some View {
        ScannedItemView(barcode: "1234567890123", productName: "Sample Product")
    }
}
