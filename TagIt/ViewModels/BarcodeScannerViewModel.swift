//
//  BarcodeScannerViewModel.swift
//  TagIt
//
//  Created by Angi Shi on 2024-10-27.
//

import SwiftUI

/**
 Manages the state for barcode scanning functionality.

 This view model handles the scanned barcode value, allowing views to reactively update based on barcode scans.
 */
class BarcodeScannerViewModel: ObservableObject {
    /// The barcode value that has been scanned. It is optional and updates when a new barcode is scanned.
    @Published var scannedBarcode: String? = nil
}
