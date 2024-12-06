//
//  ContentView.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-09-21.
//

import SwiftUI

/**
 The main content view that holds the navigation and tab view for the app.
 It contains a `TopNavView` and a `TabView` with multiple tabs including Home, Search, New Deal, Ranking, and My Deals.
 */
struct ContentView: View {
    // MARK: - Properties

    /// The selected tab index for the TabView.
    @State private var selectedTab: Int = 0

    // MARK: - View Body

    var body: some View {
        NavigationView {
            VStack {
                TopNavView() // Navigation bar at the top
                TabView(selection: $selectedTab) {
                    // Home View Tab
                    HomeView()
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                        .tag(0)

                    // Search View Tab
                    SearchView()
                        .tabItem {
                            Label("Search", systemImage: "tray.and.arrow.up.fill")
                        }
                        .tag(1)

                    // New Deal View Tab
                    NewDealView(selectedTab: $selectedTab)
                        .tabItem {
                            Label("New Deal", systemImage: "plus.circle.fill")
                        }
                        .tag(2)

                    // Ranking View Tab
                    RankingView()
                        .tabItem {
                            Label("Ranking", systemImage: "chart.bar.fill")
                        }
                        .tag(3)

                    // My Deals View Tab
                    ProductsView()
                        .tabItem {
                            Label("My Deals", systemImage: "cart.fill")
                        }
                        .tag(4)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
