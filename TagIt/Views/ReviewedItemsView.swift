import FirebaseAuth
import SwiftUI

/**
 `ReviewedItemsView` displays a list of items that the user has reviewed. It allows searching through the reviews and loading more reviews as needed.
 */
struct ReviewedItemsView: View {
    @State var reviews: [BarcodeItemReview] = [] // Stores all reviews fetched from the database
    @State var shownReviews: [BarcodeItemReview] = [] // Stores the reviews to be displayed (filtered based on search)
    @State var userID: String? // Stores the current user's ID
    @State var search: String = "" // Stores the text entered in the search field
    @State var isLoading: Bool = true // Indicates whether the data is being loaded
    @State var errorMessage: String? // Holds any error messages that need to be displayed

    var body: some View {
        VStack {
            // Search Bar for filtering reviews
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.gray)
                    .padding(.leading)

                TextField("Search", text: $search)
                    .autocapitalization(.none)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray, lineWidth: 1)
                    .frame(height: 40)
            }
            .padding()
            .onSubmit {
                // Trigger search when user submits the search query
                print("Searching \"\(search)\"")
                searchReviews(searchText: search)
            }

            // Title Section
            HStack {
                Image(systemName: "cart.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 30)
                    .foregroundStyle(.green)
                    .padding(.horizontal)

                Text("Reviewed Items")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Reviews Section
            if isLoading {
                // Show loading spinner if data is being fetched
                ProgressView("Loading reviewed items...")
                    .padding(.top, 20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage {
                // Display error message if fetching reviews fails
                Text("Error: \(errorMessage)")
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Display reviews in a scrollable list
                ScrollView {
                    if shownReviews.isEmpty {
                        // Show message if no reviews are available
                        ZStack {
                            Spacer().containerRelativeFrame([.horizontal, .vertical])
                            Text("Sorry, you have not reviewed any items...")
                                .foregroundColor(.gray)
                        }
                    } else {
                        // Display each review in the list
                        VStack(alignment: .leading, spacing: 30) {
                            ForEach(shownReviews) { review in
                                ReviewCardView(review: review)
                                    .background(Color.white)
                                    .cornerRadius(15)
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.top, 10)
                .refreshable {
                    // Refresh reviews when the user pulls down the list
                    fetchReviews()
                }
            }
        }
        .onAppear {
            // Fetch reviews when the view appears
            fetchReviews()
        }
        .background(Color.white // <-- this is also a view
            .onTapGesture { // <-- add tap gesture to it
                UIApplication.shared.hideKeyboard() // Hide the keyboard when tapping outside
            })
    }

    /**
     Fetches the reviews for the current user from the backend.
     */
    private func fetchReviews() {
        // Check if user is authenticated, if not show error
        if userID == nil {
            if let currentUser = Auth.auth().currentUser {
                userID = currentUser.uid
            } else {
                print("Error: User not authenticated")
                errorMessage = "User not authenticated."
                return
            }
        }

        // Fetch reviews from the backend
        BarcodeItemService.shared.fetchReviewsByUserId(userId: userID!) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(reviews):
                    // On success, assign reviews to the state variables
                    self.reviews = reviews
                    print("[DEBUG] Fetch reviews for user \(userID!)")
                    shownReviews = reviews
                    isLoading = false
                case let .failure(error):
                    // On failure, display error message
                    print("[DEBUG] Error when fetching all reviews for user \(userID!) due to \(error.localizedDescription)")
                    isLoading = false
                }
            }
        }
    }

    /**
     Filters the reviews based on the search text entered by the user.
     */
    private func searchReviews(searchText: String) {
        if searchText == "" {
            // If the search is empty, show all reviews
            shownReviews = reviews
        } else {
            // Filter the reviews based on product name
            shownReviews = reviews.filter { $0.productName.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

#Preview {
    ReviewedItemsView()
}
