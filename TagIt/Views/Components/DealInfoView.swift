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
    @State var isSaved = false
    @State var user: UserProfile?
    @State private var profileErrorMessage: String?
    @State private var voteErrorMessage: String?
    @State private var currentUserId: String? = nil

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.white
                .frame(maxWidth: .infinity)
                .frame(height: 280)
                .shadow(radius: 5)
            
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading) {
                        // Load User Profile
                        if isLoading {
                            ProgressView()
                                .frame(width: 40, height: 40)
                        } else if let profileErrorMessage = profileErrorMessage {
                            Text("Error: \(profileErrorMessage)")
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
                            .frame(height: 50)
                            .bold()
                            .lineLimit(2)
                        
                        Text(String(format: "$%.2f", deal.price))
                            .bold()
                            .foregroundStyle(.red)
                            .frame(height: 20)
                    }
                    
                    VStack {
                        Button(action: {
                            saveDeal()
                        }) {
                            Text("Save")
                                .padding(.horizontal, 10)
                                .background(.white)
                                .foregroundColor(.green)
                                .frame(width: 90, height: 20)
                                .overlay() {
                                    if (isSaved) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.green)
                                            
                                            Text("Saved")
                                                .padding(.horizontal, 10)
                                                .foregroundColor(.white)
                                        }
                                    } else {
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.green, lineWidth: 1)
                                    }
                                }
                            
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
                }
                .padding(.top, 5)
                
                Text("\"" + deal.postText + "\"")
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 80, alignment: .top)
                
                HStack {
                    Image(systemName: "paperplane.fill")
                        .foregroundStyle(.green)
                    
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
                        self.profileErrorMessage = error.localizedDescription
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
            self.voteErrorMessage = "User not authenticated."
        }
    }
    
    // Save deal
    private func saveDeal() {
        isSaved.toggle()
        // Get saved status
        
        // Update saved db
    }
}

#Preview {
    DealInfoView(
        deal: .constant(
            Deal(
                id: "DealID",
                userID: "PtMxESE6kEONluP2QtWTAh7tWax2",
                photoURL: "https://i.imgur.com/8ciNZcY.jpeg",
                productText: "Product Text~~~~~~~~~~~~~~~~~~",
                postText: "Post Text. Post Text. Post Text. Post Text. Post Text. Post Text.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",
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
