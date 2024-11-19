//
//  SearchResultView.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-11-17.
//

import SwiftUI
import MapKit

struct SearchResultView: View {
    @StateObject var viewModel: SearchResultViewModel
    
    var body: some View {
        NavigationStack {
            Map(selection: $viewModel.selection) {
                UserAnnotation()
                if !viewModel.mapAnnotations.isEmpty {
                    ForEach(viewModel.mapAnnotations) { annotation in
                        Annotation(annotation.title, coordinate: annotation.coordinate){
                            NavigationLink(destination: SearchResultDetailView(store: annotation.store!, deals: viewModel.deals)){
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
            .task {
                viewModel.requestLocationPermission()
                viewModel.fetchDeals()
            }
        }
    }
}

#Preview {
    SearchResultView(viewModel:SearchResultViewModel(searchText: "milk"))
}
