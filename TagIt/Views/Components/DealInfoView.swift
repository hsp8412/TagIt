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

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.white
                .frame(maxWidth: .infinity)
                .frame(height: 250)
                .shadow(radius: 5)
            
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading) {
                        // Load User Profile
                        if isLoading {
                            ProgressView()
                                .frame(width: 40, height: 40)
                        } else if let errorMessage = errorMessage {
                            Text("Error: \(errorMessage)")
                        } else {
                            HStack {
                                UserAvatarView(avatarURL: user?.avatarURL ?? "")
                                    .frame(width: 40, height: 40)
                                
                                VStack(alignment: .leading) {
                                    Text(user?.displayName ?? "")
                                        .lineLimit(1)
                                    
                                    Text(deal.date)
                                }
                            }
                        }
                        
                        // Product Details
                        Text(deal.productText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(String(format: "$%.2f", deal.price))
                    }
                    
                    AsyncImage(url: URL(string: deal.photoURL)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .clipShape(Rectangle())
                                .cornerRadius(25)
                        } else {
                            ProgressView()
                                .frame(width: 100, height: 100)
                                .cornerRadius(25)
                        }
                    }
                }
                .padding(.top, 5)
                
                Text("\"" + deal.postText + "\"")
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 80, alignment: .top)
                
                HStack {
                    Image(systemName: "mappin")
                    Text(deal.location)
                        .foregroundStyle(Color.green)
                    
                    Spacer()
                    
                    // UpVote DownVote Button
                    if let userId = currentUserId {
                        UpDownVoteView(
                            userId: userId,
                            type: .deal,
                            id: deal.id!,
                            upVote: $deal.upvote,  // Pass as a binding
                            downVote: $deal.downvote // Pass as a binding
                        )
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    } else {
                        ProgressView()
                            .onAppear {
                                fetchCurrentUserId()
                            }
                    }
                }
            }
            .padding(.horizontal)
            .onAppear {
                fetchUserProfile()
            }
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
