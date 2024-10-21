//
//  NewDealViewModel.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-20.
//

import Foundation
import UIKit
import SwiftUI

class NewDealViewModel: ObservableObject{
    @Published var image: UIImage?
    @Published var productText: String = ""
    @Published var postText: String = ""
    @Published var price: String = ""
    @Published var location: String = ""
    @Published var submitted: Bool = false
    @Published var errorMessage: String? = nil
    
    private var selectedTab: Binding<Int>  // Store the Binding
    
    init(selectedTab: Binding<Int>) {
        self.selectedTab = selectedTab
    }
    
    // Handle form submission
    func handleSubmit() {
        if validate() {
           
            submitted = true
            selectedTab.wrappedValue = 0
            clearForm()
            submitted = false
        } else {
            submitted = false
        }
    }
    
    private func clearForm() {
        productText = ""
        postText = ""
        price = ""
        location = ""
        image = nil
        submitted = false
        errorMessage = nil
    }
    
    // Validation method to check all conditions
    private func validate() -> Bool {
        errorMessage = nil
        
        // All fields are required
        guard !productText.isEmpty, !price.isEmpty, !location.isEmpty, !postText.isEmpty, image != nil else {
            errorMessage = "Please fill in all fields and upload an image."
            print("Please fill in all fields and upload an image.")
            return false
        }
        
        // Check if product name is valid (minimum 3 characters)
        guard productText.count >= 3 else {
            errorMessage = "Product name must be at least 3 characters long."
            return false
        }
        
        // Check if price is valid
        guard isValidPrice(price) else {
            errorMessage = "Please enter a valid price."
            return false
        }
        
        return true
    }
    
    // Price validation using a simple regex (checks for decimal numbers)
      private func isValidPrice(_ price: String) -> Bool {
          let priceRegex = "^[0-9]+(\\.[0-9]{1,2})?$"  // Allows integers or decimals with up to two decimal places
          let pricePredicate = NSPredicate(format: "SELF MATCHES %@", priceRegex)
          return pricePredicate.evaluate(with: price)
      }
}
