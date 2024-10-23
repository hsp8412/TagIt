//
//  DealDetailView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-16.
//

// NEED GETUSERBYID TO RETURN USERPROFILE

import SwiftUI

struct DealInfoView: View {
    @State var deal: Deal
    let user: UserProfile = UserProfile(userId: "UID1", email: "user@example.com", displayName: "User Name", avatarURL: "https://i.imgur.com/8ciNZcY.jpeg")
    
    init(deal: Deal) {
        self.deal = deal
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.white
                .frame(maxWidth: .infinity)
                .frame(height: 250)
                .shadow(radius: 5)
            
            // Product Detail
            VStack (alignment: .leading) {
                HStack {
                    VStack (alignment: .leading) {
                        HStack {
                            if let avatarURL = user.avatarURL, let url = URL(string: avatarURL) {
                                AsyncImage(url: url) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                    } else {
                                        ProgressView()
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                    }
                                }
                            }
                            
                            VStack (alignment: .leading) {
                                Text(user.displayName)
                                    .lineLimit(1)
                                
                                Text(deal.date)
                            }
                        }
                        
                        Text(deal.productText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(String(format: "$%.2f", deal.price))
                    }
                    
                    AsyncImage(url: URL(string: deal.photoURL)) { image in
                        image.image?.resizable()
                    }
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(.rect(cornerRadius: 25))
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
                    
                    HStack {
                        
                        // Upvote and downvote button
                        // Need to be fully implemented
                        Button(action: {
                            print("Thumbsup Tapped")
                            deal.upvote = deal.upvote + 1
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.green)
                                    .frame(width: 100, height: 30)
                                
                                HStack {
                                    Image(systemName: "hand.thumbsup.fill")
                                        .foregroundStyle(Color.white)
                                    
                                    Text("\(deal.upvote)")
                                        .padding(.horizontal)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        
                        Button(action: {
                            print("Thumbsdown Tapped")
                            deal.downvote = deal.downvote + 1
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.red)
                                    .frame(width: 100, height: 30)
                                
                                HStack {
                                    Image(systemName: "hand.thumbsdown.fill")
                                        .foregroundStyle(Color.white)
                                    
                                    Text("\(deal.downvote)")
                                        .padding(.horizontal)
                                        .foregroundColor(.white)
                                }
                                
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    DealDetailView(
        deal: Deal(id: "DealID", userID: "UID1", photoURL: "https://i.imgur.com/8ciNZcY.jpeg", productText: "Product Text", postText: "Post Text. Post Text. Post Text. Post Text. Post Text. Post Text.", price: 1.23, location: "Safeway", date: "2d", commentIDs: ["CommentID1", "CommentID2"], upvote: 5, downvote: 6)
    )
    
}
