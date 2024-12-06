//
//  SearchViewModel.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-29.
//

import Foundation

/**
 ViewModel responsible for managing the search functionality, including handling
 the search input and tracking the loading state during search operations.
 */
class SearchViewModel: ObservableObject {
    /// Indicates whether a search operation is in progress.
    @Published var isLoading: Bool = false
    /// The text input for the search query.
    @Published var searchText: String = ""
}
