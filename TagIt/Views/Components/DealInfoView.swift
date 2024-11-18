//
//  DealDetailView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-16.
//

import SwiftUI

struct DealInfoView: View {
    @State var deal: Deal
    @State var isLoading = true
    @State var user: UserProfile?
    @State private var errorMessage: String?

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.white
                .frame(maxWidth: .infinity)
                .frame(height: 250)
                .shadow(radius: 5)
            
            VStack (alignment: .leading) {
                HStack {
                    VStack (alignment: .leading) {

                        // Load User Profile
                        if (isLoading) {
                            ProgressView()
                                .frame(width: 40, height: 40)
                        } else if let errorMessage = errorMessage {
                            Text("Error: \(errorMessage)")
                        } else {
                            HStack {
                                UserAvatarView(avatarURL: user?.avatarURL ?? "")
                                    .frame(width: 40, height: 40)
                                
                                VStack (alignment: .leading) {
                                    Text(user?.displayName ?? "")
                                        .lineLimit(1)
                                    
                                    Text(deal.date)
                                }
                            }
                        }
                        
                        // Product Detail
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
                                .clipShape(.rect(cornerRadius: 25))
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
                    
                    // UpVote DownVote Button
                    // TAP STATUS NEED TO BE IMPLEMENTED
                    UpDownVoteView(type: .deal, id: deal.id!, upVote: deal.upvote, downVote: deal.downvote, upVoteTap: false, downVoteTap: false)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .padding(.horizontal)
            .onAppear() {
                fetchUserProfile()
            }
        }
    }
    
    // Function to fetch user profile
    private func fetchUserProfile() {
        isLoading = true
        if (deal.userID != "") {
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
}

#Preview {
    DealInfoView(
        deal: Deal(id: "DealID", userID: "1B7Ra3hPWbOVr2B96mzp3oGXIiK2", photoURL: "https://i.imgur.com/8ciNZcY.jpeg", productText: "Product Text", postText: "Post Text. Post Text. Post Text. Post Text. Post Text. Post Text.", price: 1.23, location: "Safeway", date: "2d", commentIDs: ["CommentID1", "CommentID2"], upvote: 5, downvote: 6)
    )
    
}
