//
//  TopNavView.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-07.
//

import SwiftUI

struct TopNavView: View {
    var body: some View {
        HStack {
            // Logo as an SF Symbol
            Image(systemName: "tag.fill") // Replace "applelogo" with your desired SF Symbol
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .padding(.leading, 16)
                .foregroundStyle(.green)
            Text("Tagit")
                .font(.system(size: 25))
                .fontWeight(.bold)
                .foregroundColor(Color.gray)
                .padding(.leading, 10)
            
            
            Spacer() // Push items to the right
            
            // Navigation items
            HStack(spacing: 10) {
                NavigationLink(destination: BarcodeScannerView()) {
                    Image(systemName: "barcode.viewfinder") // Replace "applelogo" with your desired SF Symbol
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundStyle(.gray)
                }
                NavigationLink(destination: ProfileView()) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundStyle(.gray)
                }
            }
            .padding(.trailing, 16)
        }
        .frame(height: 60)
        .background(.topNavBG)
        .foregroundColor(.black)
        .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 3, y: 3)
    }
}

#Preview {
    TopNavView()
}
