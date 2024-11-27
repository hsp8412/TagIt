//
//  ReviewCardView.swift
//  TagIt
//
//  Created by Angi Shi on 2024-11-24.
//

import SwiftUI
import FirebaseFirestore


struct ReviewCardView: View {
    let review: BarcodeItemReview
    @State var isLoading = true
    @State var user: UserProfile?
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color.white
                .cornerRadius(15)

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(review.reviewTitle)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)

                        // User Info Row
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            } else if let errorMessage = errorMessage {
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
                        }
                        HStack {
                            // Rating Display
                            HStack(spacing: 2) {
                                ForEach(0..<Int(review.reviewStars), id: \.self) { _ in
                                    Image(systemName: "star.fill")
                                        .resizable()
                                        .frame(width: 12, height: 12)
                                        .foregroundColor(.yellow)
                                }
                                ForEach(0..<(5 - Int(review.reviewStars)), id: \.self) { _ in
                                    Image(systemName: "star")
                                        .resizable()
                                        .frame(width: 12, height: 12)
                                        .foregroundColor(.gray)
                                }
                            }

                            Spacer()
                        }
                    }
                    .padding(.bottom, 10)

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
                        .frame(width: 90, height: 90)
                    }

                }

                // Review Content
                VStack(alignment: .leading, spacing: 8) {
                    Text(review.reviewText)
                        .font(.body)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(25)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 0)
        .onAppear {
            fetchUserProfile()
        }
    }

    // Function to fetch user profile
    private func fetchUserProfile() {
        isLoading = true
        if !review.userID.isEmpty {
            UserService.shared.getUserById(id: review.userID) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let fetchUserProfilebyID):
                        self.user = fetchUserProfilebyID
                        self.isLoading = false
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                        self.isLoading = false
                    }
                }
            }
        }
    }

    // Function to format Timestamp to String
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
            reviewText: "This product was amazing! High quality and exactly as described."
        )

        ReviewCardView(review: sampleReview)
    }
}
