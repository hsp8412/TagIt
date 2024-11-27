//
//  ScannedItemView.swift
//  TagIt
//
//  Created by Angi Shi on 2024-11-05.
//
import SwiftUI
struct ScannedItemView: View {
    @State private var shouldRefreshReviews = false
    @StateObject var viewModel: ScannedItemViewModel
    @State private var navigateToAddReview = false

    init(barcode: String, productName: String) {
        _viewModel = StateObject(wrappedValue: ScannedItemViewModel(barcode: barcode, productName: productName))
    }

    var body: some View {
        VStack(spacing: 10) {
            // Filters Section
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.filters) { filter in
                        FilterButton(
                            icon: filter.icon,
                            text: filter.label,
                            isSelected: filter.isSelected,
                            action: {
                                viewModel.toggleFilter(id: filter.id)
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .frame(height: 50)
            }

            Divider()
                .padding(.horizontal)

            // Reviews Section
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading Reviews...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                } else if viewModel.shownReviews.isEmpty {
                    Text("No reviews found for this item.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(viewModel.shownReviews) { review in
                                ReviewCardView(review: review)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Add Review Button
            if !viewModel.isLoading {
                Button(action: {
                    navigateToAddReview = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                        Text("Add a Review")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 10)
            }

            // Navigation to AddReviewView
            NavigationLink(
                destination: AddReviewView(
                    barcode: viewModel.barcode,
                    productName: viewModel.productName,
                    onReviewSubmitted: {
                        shouldRefreshReviews = true
                    }
                ),
                isActive: $navigateToAddReview
            ) {
                EmptyView()
            }
        }
        .onChange(of: shouldRefreshReviews) { _ in
            if shouldRefreshReviews {
                viewModel.fetchReviews()
                shouldRefreshReviews = false
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Reviews for \(viewModel.productName)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
            }
        }
        .background(Color(.systemGray6).ignoresSafeArea())
    }
}
