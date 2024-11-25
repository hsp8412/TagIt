import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    @State private var search: String = ""
    
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
                    viewModel.fetchSearchDeals(searchText: search)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    // Title aligned with buttons
                    Text("Fresh Finds Near You")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .padding(.leading, 16) // Match this with ScrollView's padding below
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            // Filter Buttons
                            FilterButton(icon: "sparkles", text: "Now", tapped: $viewModel.todaysDeal) {
                                viewModel.todaysDeal.toggle()
                                viewModel.fetchTodaysDeals()
                            }
                            FilterButton(icon: "mappin", text: "Nearby", tapped: $viewModel.nearbyDeal) {
                                viewModel.nearbyDeal.toggle()
                                viewModel.fetchNearbyDeals()
                            }
                            FilterButton(icon: "flame.fill", text: "Hot", tapped: $viewModel.hotDeal) {
                                viewModel.hotDeal.toggle()
                                viewModel.fetchHottestDeals()
                            }
                        }
                        .padding(.horizontal, 16) // Ensure this matches the leading padding of Text
                        .frame(height: 50)
                    }
                }
                
                Divider()
                    .padding(.horizontal)
                
                // Deals
                if viewModel.isLoading {
                    ProgressView("Loading deals...")
                        .padding(.top, 20) // Added top padding for spacing
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .padding(.horizontal) // Added horizontal padding for better alignment
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        if viewModel.shownDeals.isEmpty {
                            Text("Sorry, there are no deals...")
                                .frame(maxHeight: .infinity)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                        } else {
                            VStack(alignment: .leading, spacing: 30) {
                                ForEach(viewModel.shownDeals) { deal in
                                    DealCardView(deal: deal)
                                        .background(Color.white)
                                        .cornerRadius(15)
                                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                        .padding(.horizontal)
                                }
                            }
                        }

                    }
                    .padding(.top, 10) // Added top padding for spacing
                    .refreshable {
                        // Refresh the deal list
                        viewModel.fetchAllDeals()
                    }
                }
            }
            .padding(.bottom, 20) // Added bottom padding to ensure content doesn’t touch the bottom edge
            .onAppear {
                // Fetch deals when the view appears
                viewModel.fetchAllDeals()
            }
        }
    }
}

struct FilterButton: View {
    var icon: String
    var text: String
    @Binding var tapped: Bool
    var action: () -> Void // Add action callback
    
    var body: some View {
        Button(action: action) { // Call the action when tapped
            HStack {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundColor(tapped ? .white : .black)
                
                Text(text)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(tapped ? .white : .black)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(tapped ? Color.green.opacity(1.0) : Color.white.opacity(1.0), lineWidth: 2) // Soft white outline
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(tapped ? Color.green : Color.white) // Consistent white background
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2) // Subtle shadow
            )
        }
    }
}

#Preview {
    HomeView()
}
