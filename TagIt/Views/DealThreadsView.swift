//
//  DealThreadsView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-21.
//


// NEED GETUSERBYID TO RETURN USERPROFILE

import SwiftUI

struct DealThreadsView: View {
    @State var deals: [Deal] = [
        Deal(id: "DealID", userID: "UID1", photoURL: "https://i.imgur.com/8ciNZcY.jpeg", productText: "Product Text", postText: "Post Text. Post Text. Post Text. Post Text. Post Text. Post Text.", price: 1.23, location: "Safeway", date: "2d", commentIDs: ["CommentID1", "CommentID2"], upvote: 5, downvote: 6),
        Deal(id: "DealID", userID: "UID1", photoURL: "https://i.imgur.com/8ciNZcY.jpeg", productText: "Product Text", postText: "Post Text. Post Text. Post Text. Post Text. Post Text. Post Text.", price: 1.23, location: "Safeway", date: "2d", commentIDs: ["CommentID1", "CommentID2"], upvote: 5, downvote: 6),
        Deal(id: "DealID", userID: "UID1", photoURL: "https://i.imgur.com/8ciNZcY.jpeg", productText: "Product Text", postText: "Post Text. Post Text. Post Text. Post Text. Post Text. Post Text.", price: 1.23, location: "Safeway", date: "2d", commentIDs: ["CommentID1", "CommentID2"], upvote: 5, downvote: 6),
        Deal(id: "DealID", userID: "UID1", photoURL: "https://i.imgur.com/8ciNZcY.jpeg", productText: "Product Text", postText: "Post Text. Post Text. Post Text. Post Text. Post Text. Post Text.", price: 1.23, location: "Safeway", date: "2d", commentIDs: ["CommentID1", "CommentID2"], upvote: 5, downvote: 6),
        Deal(id: "DealID", userID: "UID1", photoURL: "https://i.imgur.com/8ciNZcY.jpeg", productText: "Product Text", postText: "Post Text. Post Text. Post Text. Post Text. Post Text. Post Text.", price: 1.23, location: "Safeway", date: "2d", commentIDs: ["CommentID1", "CommentID2"], upvote: 5, downvote: 6)
    ]
    @State var search: String = ""

    var body: some View {
        NavigationStack {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color.gray)
                        .padding(.leading)
                    
                    TextField("Search", text: $search)
                        .autocapitalization(.none)
                }
                .overlay() {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: 1)
//                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 40)
                }
                .padding()
                .onSubmit {
                    print("Searching \"\(search)\"")
                }
                
                // Filter
                // New to create a new view
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        Button(action: {
                            print("Filter Tapped")
                        }) {
                            Text("Today's Deals")
                                .padding(.horizontal,10)
                                .background(.white)
                                .foregroundColor(.green)
                                .overlay() {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.green, lineWidth: 1)
                                }
                        }
                        
                        Button(action: {
                            print("Filter Tapped")
                        }) {
                            Text("Hottest Deals")
                                .padding(.horizontal,10)
                                .background(.white)
                                .foregroundColor(.green)
                                .overlay() {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.green, lineWidth: 1)
                                }
                            
                        }
                    }
                }
                .frame(height: 30)
                .padding(.horizontal)
                
                // Title
                HStack {
                    Image(systemName: "sun.max.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30)
                        .foregroundStyle(.red)
                    

                    Text("HOT DEALS NEAR YOU")
                        .foregroundStyle(.red)
                        .font(.system(size: 30))
                        .bold()
                        .padding(.vertical)
                }

                // Deals
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        ForEach(deals) { deal in
                            DealView(deal: deal)
                                .background(.white)
                        }
                    }
                }
                .refreshable {
                    // Fetch Deals to update deals
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    DealThreadsView()
}
