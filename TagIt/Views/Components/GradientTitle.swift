//
//  GradientTitle.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-29.
//

import SwiftUI

struct GradientTitle: View {
    var icon: String;
    var text: String;
    var fontSize: CGFloat;
    var color1: Color;
    var color2: Color;
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: fontSize))
                .foregroundStyle(.green)
            Text(text)
                .fontWeight(.bold)
                .foregroundStyle(.black)
                .font(.system(size: 40))
                .overlay(
                    LinearGradient(gradient: Gradient(colors: [color1, color2]), startPoint: .leading, endPoint: .trailing)
                        .mask(
                            Text(text)
                                .fontWeight(.bold)
                                .font(.system(size: fontSize))
                        )
                )
        }
        .padding(.vertical, 20)
    }
}

#Preview {
    GradientTitle(icon: "plus.circle.fill", text:"Add a new deal", fontSize: 40, color1:.green, color2:.purple)
}
