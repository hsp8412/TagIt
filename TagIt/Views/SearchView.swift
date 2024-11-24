//
//  SearchView.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-07.
//

import SwiftUI

struct SearchView: View {
    @StateObject var viewModel: SearchViewModel = SearchViewModel()
    @State private var isPresent: Bool = false
    @State private var showWarning: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    Color(UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1))
                    VStack {
                        GradientTitle(
                            icon: "magnifyingglass.circle.fill",
                            text: "Search deals",
                            fontSize: 40,
                            color1: .green,
                            color2: .purple
                        )
                        
                        // Form
                        VStack(spacing: 20) {
                            VStack(alignment: .leading) {
                                Text("Item Name")
                                    .padding(.horizontal, 40)
                                    .foregroundStyle(.green)
                                TextField("Item Name", text: $viewModel.searchText)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .padding(.horizontal, 40)
                                    .shadow(radius: 5)
                                    .autocapitalization(.none)
                                if showWarning {
                                    Text("Please enter the search text")
                                        .foregroundColor(.red)
                                        .padding(.horizontal, 40)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                            
                            Button(action: {
                                if !viewModel.searchText.isEmpty {
                                    showWarning = false
                                    isPresent = true
                                } else {
                                    showWarning = true
                                }
                            }) {
                                Text("Search")
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 15)
                                    .background(.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(25)
                            }
                            .padding(.top, 20)
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $isPresent) {
                SearchResultView(searchText: viewModel.searchText)
            }
        }
    }
}

#Preview {
    SearchView()
}
