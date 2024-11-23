//
//  DealThreadsView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-21.
//

import SwiftUI
struct HomeView: View {
    @State private var deals: [Deal] = []  // Empty deals array
    @State private var search: String = ""
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color.gray)
                        .padding(.leading)
                    
                    TextField("Search", text: $search)
                        .autocapitalization(.none)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: 1)
                        .frame(height: 40)
                }
                .padding()
                .onSubmit {
                    print("Searching \"\(search)\"")
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    // Title aligned with buttons
                    Text("Fresh Finds Near You")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .padding(.leading, 16) // Match this with ScrollView's padding below
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            FilterButton(icon: "sparkles", text: "Now")
                            FilterButton(icon: "mappin", text: "Nearby")
                        }
                        .padding(.horizontal, 16) // Ensure this matches the leading padding of Text
                        .frame(height: 50)
                    }
                }
                
                Divider()
                    .padding(.horizontal)
                
                // Deals
                if isLoading {
                    ProgressView("Loading deals...")
                        .padding(.top, 20) // Added top padding for spacing
                } else if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .padding(.horizontal) // Added horizontal padding for better alignment
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 30) {
                            ForEach(deals) { deal in
                                DealCardView(deal: deal)
                                    .background(Color.white)
                                    .cornerRadius(15) // Added rounded corners for a cleaner look
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2) // Subtle shadow
                                    .padding(.horizontal) // Added padding to avoid touching screen edges
                            }
                        }
                    }
                    .padding(.top, 10) // Added top padding for spacing
                    .refreshable {
                        // Refresh the deal list
                        fetchDeals()
                    }
                }
            }
            .padding(.bottom, 20) // Added bottom padding to ensure content doesn’t touch the bottom edge
            .onAppear {
                // Fetch deals when the view appears
                fetchDeals()
            }
        }
    }

    
    // Function to fetch deals
    private func fetchDeals() {
        isLoading = true
        DealService.shared.getDeals { result in
            switch result {
            case .success(let fetchedDeals):
                self.deals = fetchedDeals
                self.isLoading = false
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}


struct FilterButton: View {
    var icon: String
    var text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
                .foregroundColor(.black)
            
            Text(text)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.white.opacity(1.0), lineWidth: 2) // Soft white outline
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white) // Consistent white background
                )
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2) // Subtle shadow
        )
    }
}

#Preview {
    HomeView()
}
