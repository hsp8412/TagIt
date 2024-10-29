//
//  BarcodeScannerViewModel.swift
//  TagIt
//
//  Created by Angi Shi on 2024-10-27.
//

import SwiftUI

class BarcodeScannerViewModel: ObservableObject {
    @Published var scannedBarcode: String? = nil 
}
