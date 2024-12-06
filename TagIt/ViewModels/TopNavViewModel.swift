//
//  TopNavViewModel.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-11-28.
//

import Foundation
import UIKit

/**
 ViewModel responsible for managing the user's profile information in the top navigation,
 including fetching and displaying the user's profile data and avatar image.
 */
class TopNavViewModel: ObservableObject {
    // MARK: - Published Properties

    /// The current user's profile data.
    @Published var userProfile: UserProfile? = nil
    /// The user's avatar image.
    @Published var avatarImage: UIImage? = nil
    /// Indicates whether the profile data is currently being loaded.
    @Published var isLoading = false

    // MARK: - Initializer

    /**
     Initializes the TopNavViewModel and fetches the cached user data when the ViewModel is created.
     */
    init() {
        print("init profileviewmodel")
        fetchCachedUser()
    }

    // MARK: - Profile Fetching

    /**
     Fetches the current user's profile from the AuthService.
     */
    func fetchCachedUser() {
        AuthService.shared.getCurrentUser { profile in
            DispatchQueue.main.async {
                self.userProfile = profile
                self.fetchProfileImage()
                print("Success loading profile: \(profile?.displayName ?? "Unknown")")
                self.isLoading = false
            }
        }
    }

    /**
     Fetches the user's profile image from the provided avatar URL.
     */
    func fetchProfileImage() {
        guard let avatarURL = userProfile?.avatarURL else { return }
        ImageService.shared.downloadImage(from: avatarURL) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(image):
                    self.avatarImage = image
                    print("Success loading image: \(avatarURL)")
                case let .failure(error):
                    print("Failed to download image: \(error.localizedDescription)")
                }
            }
        }
    }
}
