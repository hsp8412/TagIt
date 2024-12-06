//
//  ScannedItemViewModel.swift
//  TagIt
//
//  Created by Angi Shi on 2024-11-24.
//

import FirebaseFirestore
import Foundation

/**
 Manages the state and logic for displaying and filtering reviews associated with a scanned barcode.

 This view model handles fetching reviews from the backend, applying user-selected filters, and managing loading and error states.
 */
class ScannedItemViewModel: ObservableObject {
    // MARK: - Published Properties

    /// The complete list of reviews fetched from the backend.
    @Published var reviews: [BarcodeItemReview] = []

    /// The list of reviews currently displayed after applying filters.
    @Published var shownReviews: [BarcodeItemReview] = [] // Filtered reviews

    /// Indicates whether the view model is currently loading data.
    @Published var isLoading: Bool = false

    /// An optional error message to display if fetching reviews fails.
    @Published var errorMessage: String? = nil

    /// The list of available filters for sorting reviews.
    @Published var filters: [Filter] = [
        Filter(id: "1", label: "Latest", value: "latest", icon: "arrow.down", isSelected: true),
        Filter(id: "2", label: "Oldest", value: "oldest", icon: "arrow.up", isSelected: false),
    ]

    // MARK: - Properties

    /// The barcode number associated with the product being reviewed.
    let barcode: String

    /// The name of the product associated with the barcode.
    let productName: String

    // MARK: - Initializer

    /**
         Initializes the `ScannedItemViewModel` with the specified barcode and product name.

         - Parameters:
             - barcode: The barcode number of the scanned item.
             - productName: The name of the product associated with the barcode.

         Automatically fetches the reviews for the provided barcode upon initialization.
     */
    init(barcode: String, productName: String) {
        self.barcode = barcode
        self.productName = productName
        fetchReviews()
    }

    // MARK: - Public Methods

    /**
         Fetches the reviews associated with the scanned barcode from the backend.

         This method sets the loading state to true, clears any previous error messages, and attempts
         to retrieve reviews using the `BarcodeItemService`. Upon completion, it updates the `reviews`
         and applies the current filter.
     */
    func fetchReviews() {
        isLoading = true
        errorMessage = nil

        BarcodeItemService.shared.getReviewsForBarcode(barcode: barcode) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case let .success(reviews):
                    self?.reviews = reviews
                    self?.applyFilter()
                case let .failure(error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    /**
         Toggles the selected filter based on the provided filter ID.

         - Parameter id: The unique identifier of the filter to be selected.

         This method updates the `filters` array to reflect the newly selected filter and re-applies
         the filter to update the displayed reviews.
     */
    func toggleFilter(id: String) {
        for index in filters.indices {
            filters[index].isSelected = (filters[index].id == id)
        }
        applyFilter()
    }

    // MARK: - Private Methods

    /**
         Applies the currently selected filter to the list of reviews.

         Depending on the selected filter (e.g., "Latest" or "Oldest"), this method sorts the `reviews`
         array accordingly and updates the `shownReviews` array to reflect the sorted results.
     */
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
