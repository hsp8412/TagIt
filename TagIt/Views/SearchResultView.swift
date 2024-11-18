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
        Map(){
            UserAnnotation()
            if viewModel.mapAnnotations.count>0 {
                ForEach(viewModel.mapAnnotations) { annotation in
                    Marker(annotation.title, coordinate: annotation.coordinate)
                }
            }
        }
        .task{
            viewModel.requestLocationPermission()
            viewModel.fetchDeals()
        }
    }
}


#Preview {
    SearchResultView(viewModel:SearchResultViewModel(searchText: "milk"))
}
