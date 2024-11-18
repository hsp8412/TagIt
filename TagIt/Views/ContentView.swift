//
//  ContentView.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-09-21.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0
    var body: some View {
        NavigationView{
            VStack{
                TopNavView()
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }.tag(0)
                    
                    SearchView()
                        .tabItem {
                            Label("Search", systemImage: "tray.and.arrow.up.fill")
                        }.tag(1)
                    
                    NewDealView(selectedTab: $selectedTab)
                        .tabItem {
                            Label("New Deal", systemImage: "plus.circle.fill")
                        }.tag(2)
                    
                    RankingView()
                        .tabItem {
                            Label("Ranking", systemImage: "chart.bar.fill")
                        }.tag(3)
                    
                    ProductsView()
                        .tabItem {
                            Label("Products", systemImage: "bag.fill")
                        }.tag(4)
                }
            }
        }
        
    }
}

#Preview{
    ContentView()
}
