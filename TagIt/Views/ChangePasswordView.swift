//
//  ChangePasswordView.swift
//  TagIt
//
//  Created by Angi Shi on 2024-11-05.
//

import SwiftUI

struct ChangePasswordView: View {
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String? = nil
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Change Password")
                .font(.title)
                .padding(.top)
            
            SecureField("Current Password", text: $currentPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            SecureField("New Password", text: $newPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            SecureField("Confirm New Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
            
            Button(action: changePassword) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Submit")
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.top)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Change Password")
    }
    
    private func changePassword() {
        errorMessage = nil
        
        guard !currentPassword.isEmpty, !newPassword.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "All fields are required."
            return
        }
        
        guard newPassword == confirmPassword else {
            errorMessage = "New passwords do not match."
            return
        }
    }
}

#Preview {
    ChangePasswordView()
}
