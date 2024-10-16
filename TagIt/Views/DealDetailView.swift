//
//  DealDetailView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-16.
//

import SwiftUI

struct DealDetailView: View {
    let deal: Deal
    let user: UserProfile
    
    init(deal: Deal, user: UserProfile) {
        self.deal = deal
        self.user = user
//        self.user = findUserByID(id: deal.userID)!
    }

    var body: some View {
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
            
            Text("\"" + deal.postText + "\"")
                .italic()
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                Image(systemName: "mappin")
                Text(deal.location)
                    .foregroundStyle(Color.green)
                
                HStack {
                    Image(systemName: "hand.thumbsup")
                    Text("\(deal.upvote)")
                    
                    Image(systemName: "hand.thumbsdown")
                    Text("\(deal.downvote)")
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding()
        .navigationTitle(deal.id!)
    }
}

#Preview {
    DealDetailView(
        deal: Deal(id: "DealID", userID: "UID1", photoURL: "https://i.imgur.com/8ciNZcY.jpeg", productText: "Product Text", postText: "Post Text. Post Text. Post Text. Post Text. Post Text. Post Text.", price: 1.23, location: "Safeway", date: "2d", commentIDs: ["CommentID1", "CommentID2"], upvote: 5, downvote: 6),
        user: UserProfile(userId: "UID1", email: "user@example.com", displayName: "User Name", avatarURL: nil)
    )
    
}
