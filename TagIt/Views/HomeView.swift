//
//  DealThreadsView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-21.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    @State private var search: String = ""
    
    @State var button1_tap: Bool = false
    @State var button2_tap: Bool = false
    @State var button3_tap: Bool = false
    
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
                        .frame(height: 40)
                }
                .padding()
                .onSubmit {
                    viewModel.fetchSearchDeals(searchText: search)
                }
                
                // Filter
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        Button(action: {
                            button1_tap.toggle()
                            button2_tap = false
                            button3_tap = false
                            viewModel.fetchTodaysDeals()
                        }) {
                            Text("Today's Deals")
                                .padding(.horizontal,10)
                                .background(.white)
                                .foregroundColor(.green)
                                .overlay() {
                                    if (button1_tap) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.green)
                                            
                                            Text("Today's Deals")
                                                .padding(.horizontal,10)
                                                .foregroundColor(.white)
                                        }
                                    } else {
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.green, lineWidth: 1)
                                    }
                                }
                        }
                        
                        Button(action: {
                            button1_tap = false
                            button2_tap.toggle()
                            button3_tap = false
                            viewModel.fetchHottestDeals()
                        }) {
                            Text("Hottest Deals")
                                .padding(.horizontal,10)
                                .background(.white)
                                .foregroundColor(.green)
                                .overlay() {
                                    if (button2_tap) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.green)
                                            
                                            Text("Hottest Deals")
                                                .padding(.horizontal,10)
                                                .foregroundColor(.white)
                                        }
                                    } else {
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.green, lineWidth: 1)
                                    }
                                }
                            
                        }
                        
                        Button(action: {
                            button1_tap = false
                            button2_tap = false
                            button3_tap.toggle()
                            viewModel.fetchDealsClosedTo()
                        }) {
                            Text("Deals Closed to You")
                                .padding(.horizontal,10)
                                .background(.white)
                                .foregroundColor(.green)
                                .overlay() {
                                    if (button3_tap) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.green)
                                            
                                            Text("Deals Closed to You")
                                                .padding(.horizontal,10)
                                                .foregroundColor(.white)
                                        }
                                    } else {
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.green, lineWidth: 1)
                                    }
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
                if viewModel.isLoading {
                    ProgressView("Loading deals...")
                        .frame(maxHeight: .infinity)
                } else if viewModel.errorMessage != nil {
                    Text("Error: \(viewModel.errorMessage!)")
                } else {
                    if (viewModel.shownDeals.isEmpty) {
                        Text("Sorry, there is no deals...")
                            .frame(maxHeight: .infinity)
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 30) {
                                ForEach(viewModel.shownDeals) { deal in
                                    DealCardView(deal: deal)
                                        .background(.white)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .refreshable {
                            // Refresh the deal list
                            viewModel.fetchAllDeals()
                        }
                    }
                }
            }
            .onAppear {
                // Fetch deals when the view appears
                viewModel.fetchAllDeals()
            }
        }
    }
}

#Preview {
    HomeView()
}
