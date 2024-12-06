//
//  DealCardView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-16.
//

import SwiftUI

/**
 A view that displays a deal card, including the user who posted the deal, the product details, price, location,
 and the number of comments. The card is tappable and navigates to the detailed deal view.
 */
struct DealCardView: View {
    // MARK: - Properties

    /// The deal to be displayed in the card.
    let deal: Deal
    /// State variable to track if the user profile is loading.
    @State var isLoading = true
    /// The user profile data associated with the deal.
    @State var user: UserProfile?
    /// Error message to be displayed in case of failure while fetching data.
    @State private var errorMessage: String?
    /// Tracks the number of comments for the deal.
    @State private var commentCount: Int = 0

    // MARK: - View Body

    var body: some View {
        NavigationLink(destination: DealDetailView(deal: deal)) {
            ZStack {
                Color.white
                    .cornerRadius(15) // Rounded corners for the card

                VStack(alignment: .leading, spacing: 10) {
                    // User Info Row with Price
                    HStack {
                        if isLoading {
                            ProgressView()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle()) // Show a loading indicator while fetching user profile
                        } else if let errorMessage {
                            Text("Error: \(errorMessage)")
                                .font(.caption)
                                .foregroundColor(.red)
                        } else {
                            HStack(spacing: 10) {
                                UserAvatarView(avatarURL: user?.avatarURL ?? "")
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle()) // User avatar

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(user?.displayName ?? "Unknown User")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.black)

                                    Text(deal.date)
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray) // Display the deal's date
                                }
                            }
                        }

                        Spacer()

                        // Price
                        Text(String(format: "$%.2f", deal.price))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.red) // Price displayed in red
                    }

                    Divider()
                        .background(Color.gray.opacity(0.5))

                    // Content Area
                    HStack(alignment: .top, spacing: 10) {
                        VStack(alignment: .leading, spacing: 8) {
                            // Product Text
                            Text(deal.productText)
                                .font(.headline)
                                .foregroundColor(.black)
                                .lineLimit(2) // Limit to 2 lines of text
                                .multilineTextAlignment(.leading)

                            Text("\"\(deal.postText)\"")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .italic()
                                .lineLimit(1) // Display post text in italic with a limit of one line

                            Spacer()

                            HStack(spacing: 5) {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundColor(.green) // Location icon
                                Text(deal.location)
                                    .font(.system(size: 14))
                                    .foregroundColor(.green) // Display deal location in green

                                Spacer()

                                // Comments Icon and Count
                                Image(systemName: "bubble.left.and.bubble.right")
                                    .foregroundColor(.gray) // Updated to gray
                                Text("\(commentCount)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray) // Updated to gray
                            }
                        }

                        Spacer()

                        // Product Image
                        AsyncImage(url: URL(string: deal.photoURL)) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100) // Slightly smaller image
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            } else {
                                ProgressView()
                                    .frame(width: 100, height: 100)
                                    .background(Color.gray.opacity(0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: 12)) // Loading placeholder for image
                            }
                        }
                    }
                }
                .padding(15) // Add consistent padding inside the card
            }
            .frame(maxWidth: .infinity) // Extend card horizontally
            .padding(.horizontal, 0) // Remove extra padding between cards
            .onAppear {
                fetchUserProfile() // Fetch the user profile when the view appears
                fetchCommentCount() // Fetch the number of comments for the deal
            }
        }
    }

    // MARK: - Helper Functions

    /**
     Fetches the user profile associated with the deal.
     This function is called to display the user information when the deal card appears.
     */
    private func fetchUserProfile() {
        isLoading = true
        if deal.userID != "" {
            UserService.shared.getUserById(id: deal.userID) { result in
                switch result {
                case let .success(fetchUserProfilebyID):
                    user = fetchUserProfilebyID
                    isLoading = false
                case let .failure(error):
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }

    /**
     Fetches the number of comments associated with the deal.
     This function updates the comment count on the deal card.
     */
    private func fetchCommentCount() {
        guard let dealId = deal.id else { return }

        CommentService.shared.getCommentsForItem(itemID: dealId) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(comments):
                    commentCount = comments.count // Update comment count
                case let .failure(error):
                    print("Error fetching comments for deal \(dealId): \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    DealCardView(
        deal: Deal(
            id: "1",
            userID: "1B7Ra3hPWbOVr2B96mzp3oGXIiK2",
            photoURL: "https://i.imgur.com/8ciNZcY.jpeg",
            productText: "Product Text",
            postText: "Post Text. Post Text. Post Text. Post Text.",
            price: 1.23,
            location: "Safeway",
            date: "2d",
            commentIDs: ["CommentID1", "CommentID2"],
            upvote: 5,
            downvote: 6
        )
    )
}
