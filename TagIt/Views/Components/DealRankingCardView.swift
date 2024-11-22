//
//  ProductRankingCardView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-11-18.
//

import SwiftUI

struct DealRankingCardView: View {
    let rank: Int
    let deal: Deal
    let fontSize: CGFloat

    var body: some View {
        NavigationLink(destination: DealDetailView(deal: deal)) {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 20)
                    .frame(height: fontSize*7)
                    .foregroundStyle(.white)
                    .shadow(radius: 5)
                
                HStack {
                    // Rank
                    Text("\(rank)")
                        .font(.system(size: fontSize*2, weight: .bold))
                        .foregroundStyle(.clear)
                        .padding(.horizontal)
                        .overlay(
                            LinearGradient(colors: [.yellow, .orange, .red], startPoint: .top, endPoint: .bottom)
                                .mask(
                                    Text("\(rank)")
                                        .font(.system(size: fontSize*2, weight: .bold))
                                )
                        )
                    
                    // Deal
                    VStack (alignment: .leading) {
                        Text(deal.productText)
                            .font(.custom("Gill Sans", size: fontSize))
                            .foregroundStyle(.black)
                            .multilineTextAlignment(.leading)
                            .frame(height: fontSize*4.5)
                            .padding(.leading, 5)
                            .lineLimit(3)
                        
                        // Location
                        HStack {
                            Image(systemName: "paperplane.fill")
                                .foregroundStyle(.green)
                            
                            Text(deal.location)
                                .font(.custom("Gill Sans", size: fontSize*0.8))
                                .foregroundStyle(.green)
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    
                    // Photo
                    AsyncImage(url: URL(string: deal.photoURL)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .cornerRadius(35)
                        } else {
                            ProgressView()
                                .frame(width: 100, height: 100)
                                .cornerRadius(25)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.trailing)
            }
        }
    }
}

#Preview {
    DealRankingCardView(rank: 1, deal: Deal(userID: "123", photoURL: "https://i.imgur.com/8ciNZcY.jpeg", productText: "Tropicana Orange Juice", postText: "", price: 1.23, location: "Safeway", date: "", commentIDs: [], upvote: 5, downvote: 6), fontSize: 25)
}
