//
//  ProfileViewModel.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-16.
//

import Foundation
import FirebaseAuth
import UIKit
import FirebaseFirestore

class ProfileViewModel:ObservableObject{
    @Published var isLoading = false;
    @Published var errorMessage:String? = nil;
    @Published var userProfile: UserProfile? = nil;
    @Published var image: UIImage?;
    @Published var avatarImage: UIImage? = nil
    
    init() {
        // Fetch the cached user from AuthService when the ViewModel is initialized
        print("init profileviewmodel")
        fetchCachedUser()
        fetchProfileImage()
    }
    
    
    func loadAvatarImage() {
        guard let avatarUrl = userProfile?.avatarURL, !avatarUrl.isEmpty, let url = URL(string: avatarUrl) else {
            // Use the placeholder if the URL is invalid
            DispatchQueue.main.async {
                self.avatarImage = UIImage(named: "uploadProfileIcon")
            }
            return
        }
        
        // Load the image asynchronously
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.avatarImage = image
                }
            } else {
                // Use the placeholder in case of error
                DispatchQueue.main.async {
                    self.avatarImage = UIImage(named: "uploadProfileIcon")
                }
            }
        }.resume()
    }
    
    func fetchCachedUser() {
        AuthService.shared.getCurrentUser(){profile in
            DispatchQueue.main.async {
                self.userProfile = profile
                self.loadAvatarImage()
                print("Success loading profile: \(profile?.displayName ?? "Unknown")")
            }
        }
    }
    
    func logout(){
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
    
    func fetchProfileImage() {
        guard let avatarURL = userProfile?.avatarURL else { return }
        ImageService.shared.downloadImage(from: avatarURL) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
//                    self.image = image
                    self.avatarImage = image
                    print("Success loading image: \(avatarURL)")
                case .failure(let error):
                    print("Failed to download image: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func updateProfileImage(newImage: UIImage) {
        guard let _ = userProfile?.id else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Custom format
        
        let formattedDate = dateFormatter.string(from: Date())
        
        isLoading = true
        ImageService.shared.uploadImage(newImage, folder: .avatar, fileName: "avater-\(UUID().uuidString)-\(formattedDate)") { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let imageUrl):
                    self.updateAvatarURL(imageUrl: imageUrl)
                    self.userProfile?.avatarURL = imageUrl
                    print("succes update avatar URL")
                    AuthService.shared.resetCurrentUserProfile()
                case .failure(let error):
                    self.errorMessage = "Failed to upload image: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
        
    }
    
    private func updateAvatarURL(imageUrl: String) {
        guard let userId = userProfile?.id else { return }
        
        // Call the UserService to update the avatar URL in Firestore
        UserService.shared.updateAvatar(userId: userId, avatarURL: imageUrl) { result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    // Update the local user profile with the new avatar URL
                    self.userProfile?.avatarURL = imageUrl
                    self.fetchProfileImage() // Refresh the profile image in the UI
                    self.isLoading = false
                case .failure(let error):
                    // Handle any errors
                    self.errorMessage = "Failed to update avatar URL: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
}
