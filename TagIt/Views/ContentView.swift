//
//  ContentView.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-09-21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView{
            VStack{
                TopNavView()
                TabView {
                    ItemTableView()
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                    
                    SearchView()
                        .tabItem {
                            Label("Search", systemImage: "tray.and.arrow.up.fill")
                        }
                    
                    NewDealView()
                        .tabItem {
                            Label("New Deal", systemImage: "plus.circle.fill")
                        }
                    
                    RankingView()
                        .tabItem {
                            Label("Ranking", systemImage: "chart.bar.fill")
                        }
                    
                    ProductsView()
                        .tabItem {
                            Label("Products", systemImage: "bag.fill")
                        }
                }
            }
        }
        
    }
}

#Preview{
    ContentView()
}
