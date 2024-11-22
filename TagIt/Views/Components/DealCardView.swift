//
//  DealView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-16.
//
import SwiftUI

struct DealCardView: View {
    let deal: Deal
    @State var isLoading = true
    @State var user: UserProfile?
    @State private var errorMessage: String?
    @State private var commentCount: Int = 0 // Holds the number of comments for the deal

    var body: some View {
        NavigationLink(destination: DealDetailView(deal: deal)) {
            ZStack {
                Color.white
                    .cornerRadius(15) // Rounded corners, no shadow
                
                VStack(alignment: .leading, spacing: 10) {
                    // User Info Row with Price
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
                                    
                                    Text(deal.date)
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        // Price
                        Text(String(format: "$%.2f", deal.price))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.red)
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
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                            
                            Text("\"\(deal.postText)\"")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .italic()
                                .lineLimit(1)

                            Spacer()
                            
                            HStack(spacing: 5) {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundColor(.green)
                                Text(deal.location)
                                    .font(.system(size: 14))
                                    .foregroundColor(.green)
                                
                                Spacer()
                                
                                // Comments Icon and Count
                                Image(systemName: "bubble.left.and.text.bubble.right")
                                    .foregroundColor(.gray)
                                Text("\(commentCount)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray) 
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
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                }
                .padding(15) // Add consistent padding inside the card
            }
            .frame(maxWidth: .infinity) // Extend card horizontally
            .padding(.horizontal, 0) // Remove extra padding between cards
            .onAppear {
                fetchUserProfile()
                fetchCommentCount() // Fetch the number of comments for the deal
            }
        }
    }
    
    // Function to fetch user profile
    private func fetchUserProfile() {
        isLoading = true
        if deal.userID != "" {
            UserService.shared.getUserById(id: deal.userID) { result in
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
    
    // Function to fetch the number of comments for the deal
    private func fetchCommentCount() {
        guard let dealId = deal.id else { return }
        
        CommentService.shared.getCommentsForItem(itemID: dealId, commentType: .deal) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let comments):
                    self.commentCount = comments.count
                case .failure(let error):
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
