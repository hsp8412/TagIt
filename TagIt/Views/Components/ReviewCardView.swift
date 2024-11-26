//
//  ReviewCardView.swift
//  TagIt
//
//  Created by Angi Shi on 2024-11-24.
//

import SwiftUI

struct Review: Identifiable {
    let id: String
    let userID: String
    let photoURL: String
    let reviewText: String
    let rating: Int
    let date: String
}

struct ReviewCardView: View {
    let review: Review
    @State var isLoading = true
    @State var user: UserProfile?
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color.white
                .cornerRadius(15) // Rounded corners, no shadow
            
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Review Title")
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
                                        
                                        Text(review.date) // Assuming the review model has a `date` property
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        HStack {
                            // Rating Display
                            HStack(spacing: 2) {
                                ForEach(0..<review.rating, id: \.self) { _ in
                                    Image(systemName: "star.fill")
                                        .resizable()
                                        .frame(width: 12, height: 12)
                                        .foregroundColor(.yellow)
                                }
                                ForEach(0..<(5 - review.rating), id: \.self) { _ in
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
                    
                    // Product Image
                    AsyncImage(url: URL(string: review.photoURL)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 90, height: 90) // Slightly smaller image
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
                
                // Review Content
                VStack(alignment: .leading, spacing: 8) {
                    Text(review.reviewText) // Review content
                        .font(.body)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                    
                }
            }
            .padding(25) // Add consistent padding inside the card
        }
        .frame(maxWidth: .infinity) // Extend card horizontally
        .padding(.horizontal, 0) // Remove extra padding between cards
        .onAppear {
            fetchUserProfile()
        }
    }
    
    // Function to fetch user profile
    private func fetchUserProfile() {
        isLoading = true
        if review.userID != "" {
            UserService.shared.getUserById(id: review.userID) { result in
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

#Preview{
    ReviewCardView(
        review: Review(
            id: "1",
            userID: "1B7Ra3hPWbOVr2B96mzp3oGXIiK2",
            photoURL: "https://i.imgur.com/8ciNZcY.jpeg",
            reviewText: "This product was amazing! High quality and exactly as described.",
            rating: 5,
            date: "2 days ago"
        )
    )
}
