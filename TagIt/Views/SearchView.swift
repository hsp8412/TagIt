//
//  SearchView.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-07.
//

import SwiftUI

/**
 The view responsible for searching deals by item name. It provides a text field for the search input and a button to trigger the search.
 When a search is initiated, it navigates to the search results page.
 */
struct SearchView: View {
    // MARK: - Properties

    /// The view model responsible for managing the search text input.
    @StateObject var viewModel: SearchViewModel = .init()
    /// State to control whether the search results page is presented.
    @State private var isPresent: Bool = false
    /// State to control whether the warning message should be displayed if no search text is entered.
    @State private var showWarning: Bool = false

    // MARK: - View Body

    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    Color(UIColor(red: 242 / 255, green: 242 / 255, blue: 247 / 255, alpha: 1)) // Background color
                        .onTapGesture { // Dismiss keyboard when tapping outside
                            UIApplication.shared.hideKeyboard()
                        }

                    VStack {
                        // Gradient title
                        GradientTitle(
                            icon: "magnifyingglass.circle.fill",
                            text: "Search deals",
                            fontSize: 40,
                            color1: .green,
                            color2: .purple
                        )

                        // Form for searching
                        VStack(spacing: 20) {
                            VStack(alignment: .leading) {
                                // Label for item name
                                Text("Item Name")
                                    .padding(.horizontal, 40)
                                    .foregroundStyle(.green)

                                // Text field for search input
                                TextField("Item Name", text: $viewModel.searchText)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .padding(.horizontal, 40)
                                    .shadow(radius: 5)
                                    .autocapitalization(.none)

                                // Display warning if no text is entered
                                if showWarning {
                                    Text("Please enter the search text")
                                        .foregroundColor(.red)
                                        .padding(.horizontal, 40)
                                        .multilineTextAlignment(.leading)
                                }
                            }

                            // Search button
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
                SearchResultView(searchText: viewModel.searchText) // Navigate to search results
            }
        }
    }
}

#Preview {
    SearchView()
}
