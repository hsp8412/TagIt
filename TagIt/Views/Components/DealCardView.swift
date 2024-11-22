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
    
    var body: some View {
        NavigationLink(destination: DealDetailView(deal: deal)) {
            ZStack {
                Color.white
                    .frame(height: 220)
                    .shadow(radius: 5)
                
                HStack {
                    VStack(alignment: .leading) {
                        
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
                                
                                VStack(alignment: .leading) {
                                    Text(user?.displayName ?? "")
                                        .lineLimit(1)
                                        .foregroundColor(.black)
                                    
                                    Text(deal.date)
                                        .foregroundStyle(.black)
                                }
                            }
                        }
                        
                        // Product Details
                        Text(deal.productText)
                            .font(.system(size: 20))
                            .foregroundStyle(.black)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .bold()
                            .frame(height: 50)
                        
                        Text(String(format: "$%.2f", deal.price))
                            .font(.system(size: 20))
                            .foregroundStyle(.red)
                            .bold()
                        
                        HStack(spacing: 0) {
                            Text("\"")
                                .foregroundStyle(.black)
                            Text(deal.postText)
                                .foregroundStyle(.black)
                                .lineLimit(1)
                                .italic()
                            Text("\"")
                                .foregroundStyle(.black)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            Image(systemName: "paperplane.fill")
                                .foregroundStyle(.green)

                            Text(deal.location)
                                .foregroundStyle(.green)
                        }
                    }
                    
                    AsyncImage(url: URL(string: deal.photoURL)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .cornerRadius(25)
                        } else {
                            ProgressView()
                                .frame(width: 120, height: 120)
                                .cornerRadius(25)
                        }
                    }
                }
            }
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
    DealCardView(
        deal: Deal(id: nil, userID: "1B7Ra3hPWbOVr2B96mzp3oGXIiK2", photoURL: "https://i.imgur.com/8ciNZcY.jpeg", productText: "Product Text~~~~~~~~~~~~~~~~~~~~~~~~", postText: "Post Text. Post Text. Post Text. Post Text.", price: 1.23, location: "Safeway", date: "2d", commentIDs: ["CommentID1", "CommentID2"], upvote: 5, downvote: 6)
    )
}
