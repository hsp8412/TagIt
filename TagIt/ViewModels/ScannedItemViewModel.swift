//
//  ScannedItemViewModel.swift
//  TagIt
//
//  Created by Angi Shi on 2024-11-24.
//

import Foundation
import FirebaseFirestore
class ScannedItemViewModel: ObservableObject {
    @Published var reviews: [BarcodeItemReview] = []
    @Published var shownReviews: [BarcodeItemReview] = [] // Filtered reviews
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var filters: [Filter] = [
        Filter(id: "1", label: "Latest", value: "latest", icon: "arrow.down", isSelected: true),
        Filter(id: "2", label: "Oldest", value: "oldest", icon: "arrow.up", isSelected: false)
    ]
    
    let barcode: String
    let productName: String

    init(barcode: String, productName: String) {
        self.barcode = barcode
        self.productName = productName
        fetchReviews()
    }

    func fetchReviews() {
        isLoading = true
        errorMessage = nil

        BarcodeItemService.shared.getReviewsForBarcode(barcode: barcode) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let reviews):
                    self?.reviews = reviews
                    self?.applyFilter()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func toggleFilter(id: String) {
        for index in filters.indices {
            filters[index].isSelected = (filters[index].id == id)
        }
        applyFilter()
    }

    private func applyFilter() {
        guard let selectedFilter = filters.first(where: { $0.isSelected }) else {
            shownReviews = reviews
            return
        }
        switch selectedFilter.value {
        case "latest":
            shownReviews = reviews.sorted {
                ($0.dateTime?.dateValue() ?? Date.distantPast) >
                ($1.dateTime?.dateValue() ?? Date.distantPast)
            }
        case "oldest":
            shownReviews = reviews.sorted {
                ($0.dateTime?.dateValue() ?? Date.distantPast) <
                ($1.dateTime?.dateValue() ?? Date.distantPast)
            }
        default:
            shownReviews = reviews
        }
    }
}
