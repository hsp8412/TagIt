//
//  ReviewCardView1.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-11-26.
//

import SwiftUI

struct ReviewCardView1: View {
    let review: BarcodeItemReview
    let date: String = "1h"
    let description: String = "abababbabababab"
    @State var isLoading = true
    @State var user: UserProfile?
    @State private var errorMessage: String?
    @State private var isPhotoExpanded: Bool = false

    var body: some View {
        ZStack {
            Color.white
                .cornerRadius(15) // Rounded corners, no shadow
            
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(review.productName)
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
                                        
                                        Text(date) // Assuming the review model has a `date` property
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
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
                    
                    // Product Image Section
                    AsyncImage(url: URL(string: review.photoURL)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .onTapGesture {
                                    isPhotoExpanded = true // Expand the photo on tap
                                }
                        } else {
                            ProgressView()
                                .frame(height: 150)
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                
                // Review Content
                VStack(alignment: .leading, spacing: 8) {
                    Text(description) // Review content
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


#Preview {
    ReviewCardView1(
        review: BarcodeItemReview(
            userID: "1B7Ra3hPWbOVr2B96mzp3oGXIiK2",
            photoURL: "https://i.imgur.com/8ciNZcY.jpeg",
            reviewStars: 4,
            productName: "Apple",
            barcodeNumber: "123456789012",
            reviewTitle: "The best apple ever",
            reviewText: "This is a great apple. It's so juicy and sweet."
        )
    )
}

