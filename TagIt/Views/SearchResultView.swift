//
//  SearchResultView.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-11-17.
//

import SwiftUI
import MapKit

struct SearchResultView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject var viewModel: SearchResultViewModel
    
    //    @Environment(\.dismiss) private var dismiss // Environment to handle navigation back
    @State private var showAlert = false // State to control the alert display
    
    init(searchText: String) {
        let locationManager = LocationManager()
        _viewModel = StateObject(wrappedValue: SearchResultViewModel(searchText: searchText, locationManager: locationManager))
    }
    
    var body: some View {
        NavigationStack {
            
            if viewModel.loading {
                ProgressView("Loading Deals...")
                    .task {
                        locationManager.requestLocationPermission()
                        await viewModel.fetchDeals()
                        if !viewModel.hasDeals {
                            showAlert = true
                        }
                    }
            } else {
                VStack(spacing: 0){
                    VStack(alignment: .leading, spacing: 8){
                        Text("Search Results for \"\(viewModel.searchText)\"")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                            .opacity(0.7)
                            .padding(.leading, 16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top)
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
                                            // Toggle selection
                                            if isSelected {
                                                viewModel.selectedTag = nil
                                            } else {
                                                viewModel.selectedTag = tag
                                            }
                                            viewModel.applyFilters()
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    Spacer()
                    if viewModel.hasDeals {
                        Map(position: $viewModel.position) {
                            UserAnnotation()
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
                        
                    }
                    else {
                        Text("No deals found for \"\(viewModel.searchText)\".") // Fallback UI (in case the alert is dismissed)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
            }
        }.onAppear{
//            viewModel.locationManager.requestLocationPermission()
        }
    }
}

#Preview {
    SearchResultView(searchText: "milk")
}
