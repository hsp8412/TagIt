import SwiftUI

// Enum to represent the selected filter type
enum FilterType {
    case now
    case hot
    case nearby
}

/**
 `HomeView` displays the main screen where users can search for deals, filter deals by type, and view a list of deals.

 - The view includes a search bar for querying deals.
 - Users can apply filters like "Now," "Hot," and "Nearby" to narrow down the deals.
 - The deals are displayed in a scrollable list, and the view can show loading, error messages, or the actual deals.
 */
struct HomeView: View {
    @StateObject var viewModel = HomeViewModel() // ViewModel that manages the state and data for this view
    @State private var search: String = "" // Holds the text entered in the search bar
    @State private var selectedFilter: FilterType? = nil // Tracks the selected filter

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color.gray)
                        .padding(.leading)

                    TextField("Search", text: $search) // Binds search text to the viewModel
                        .autocapitalization(.none)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: 1)
                        .frame(height: 40)
                }
                .padding()
                .onSubmit {
                    print("Searching \"\(search)\"") // Debugging output
                    viewModel.fetchSearchDeals(searchText: search) // Trigger search query in the ViewModel
                }

                // Title aligned with buttons
                VStack(alignment: .leading, spacing: 5) {
                    Text("Fresh Finds Near You")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .padding(.leading, 16)

                    // Filter Buttons Section
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            // Display each filter as a button
                            ForEach(viewModel.filters) { filter in
                                FilterButton(icon: filter.icon, text: filter.label, isSelected: filter.isSelected) {
                                    viewModel.toggleFilter(id: filter.id) // Toggle filter selection
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 50)
                    }
                }

                Divider()
                    .padding(.horizontal)

                // Deals Section
                if viewModel.isLoading {
                    ProgressView("Loading deals...")
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)") // Display error if there's a problem fetching deals
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Show the deals when they're successfully fetched
                    ScrollView {
                        if viewModel.shownDeals.isEmpty {
                            Text("Sorry, there are no deals...")
                                .frame(maxHeight: .infinity)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                        } else {
                            VStack(alignment: .leading, spacing: 30) {
                                ForEach(viewModel.shownDeals) { deal in
                                    DealCardView(deal: deal) // Custom view to display deal information
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
                        viewModel.fetchAllDeals() // Refresh the deals list when pulled down
                    }
                }
            }
            .padding(.bottom, 20)
            .onAppear {
                viewModel.resetFilters() // Reset filters when the view appears
                viewModel.fetchAllDeals() // Fetch all deals initially
            }
            .background(Color.white // Hide keyboard when tapping outside of text fields
                .onTapGesture {
                    UIApplication.shared.hideKeyboard()
                })
        }
    }
}

#Preview {
    HomeView()
}
