//
//  FilterButton.swift
//  TagIt
//
//  Created by Peter Tran on 2024-11-25.
//

import SwiftUI

/**
 A custom button used for filtering options, displaying an icon and label, and allowing for selection state changes.
 */
struct FilterButton: View {
    // MARK: - Properties

    /// The name of the system image icon to display on the button.
    var icon: String
    /// The text label displayed alongside the icon.
    var text: String
    /// Indicates whether the button is currently selected.
    var isSelected: Bool
    /// A closure that is called when the button is tapped.
    var action: () -> Void

    // MARK: - View Body

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundColor(isSelected ? .white : .black)

                Text(text)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .black)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(isSelected ? Color.green.opacity(1.0) : Color.white.opacity(1.0), lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(isSelected ? Color.green : Color.white)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
            )
        }
    }
}
