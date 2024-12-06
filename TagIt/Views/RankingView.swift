//
//  RankingView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-11-17.
//

import SwiftUI

/**
 The view that displays ranking information. It allows users to toggle between viewing the "User" rankings
 and the "Product" (Deal) rankings. A tab-like interface is used to switch between the two views.
 */
struct RankingView: View {
    // MARK: - Properties

    /// The selected tab index, determining whether to show User rankings or Product (Deal) rankings.
    @State private var selected: Int = 0

    // MARK: - View Body

    var body: some View {
        NavigationStack {
            VStack {
                // Tab Buttons for User and Product Rankings
                HStack {
                    // User Rankings Button
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

                    // Product Rankings Button
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

                // Conditional rendering based on selected tab
                if selected == 0 {
                    UserRankingView() // Show User Ranking
                } else {
                    DealRankingView() // Show Product (Deal) Ranking
                }
            }
        }
    }
}

#Preview {
    RankingView()
}
