//
//  RankingView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-11-17.
//

import SwiftUI

struct RankingView: View {
    @State private var selected: Int = 0

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    // User
                    Button(action: {
                        withAnimation {
                            selected = 0
                        }
                    }) {
                        VStack {
                            Text("Users")
                                .foregroundColor(selected == 0 ? .blue : .gray)
                        }
                        
                    }
                    .frame(width: 100)
                    
                    // Product
                    Button(action: {
                        withAnimation {
                            selected = 1
                        }
                    }) {
                        VStack {
                            Text("Products")
                                .foregroundColor(selected == 1 ? .blue : .gray)
                        }
                    }
                    .frame(width: 100)
                }
                .frame(height: 35)
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .frame(height: 3)
                        .foregroundStyle(.gray.opacity(0.3)),
                    alignment: .bottom
                )
                .overlay(
                    GeometryReader { geometry in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.blue)
                            .frame(height: 3)
                            .frame(width: geometry.size.width / 2)
                            .offset(x: CGFloat(selected) * (geometry.size.width / 2))
                            .offset(y: 32)
                            .animation(.easeInOut(duration: 0.3), value: selected)
                    }
                )
                
                
                // Conditional rendering
                if (selected == 0) {
                    UserRankingView()
                } else {
                    DealRankingView()
                }
            }
        }
    }
}

#Preview {
    RankingView()
}
