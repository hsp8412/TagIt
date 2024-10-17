//
//  LoginViewModel.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-08.
//

import Foundation
import FirebaseAuth

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String? = nil
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false

    func login() {
        guard validate() else { return }

        errorMessage = nil
        isLoading = true

        AuthService.shared.loginUser(withEmail: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case .success(let userId):
                    print("Login successful with userId: \(userId)")
                    self?.isLoggedIn = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription // Display the specific error message
                    print("Login failed with error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func validate() -> Bool {
        errorMessage = nil
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please fill in all fields."
            return false
        }
        
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Please enter a valid email."
            return false
        }
        
        return true
    }
}
