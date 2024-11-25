//
//  SearchViewModel.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-29.
//

import Foundation
class SearchViewModel: ObservableObject{
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""
    
}
