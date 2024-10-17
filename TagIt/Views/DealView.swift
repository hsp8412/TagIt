//
//  DealView.swift
//  TagIt
//
//  Created by Iris Chao on 2024-10-16.
//

import SwiftUI

struct DealView: View {
    let deal: Deal
    let user: UserProfile
    
    var body: some View {
        NavigationLink(destination: DealDetailView(deal: deal, user: user)) {
            HStack {
                VStack(alignment: .leading) {
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
                        
                        VStack(alignment: .leading) {
                            Text(user.displayName)
                                .lineLimit(1)
                            
                            Text(deal.date)
                        }
                    }
                    
                    Text(deal.productText)
                    
                    Text(String(format: "$%.2f", deal.price))
                    
                    HStack(spacing: 0) {
                        Text("\"")
                        Text(deal.postText)
                            .lineLimit(1)
                            .italic()
                        Text("\"")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Image(systemName: "mappin")
                        Text(deal.location)
                            .foregroundColor(.green)
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
    }
}


#Preview {
    DealView(
        deal: Deal(id: nil, userID: "UID1", photoURL: "https://i.imgur.com/8ciNZcY.jpeg", productText: "Product Text", postText: "Post Text. Post Text. Post Text. Post Text.", price: 1.23, location: "Safeway", date: "2d", commentIDs: ["CommentID1", "CommentID2"], upvote: 5, downvote: 6),
        user: UserProfile(userId: "UID1", email: "user@example.com", displayName: "User Name", avatarURL: nil)
    )
}
