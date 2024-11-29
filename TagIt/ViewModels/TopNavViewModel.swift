//
//  TopNavViewModel.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-11-28.
//

import Foundation
import UIKit

class TopNavViewModel: ObservableObject{
    @Published var userProfile: UserProfile? = nil;
    @Published var avatarImage: UIImage? = nil
    @Published var isLoading = false
    
    init() {
        // Fetch the cached user from AuthService when the ViewModel is initialized
        print("init profileviewmodel")
        fetchCachedUser()
    }
    
    func fetchCachedUser() {
        AuthService.shared.getCurrentUser(){profile in
            DispatchQueue.main.async {
                self.userProfile = profile
                self.fetchProfileImage()
                print("Success loading profile: \(profile?.displayName ?? "Unknown")")
                self.isLoading = false
            }
        }
    }
    
    func fetchProfileImage() {
        guard let avatarURL = userProfile?.avatarURL else { return }
        ImageService.shared.downloadImage(from: avatarURL) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    self.avatarImage = image
                    print("Success loading image: \(avatarURL)")
                case .failure(let error):
                    print("Failed to download image: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
}
