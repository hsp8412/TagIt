import SwiftUI

/**
 `ScannedItemView` displays product reviews and allows users to add a new review for a scanned item.
 It shows the item details, a list of reviews, and a button to add a new review.
 */
struct ScannedItemView: View {
    @State private var shouldRefreshReviews = false // Flag to refresh the reviews after submitting a new one
    @StateObject var viewModel: ScannedItemViewModel // ViewModel to manage product reviews and filters
    @State private var navigateToAddReview = false // Controls navigation to the AddReviewView

    // Initialize the view with a barcode and product name
    init(barcode: String, productName: String) {
        _viewModel = StateObject(wrappedValue: ScannedItemViewModel(barcode: barcode, productName: productName))
    }

    var body: some View {
        VStack(spacing: 10) {
            // Filters Section for sorting or categorizing reviews
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.filters) { filter in
                        FilterButton(
                            icon: filter.icon,
                            text: filter.label,
                            isSelected: filter.isSelected,
                            action: {
                                viewModel.toggleFilter(id: filter.id) // Toggle filter selection
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .frame(height: 50)
            }

            Divider()
                .padding(.horizontal)

            // Reviews Section to display the list of reviews
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading Reviews...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center) // Show loading indicator while fetching reviews
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal) // Display error message if something goes wrong
                } else if viewModel.shownReviews.isEmpty {
                    Text("No reviews found for this item.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity) // Display a message if no reviews are available
                } else {
                    ScrollView {
                        VStack(spacing: 10) {
                            // Loop through each review and display it
                            ForEach(viewModel.shownReviews) { review in
                                ReviewCardView(review: review) // A card view to show individual review
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Add Review Button that triggers the navigation to the review submission screen
            if !viewModel.isLoading {
                Button(action: {
                    navigateToAddReview = true // Trigger navigation when clicked
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

            // Navigation to AddReviewView to submit a new review
            NavigationLink(
                destination: AddReviewView(
                    barcode: viewModel.barcode,
                    productName: viewModel.productName,
                    onReviewSubmitted: {
                        shouldRefreshReviews = true // Trigger refresh of reviews after adding a new one
                    }
                ),
                isActive: $navigateToAddReview
            ) {
                EmptyView()
            }
        }
        .onChange(of: shouldRefreshReviews) { _ in
            if shouldRefreshReviews {
                viewModel.fetchReviews() // Fetch the updated reviews
                shouldRefreshReviews = false
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Reviews for \(viewModel.productName)") // Title of the toolbar
                    .font(.system(size: 32, weight: .bold, design: .rounded))
            }
        }
        .background(Color(.systemGray6).ignoresSafeArea()) // Background color for the view
    }
}
