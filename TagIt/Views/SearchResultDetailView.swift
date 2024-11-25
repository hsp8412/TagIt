//
//  SearchResultDetailView.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-11-19.
//

import SwiftUI

struct SearchResultDetailView: View {
    var viewModel:SearchResultDetailViewModel
    
    init(store:Store, deals:[Deal]){
        func filterDealsByStore(storeId: String, deals: [Deal]) -> [Deal] {
            return deals.filter { deal in
                if let locationId = deal.locationId {
                    return locationId == storeId
                }
                return false
            }
        }
        
        self.viewModel = SearchResultDetailViewModel(store: store, dealsFromStore: filterDealsByStore(storeId: store.id ?? "", deals: deals))
    }
    
    var body: some View {
        ZStack{
            Color(UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1))
            VStack{
                Text("Search Results from \"\(viewModel.store.name)\"")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                    .opacity(0.7)
                    .padding(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                ScrollView() {
                    VStack(alignment: .leading, spacing: 30) {
                        ForEach(viewModel.dealsFromStore) { deal in
                            DealCardView(deal: deal)
                                .background(.white)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
        }
    }
}

#Preview {
    SearchResultDetailView(
        store: Store(
            id: "113", latitude: 112, longitude: -113, name: "Freshco"
        ), deals: [Deal(id: "DealID", userID: "1B7Ra3hPWbOVr2B96mzp3oGXIiK2", photoURL: "https://i.imgur.com/8ciNZcY.jpeg", productText: "Product Text", postText: "Post Text. Post Text. Post Text. Post Text. Post Text. Post Text.", price: 1.23, location: "Safeway", date: "2d", commentIDs: ["CommentID1", "CommentID2"], upvote: 5, downvote: 6),Deal(id: "DealID", userID: "1B7Ra3hPWbOVr2B96mzp3oGXIiK2", photoURL: "https://i.imgur.com/8ciNZcY.jpeg", productText: "Product Text", postText: "Post Text. Post Text. Post Text. Post Text. Post Text. Post Text.", price: 1.23, location: "Safeway", date: "2d", commentIDs: ["CommentID1", "CommentID2"], upvote: 5, downvote: 6), Deal(id: "DealID", userID: "1B7Ra3hPWbOVr2B96mzp3oGXIiK2", photoURL: "https://i.imgur.com/8ciNZcY.jpeg", productText: "Product Text", postText: "Post Text. Post Text. Post Text. Post Text. Post Text. Post Text.", price: 1.23, location: "Safeway", date: "2d", commentIDs: ["CommentID1", "CommentID2"], upvote: 5, downvote: 6), Deal(id: "DealID", userID: "1B7Ra3hPWbOVr2B96mzp3oGXIiK2", photoURL: "https://i.imgur.com/8ciNZcY.jpeg", productText: "Product Text", postText: "Post Text. Post Text. Post Text. Post Text. Post Text. Post Text.", price: 1.23, location: "Safeway", date: "2d", commentIDs: ["CommentID1", "CommentID2"], upvote: 5, downvote: 6),Deal(id: "DealID", userID: "1B7Ra3hPWbOVr2B96mzp3oGXIiK2", photoURL: "https://i.imgur.com/8ciNZcY.jpeg", productText: "Product Text", postText: "Post Text. Post Text. Post Text. Post Text. Post Text. Post Text.", price: 1.23, location: "Safeway", date: "2d", commentIDs: ["CommentID1", "CommentID2"], upvote: 5, downvote: 6)]
    )
}

