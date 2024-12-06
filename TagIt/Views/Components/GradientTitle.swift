//
//  GradientTitle.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-29.
//

import SwiftUI

/**
 A custom view that displays a title with an icon and gradient text. The gradient is applied to the title text, and an icon is displayed next to the title.
 */
struct GradientTitle: View {
    // MARK: - Properties

    /// The SF Symbol icon name to display next to the title.
    var icon: String
    /// The text to display in the title.
    var text: String
    /// The font size for the title text.
    var fontSize: CGFloat
    /// The first color of the gradient.
    var color1: Color
    /// The second color of the gradient.
    var color2: Color

    // MARK: - View Body

    var body: some View {
        HStack {
            // Icon
            Image(systemName: icon)
                .font(.system(size: fontSize))
                .foregroundStyle(.green) // Set the color of the icon

            // Gradient Text
            Text(text)
                .fontWeight(.bold)
                .foregroundStyle(.black) // Set text color to black
                .font(.system(size: 40)) // Font size for the title
                .overlay(
                    LinearGradient(gradient: Gradient(colors: [color1, color2]), startPoint: .leading, endPoint: .trailing) // Apply gradient
                        .mask(
                            Text(text) // Mask the gradient with the title text
                                .fontWeight(.bold)
                                .font(.system(size: fontSize))
                        )
                )
        }
        .padding(.vertical, 20) // Vertical padding for the title
    }
}

#Preview {
    GradientTitle(icon: "plus.circle.fill", text: "Add a new deal", fontSize: 40, color1: .green, color2: .purple)
}
