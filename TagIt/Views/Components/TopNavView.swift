//
//  TopNavView.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-07.
//

import SwiftUI

/**
 A navigation bar at the top of the screen displaying the app's logo, title, and navigation items (barcode scanner and user profile).
 */
struct TopNavView: View {
    // MARK: - Properties

    /// The ViewModel responsible for fetching and displaying the user profile.
    @StateObject var viewModel = TopNavViewModel()

    // MARK: - View Body

    var body: some View {
        HStack {
            // Logo as an SF Symbol
            Image(systemName: "tag.fill") // Replace "applelogo" with your desired SF Symbol
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .padding(.leading, 16)
                .foregroundStyle(.green)

            Text("TagIt")
                .font(.system(size: 25))
                .fontWeight(.bold)
                .foregroundColor(Color.gray)
                .padding(.leading, 10)

            Spacer() // Push items to the right

            // Navigation items
            HStack(spacing: 10) {
                // Barcode Scanner Navigation Link
                NavigationLink(destination: BarcodeScannerView()) {
                    Image(systemName: "barcode.viewfinder") // SF Symbol for barcode scanner
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundStyle(.gray)
                }

                // Profile Navigation Link
                NavigationLink(destination: ProfileView()) {
                    if viewModel.isLoading, viewModel.userProfile == nil {
                        ProgressView()
                            .frame(width: 40, height: 40)
                    } else {
                        NavAvatarView(avatar: $viewModel.avatarImage)
                            .frame(width: 40, height: 40)
                    }
                }
                .onAppear {
                    viewModel.isLoading = true
                    viewModel.fetchCachedUser() // Fetch the user profile when the view appears
                }
            }
            .padding(.trailing, 16)
        }
        .frame(height: 60) // Set the height of the top navigation bar
        .background(.topNavBG) // Custom background color or image
        .foregroundColor(.black) // Text color
        .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 3, y: 3) // Drop shadow for depth
    }
}

#Preview {
    TopNavView()
}
