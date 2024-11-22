//
//  DealDetailView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-16.
//
import SwiftUI
import FirebaseAuth

struct DealInfoView: View {
    @Binding var deal: Deal
    @State var isLoading = true
    @State var user: UserProfile?
    @State private var errorMessage: String?
    @State private var currentUserId: String? = nil
    @State private var isPhotoExpanded: Bool = false // State to toggle photo expansion

    var body: some View {
        VStack(spacing: 15) {
            // Product Image Section
            AsyncImage(url: URL(string: deal.photoURL)) { phase in
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
                        .background(Color.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .frame(maxWidth: .infinity)

            Divider()
                .background(Color.gray.opacity(0.5))

            // User Info Section
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    if isLoading {
                        ProgressView()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    } else if let errorMessage = errorMessage {
                        Text("Error: \(errorMessage)")
                            .font(.caption)
                            .foregroundColor(.red)
                    } else {
                        UserAvatarView(avatarURL: user?.avatarURL ?? "")
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            Text(user?.displayName ?? "Unknown User")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Text(deal.date)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                }

                // Product Details Section
                VStack(alignment: .leading, spacing: 8) {
                    Text(deal.productText)
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    Text(String(format: "$%.2f", deal.price))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.red)
                }

                // Post Text
                Text("\"\(deal.postText)\"")
                    .italic()
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)

                // Location and Voting Section
                HStack {
                    HStack(spacing: 5) {
                        Image(systemName: "mappin")
                            .foregroundColor(.green)
                        Text(deal.location)
                            .font(.system(size: 14))
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    if let userId = currentUserId {
                        UpDownVoteView(
                            userId: userId,
                            type: .deal,
                            id: deal.id!,
                            upVote: $deal.upvote,
                            downVote: $deal.downvote
                        )
                    } else {
                        ProgressView()
                            .onAppear {
                                fetchCurrentUserId()
                            }
                    }
                }
            }
        }
        .padding(15)
        .background(
            Color.white
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 5)
        )
        .padding(.horizontal, 20)
        .onAppear {
            fetchUserProfile()
        }
        .fullScreenCover(isPresented: $isPhotoExpanded) {
            PhotoFullScreenView(imageURL: deal.photoURL, isPresented: $isPhotoExpanded)
        }
    }

    // Fetch the current user's profile
    private func fetchUserProfile() {
        isLoading = true
        if !deal.userID.isEmpty {
            UserService.shared.getUserById(id: deal.userID) { result in
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

    // Fetch the current user ID using Firebase Authentication
    private func fetchCurrentUserId() {
        if let currentUser = Auth.auth().currentUser {
            self.currentUserId = currentUser.uid
        } else {
            print("Error: User not authenticated")
            self.errorMessage = "User not authenticated."
        }
    }
}

// Full-Screen Photo View
struct PhotoFullScreenView: View {
    let imageURL: String
    @Binding var isPresented: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.edgesIgnoringSafeArea(.all)
            
            AsyncImage(url: URL(string: imageURL)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black)
                }
            }
            
            // Close Button
            Button(action: {
                isPresented = false
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 32))
                    .padding()
            }
        }
    }
}

#Preview {
    DealInfoView(
        deal: .constant(
            Deal(
                id: "DealID",
                userID: "1B7Ra3hPWbOVr2B96mzp3oGXIiK2",
                photoURL: "https://i.imgur.com/8ciNZcY.jpeg",
                productText: "Product Text",
                postText: "Post Text. Post Text. Post Text. Post Text. Post Text. Post Text.",
                price: 1.23,
                location: "Safeway",
                date: "2d",
                commentIDs: ["CommentID1", "CommentID2"],
                upvote: 5,
                downvote: 6
            )
        )
    )
}
