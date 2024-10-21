//
//  HideKeyboardViewModel.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-10.
//

import SwiftUI

// UIApplication extension to hide the keyboard
extension UIApplication {
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
