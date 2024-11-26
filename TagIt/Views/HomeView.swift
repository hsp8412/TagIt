import SwiftUI
import SwiftUI

// Enum to represent the selected filter type
enum FilterType {
    case now
    case hot
    case nearby
}

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    @State private var search: String = ""
    @State private var selectedFilter: FilterType? = nil // Track the selected filter

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
                        .padding(.leading, 16)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            // Filter Buttons
                            ForEach(viewModel.filters) { filter in
                                FilterButton(icon: filter.icon, text: filter.label, isSelected: filter.isSelected) {
                                    viewModel.toggleFilter(id: filter.id)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 50)
                    }
                }
                
                Divider()
                    .padding(.horizontal)
                
                // Deals
                if viewModel.isLoading {
                    ProgressView("Loading deals...")
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .padding(.horizontal)
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
                    .padding(.top, 10)
                    .refreshable {
                        viewModel.fetchAllDeals()
                    }
                }
            }
            .padding(.bottom, 20)
            .onAppear {
                viewModel.fetchAllDeals()
            }
        }
    }
}

#Preview {
    HomeView()
}
