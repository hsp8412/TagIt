//
//  FilterButton.swift
//  TagIt
//
//  Created by Peter Tran on 2024-11-25.
//

import SwiftUI

struct FilterButton: View {
    var icon: String
    var text: String
    var isSelected: Bool // Indicates if the button is selected
    var action: () -> Void // Callback for button tap
    
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
