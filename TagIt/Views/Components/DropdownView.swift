//
//  DropdownView.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-29.
//

import SwiftUI

/**
 A custom dropdown view that displays a list of options in a menu-style picker.
 The selected option is bound to a variable, and the label is displayed above the picker.
 */
struct DropdownView: View {
    // MARK: - Properties

    /// The list of options to display in the dropdown.
    var options: [String]
    /// The selected option, bound to a parent view.
    @Binding var selectedOption: String?
    /// The label displayed above the dropdown.
    var label: String

    // MARK: - View Body

    var body: some View {
        // Dropdown picker
        List {
            Picker(label, selection: $selectedOption) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option as String?) // List options in the picker
                }
            }
            .pickerStyle(MenuPickerStyle()) // Style for dropdown picker
        }
    }
}

#Preview {
    DropdownView(
        options: ["FreshCo Brentwood", "Safeway Market Mall", "Safeway North Hill"],
        selectedOption: .constant("FreshCo Brentwood"),
        label: "Supermarket"
    )
}
