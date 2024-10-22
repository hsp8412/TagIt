//
//  DealThreadsView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-21.
//


// NEED GETUSERBYID TO RETURN USERPROFILE
import SwiftUI

struct DealThreadsView: View {
    @State private var deals: [Deal] = []  // Empty deals array
    @State private var search: String = ""
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    
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
                    print("Searching \"\(search)\"")
                }
                
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

                if isLoading {
                    ProgressView("Loading deals...")
                } else if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                } else {
                    // Deals
                    ScrollView {
                        VStack(alignment: .leading, spacing: 30) {
                            ForEach(deals) { deal in
                                DealView(deal: deal)
                                    .background(.white)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .refreshable {
                        // Refresh the deal list
                        fetchDeals()
                    }
                }
            }
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

#Preview {
    DealThreadsView()
}
