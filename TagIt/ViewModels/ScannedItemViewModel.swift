//
//  ScannedItemViewModel.swift
//  TagIt
//
//  Created by Angi Shi on 2024-11-24.
//

import Foundation

class ScannedItemViewModel: ObservableObject {
    @Published var reviews: [BarcodeItemReview] = []
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil
    let barcode: String

    init(barcode: String) {
        self.barcode = barcode
        fetchReviews()
    }

    func fetchReviews() {
        isLoading = true
        errorMessage = nil

        BarcodeItemService.shared.getBarcodeItemsByBarcode(barcode: barcode) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let reviews):
                    self?.reviews = reviews
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
