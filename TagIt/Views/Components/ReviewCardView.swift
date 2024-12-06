//
//  ReviewCardView.swift
//  TagIt
//
//  Created by Angi Shi on 2024-11-24.
//

import FirebaseFirestore
import SwiftUI

/**
 A view that displays a review card, including user information, review text, rating, and optional image.
 The review text can be expanded or collapsed depending on its length.
 */
struct ReviewCardView: View {
    // MARK: - Properties

    /// The review to be displayed in the card.
    let review: BarcodeItemReview
    /// Indicates whether the user profile is being loaded.
    @State var isLoading = true
    /// The user profile data for the reviewer.
    @State var user: UserProfile?
    /// An error message to be displayed if fetching the user profile fails.
    @State private var errorMessage: String?
    /// Indicates whether the review text is expanded.
    @State private var isExpanded: Bool = false
    /// The maximum number of characters to display before truncating the review text.
    private let maxTextLength: Int = 200

    // MARK: - View Body

    var body: some View {
        ZStack {
            Color.white
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 5)

            VStack(alignment: .leading, spacing: 10) {
                // Header: User Info and Rating
                HStack {
                    if isLoading {
                        ProgressView()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    } else if let errorMessage {
                        Text("Error: \(errorMessage)")
                            .font(.caption)
                            .foregroundColor(.red)
                    } else {
                        HStack(spacing: 10) {
                            UserAvatarView(avatarURL: user?.avatarURL ?? "")
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(user?.displayName ?? "Unknown User")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black)

                                if let dateTime = review.dateTime {
                                    Text(formatTimestamp(dateTime))
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }

                    Spacer()

                    // Rating
                    HStack(spacing: 2) {
                        ForEach(0 ..< Int(review.reviewStars), id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .resizable()
                                .frame(width: 12, height: 12)
                                .foregroundColor(.yellow)
                        }
                        ForEach(0 ..< (5 - Int(review.reviewStars)), id: \.self) { _ in
                            Image(systemName: "star")
                                .resizable()
                                .frame(width: 12, height: 12)
                                .foregroundColor(.gray)
                        }
                    }
                }

                Divider()
                    .background(Color.gray.opacity(0.5))

                // Content Area: Review Text and Image
                HStack(alignment: .top, spacing: 10) {
                    VStack(alignment: .leading, spacing: 8) {
                        // Title
                        Text(review.reviewTitle)
                            .font(.headline)
                            .foregroundColor(.black)
                            .lineLimit(2)

                        // Expandable Review Text
                        if isExpanded || review.reviewText.count <= maxTextLength {
                            Text(review.reviewText)
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                        } else {
                            Text(String(review.reviewText.prefix(maxTextLength)) + "...")
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                        }

                        // Show More / Show Less Button
                        if review.reviewText.count > maxTextLength {
                            Button(action: {
                                withAnimation {
                                    isExpanded.toggle()
                                }
                            }) {
                                Text(isExpanded ? "Show Less" : "Show More")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.blue)
                            }
                        }
                    }

                    Spacer()

                    // Review Image (if available)
                    if !review.photoURL.isEmpty {
                        AsyncImage(url: URL(string: review.photoURL)) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 90, height: 90)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            } else {
                                ProgressView()
                                    .frame(width: 90, height: 90)
                                    .background(Color.gray.opacity(0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                }
            }
            .padding(15)
            .frame(minHeight: 150) // Set a consistent minimum height for all cards
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 10)
        .onAppear {
            fetchUserProfile()
        }
    }

    // MARK: - Helper Functions

    /**
     Fetches the user profile associated with the review's user ID.

     This function is called when the view appears to retrieve the reviewer’s profile.
     */
    private func fetchUserProfile() {
        isLoading = true
        if !review.userID.isEmpty {
            UserService.shared.getUserById(id: review.userID) { result in
                DispatchQueue.main.async {
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
    }

    /**
     Formats a Firebase Timestamp to a readable string.

     - Parameter timestamp: The Firebase Timestamp to format.
     - Returns: A formatted string representing the timestamp.
     */
    private func formatTimestamp(_ timestamp: Timestamp) -> String {
        let date = timestamp.dateValue()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ReviewCardView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleReview = BarcodeItemReview(
            id: "1",
            userID: "1B7Ra3hPWbOVr2B96mzp3oGXIiK2",
            photoURL: "https://i.imgur.com/8ciNZcY.jpeg",
            reviewStars: 5,
            productName: "Sample Product",
            barcodeNumber: "1234567890123",
            dateTime: Timestamp(),
            reviewTitle: "Great product!",
            reviewText: "This product was amazing! High quality and exactly as described. I loved every bit of it and would highly recommend it to anyone looking for a similar item."
        )

        ReviewCardView(review: sampleReview)
    }
}
