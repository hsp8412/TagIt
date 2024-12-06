import MapKit
import SwiftUI

/**
 `SearchResultView` displays the search results based on a user's query.
 It shows relevant tags, deals, and their locations on a map.
 */
struct SearchResultView: View {
    @StateObject private var locationManager = LocationManager() // Manages user location
    @StateObject var viewModel: SearchResultViewModel // ViewModel to handle data fetching and state

    @State private var showAlert = false // Controls the display of alert when no deals are found

    // Initialize the view model with search text and location manager
    init(searchText: String) {
        let locationManager = LocationManager()
        _viewModel = StateObject(wrappedValue: SearchResultViewModel(searchText: searchText, locationManager: locationManager))
    }

    var body: some View {
        NavigationStack {
            if viewModel.loading {
                // Show loading indicator while deals are being fetched
                ProgressView("Loading Deals...")
                    .task {
                        locationManager.requestLocationPermission() // Request location permissions
                        await viewModel.fetchDeals() // Fetch deals based on search text
                        if !viewModel.hasDeals {
                            showAlert = true // Show alert if no deals are found
                        }
                    }
            } else {
                // Content view when loading is done
                VStack(spacing: 0) {
                    // Header with search query and tag filters
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Search Results for \"\(viewModel.searchText)\"")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                            .opacity(0.7)
                            .padding(.leading, 16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top)

                        // Filter tags displayed horizontally
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(viewModel.tags, id: \.label) { tag in
                                    let isSelected = viewModel.selectedTag?.value == tag.value
                                    Text(tag.label)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                                        .foregroundColor(isSelected ? .white : .black)
                                        .cornerRadius(16)
                                        .onTapGesture {
                                            // Toggle selection of tags
                                            if isSelected {
                                                viewModel.selectedTag = nil
                                            } else {
                                                viewModel.selectedTag = tag
                                            }
                                            viewModel.applyFilters() // Apply filter when tag is selected/deselected
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    Spacer()

                    // Display deals on a map if available
                    if viewModel.hasDeals {
                        Map(position: $viewModel.position) {
                            UserAnnotation() // Show user's location annotation

                            // Show annotations for each deal on the map
                            ForEach(viewModel.mapAnnotations) { annotation in
                                Annotation(annotation.title, coordinate: annotation.coordinate) {
                                    NavigationLink(destination: SearchResultDetailView(store: annotation.store!, deals: viewModel.deals)) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 5)
                                                .fill(Color.teal)
                                            Text("🥕")
                                                .padding(5)
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        // Show message if no deals found
                        Text("No deals found for \"\(viewModel.searchText)\".")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
            }
        }
    }
}

#Preview {
    SearchResultView(searchText: "milk")
}
