//
//  ScannedItemView.swift
//  TagIt
//
//  Created by Angi Shi on 2024-11-05.
//

import SwiftUI

struct ScannedItemView: View {
    let barcode: String

    var body: some View {
        VStack {
            Text("Scanned Item")
                .font(.title)
                .padding()
            
            Text("Barcode Number: \(barcode)") 
                .font(.headline)
                .padding()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}
