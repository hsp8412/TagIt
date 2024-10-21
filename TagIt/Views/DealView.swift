//
//  DealView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-16.
//

// NEED GETUSERBYID TO RETURN USERPROFILE

import SwiftUI

struct DealView: View {
    let deal: Deal
    let user: UserProfile = UserProfile(userId: "UID1", email: "user@example.com", displayName: "User Name", avatarURL: "https://i.imgur.com/8ciNZcY.jpeg")
    
    var body: some View {
        NavigationLink(destination: DealDetailandCommentsView(deal: deal)) {
            ZStack {
                Color.white
                    .frame(height: 170)
                    .shadow(radius: 5)
                
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
                                    .foregroundColor(.black)
                                
                                Text(deal.date)
                                    .foregroundStyle(.black)
                            }
                        }
                        
                        Text(deal.productText)
                            .font(.system(size: 20))
                            .foregroundStyle(.black)
                            .bold()
                        
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
        }
    }
}


#Preview {
    DealView(
        deal: Deal(id: nil, userID: "UID1", photoURL: "https://i.imgur.com/8ciNZcY.jpeg", productText: "Product Text", postText: "Post Text. Post Text. Post Text. Post Text.", price: 1.23, location: "Safeway", date: "2d", commentIDs: ["CommentID1", "CommentID2"], upvote: 5, downvote: 6)
    )
}
