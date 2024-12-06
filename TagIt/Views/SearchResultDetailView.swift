import SwiftUI

/**
 `SearchResultDetailView` displays a list of deals from a specific store.
 It filters and presents only the deals that belong to the selected store.
 */
struct SearchResultDetailView: View {
    var viewModel: SearchResultDetailViewModel

    // Initialize the view model with the store and filtered deals from the store
    init(store: Store, deals: [Deal]) {
        // Filter deals to only show those that belong to the current store
        func filterDealsByStore(storeId: String, deals: [Deal]) -> [Deal] {
            deals.filter { deal in
                if let locationId = deal.locationId {
                    return locationId == storeId
                }
                return false
            }
        }

        // Initialize the view model with the store and the filtered deals
        viewModel = SearchResultDetailViewModel(store: store, dealsFromStore: filterDealsByStore(storeId: store.id ?? "", deals: deals))
    }

    var body: some View {
        ZStack {
            Color(UIColor(red: 242 / 255, green: 242 / 255, blue: 247 / 255, alpha: 1)) // Background color
            VStack {
                // Title displaying the store name
                Text("Search Results from \"\(viewModel.store.name)\"")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                    .opacity(0.7)
                    .padding(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)

                // Scrollable view for the deals
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        // Loop through each deal and display them
                        ForEach(viewModel.dealsFromStore) { deal in
                            DealCardView(deal: deal) // Display deal card for each deal
                                .background(.white)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
        }
    }
}

#Preview {
    SearchResultDetailView(
        store: Store(
            id: "113", latitude: 112, longitude: -113, name: "Freshco"
        ), deals: [
            Deal(id: "DealID", userID: "1B7Ra3hPWbOVr2B96mzp3oGXIiK2", photoURL: "https://i.imgur.com/8ciNZcY.jpeg", productText: "Product Text", postText: "Post Text. Post Text. Post Text. Post Text. Post Text. Post Text.", price: 1.23, location: "Safeway", date: "2d", commentIDs: ["CommentID1", "CommentID2"], upvote: 5, downvote: 6),
            Deal(id: "DealID", userID: "1B7Ra3hPWbOVr2B96mzp3oGXIiK2", photoURL: "https://i.imgur.com/8ciNZcY.jpeg", productText: "Product Text", postText: "Post Text. Post Text. Post Text. Post Text. Post Text. Post Text.", price: 1.23, location: "Safeway", date: "2d", commentIDs: ["CommentID1", "CommentID2"], upvote: 5, downvote: 6),
            Deal(id: "DealID", userID: "1B7Ra3hPWbOVr2B96mzp3oGXIiK2", photoURL: "https://i.imgur.com/8ciNZcY.jpeg", productText: "Product Text", postText: "Post Text. Post Text. Post Text. Post Text. Post Text. Post Text.", price: 1.23, location: "Safeway", date: "2d", commentIDs: ["CommentID1", "CommentID2"], upvote: 5, downvote: 6),
            Deal(id: "DealID", userID: "1B7Ra3hPWbOVr2B96mzp3oGXIiK2", photoURL: "https://i.imgur.com/8ciNZcY.jpeg", productText: "Product Text", postText: "Post Text. Post Text. Post Text. Post Text. Post Text. Post Text.", price: 1.23, location: "Safeway", date: "2d", commentIDs: ["CommentID1", "CommentID2"], upvote: 5, downvote: 6),
            Deal(id: "DealID", userID: "1B7Ra3hPWbOVr2B96mzp3oGXIiK2", photoURL: "https://i.imgur.com/8ciNZcY.jpeg", productText: "Product Text", postText: "Post Text. Post Text. Post Text. Post Text. Post Text. Post Text.", price: 1.23, location: "Safeway", date: "2d", commentIDs: ["CommentID1", "CommentID2"], upvote: 5, downvote: 6),
        ]
    )
}
