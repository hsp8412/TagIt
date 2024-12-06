//
//  ProfileViewModel.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-16.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import UIKit

/**
 ViewModel responsible for managing the user's profile data, including fetching and updating
 the user's avatar image, handling authentication state, and managing related UI states.
 */
class ProfileViewModel: ObservableObject {
    // MARK: - Published Properties

    /// Indicates whether a loading process is ongoing.
    @Published var isLoading = false
    /// Stores any error messages to be displayed to the user.
    @Published var errorMessage: String? = nil
    /// Represents the current user's profile information.
    @Published var userProfile: UserProfile? = nil
    /// Holds the main profile image.
    @Published var image: UIImage?
    /// Holds the user's avatar image.
    @Published var avatarImage: UIImage? = nil

    // MARK: - Initializer

    /**
     Initializes the ProfileViewModel and fetches the cached user and profile image when created.
     */
    init() {
        // Fetch the cached user from AuthService when the ViewModel is initialized
        print("init profileviewmodel")
        fetchCachedUser()
        fetchProfileImage()
    }

    // MARK: - Avatar Image Handling

    /**
     Loads the avatar image from the user's profile or uses a placeholder if unavailable.
     */
    func loadAvatarImage() {
        guard let avatarUrl = userProfile?.avatarURL, !avatarUrl.isEmpty, let url = URL(string: avatarUrl) else {
            // Use the placeholder if the URL is invalid
            DispatchQueue.main.async {
                self.avatarImage = UIImage(named: "uploadProfileIcon")
            }
            return
        }

        // Load the image asynchronously from the provided URL
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.avatarImage = image
                }
            } else {
                // Use the placeholder in case of an error during image loading
                DispatchQueue.main.async {
                    self.avatarImage = UIImage(named: "uploadProfileIcon")
                }
            }
        }.resume()
    }

    // MARK: - User Profile Handling

    /**
     Fetches the cached user profile from the authentication service.
     */
    func fetchCachedUser() {
        AuthService.shared.getCurrentUser { profile in
            DispatchQueue.main.async {
                self.userProfile = profile
                self.loadAvatarImage()
                print("Success loading profile: \(profile?.displayName ?? "Unknown")")
            }
        }
    }

    // MARK: - Logout Handling

    /**
     Logs out the current user and handles any errors that occur during the process.
     */
    func logout() {
        errorMessage = nil
        isLoading = true
        do {
            try Auth.auth().signOut()
            isLoading = false
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            errorMessage = "Error signing out"
            isLoading = false
        }
    }

    // MARK: - Profile Image Fetching

    /**
     Fetches the profile image using the ImageService.
     */
    func fetchProfileImage() {
        guard let avatarURL = userProfile?.avatarURL else { return }
        ImageService.shared.downloadImage(from: avatarURL) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(image):
                    // Update the avatar image on successful download
                    self.avatarImage = image
                    print("Success loading image: \(avatarURL)")
                case let .failure(error):
                    // Log the error if the image fails to download
                    print("Failed to download image: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Profile Image Update

    /**
     Updates the user's profile image by uploading a new image and updating the avatar URL.

     - Parameter newImage: The new UIImage to be set as the user's avatar.
     */
    func updateProfileImage(newImage: UIImage) {
        guard let _ = userProfile?.id else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Custom format

        let formattedDate = dateFormatter.string(from: Date())

        isLoading = true
        ImageService.shared.uploadImage(newImage, folder: .avatar, fileName: "avater-\(UUID().uuidString)-\(formattedDate)") { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(imageUrl):
                    // Update the avatar URL in Firestore and reset the cached user profile
                    self.updateAvatarURL(imageUrl: imageUrl)
                    self.userProfile?.avatarURL = imageUrl
                    print("success update avatar URL")
                    AuthService.shared.resetCurrentUserProfile()
                case let .failure(error):
                    // Handle any errors that occur during image upload
                    self.errorMessage = "Failed to upload image: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }

    // MARK: - Avatar URL Update

    /**
     Updates the avatar URL in Firestore for the current user.

     - Parameter imageUrl: The new URL of the uploaded avatar image.
     */
    private func updateAvatarURL(imageUrl: String) {
        guard let userId = userProfile?.id else { return }

        // Call the UserService to update the avatar URL in Firestore
        UserService.shared.updateAvatar(userId: userId, avatarURL: imageUrl) { result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    // Update the local user profile with the new avatar URL and refresh the UI
                    self.userProfile?.avatarURL = imageUrl
                    self.fetchProfileImage() // Refresh the profile image in the UI
                    self.isLoading = false
                case let .failure(error):
                    // Handle any errors that occur while updating the avatar URL
                    self.errorMessage = "Failed to update avatar URL: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
}
