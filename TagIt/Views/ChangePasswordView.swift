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
                .padding(.bottom)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Old Password")
                    .font(.body)
                SecureField("Enter your current password", text: $currentPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("New Password")
                    .font(.body)
                SecureField("Enter your new password", text: $newPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Confirm New Password")
                    .font(.body)
                SecureField("Re-enter your new password", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
            
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
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                        .padding(.horizontal)
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
