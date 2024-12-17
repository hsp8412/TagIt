//
//  PrivacySettingsView.swift
//  TagIt
//
//  Created by Peter Tran on 2024-12-16.
//

import SwiftUI
import FirebaseAuth

/**
 View for managing user privacy settings and account deletion.
 Provides controls for data collection preferences and account deletion capability.
 */
struct PrivacySettingsView: View {
    @State private var analyticsEnabled = false
    @State private var locationEnabled = false
    @State private var marketingEnabled = false
    @State private var showingDeleteConfirmation = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            // Data Collection Settings Section
            VStack(alignment: .leading, spacing: 20) {
                Text("Data Collection Settings")
                    .font(.headline)
                    .padding(.horizontal)
                
                VStack(spacing: 15) {
                    PrivacyToggle(
                        title: "Analytics Collection",
                        subtitle: "Help us improve the app by collecting usage data",
                        isOn: $analyticsEnabled
                    )
                    
                    PrivacyToggle(
                        title: "Location Services",
                        subtitle: "Enable location-based deal recommendations",
                        isOn: $locationEnabled
                    )
                    
                    PrivacyToggle(
                        title: "Marketing Communications",
                        subtitle: "Receive updates about new features and deals",
                        isOn: $marketingEnabled
                    )
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 2)
            }
            .padding()
            
            // Account Deletion Section
            VStack(alignment: .leading, spacing: 15) {
                Text("Account")
                    .font(.headline)
                    .padding(.horizontal)
                
                Button(action: {
                    showingDeleteConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                        Text("Delete Account")
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Privacy Settings")
        .onChange(of: analyticsEnabled) { _, newValue in
            updatePrivacySettings()
        }
        .onChange(of: locationEnabled) { _, newValue in
            updatePrivacySettings()
        }
        .onChange(of: marketingEnabled) { _, newValue in
            updatePrivacySettings()
        }
        .alert("Delete Account", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("This action cannot be undone. All your data will be permanently deleted.")
        }
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            loadPrivacySettings()
        }
    }
    
    private func loadPrivacySettings() {
        guard let userId = AuthService.shared.getCurrentUserID() else { return }
        
        PrivacyService.shared.getPrivacySettings(userId: userId) { result in
            // Remove [weak self] since PrivacySettingsView is a struct
            DispatchQueue.main.async {
                switch result {
                case .success(let settings):
                    self.analyticsEnabled = settings.analyticsEnabled
                    self.locationEnabled = settings.locationEnabled
                    self.marketingEnabled = settings.marketingEnabled
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showingErrorAlert = true
                }
            }
        }
    }

    private func updatePrivacySettings() {
        guard let userId = AuthService.shared.getCurrentUserID() else { return }
        
        let settings = PrivacySettings(
            analyticsEnabled: analyticsEnabled,
            locationEnabled: locationEnabled,
            marketingEnabled: marketingEnabled,
            lastUpdated: nil
        )
        
        PrivacyService.shared.updatePrivacySettings(
            settings: settings,
            userId: userId
        ) { result in
            // Remove [weak self] since PrivacySettingsView is a struct
            DispatchQueue.main.async {
                if case .failure(let error) = result {
                    self.errorMessage = error.localizedDescription
                    self.showingErrorAlert = true
                }
            }
        }
    }
    
    private func deleteAccount() {
        guard let userId = AuthService.shared.getCurrentUserID() else { return }
        
        PrivacyService.shared.deleteUserAccount(userId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Clear local user data
                    AuthService.shared.resetCurrentUserProfile()
                    dismiss()
                    
                case .failure(let error):
                    // Handle specific error cases
                    if (error as NSError).code == 401 {
                        // User needs to log in again
                        self.errorMessage = "Please log in again to delete your account"
                        // Optionally, sign the user out here to force re-authentication
                        try? Auth.auth().signOut()
                    } else {
                        self.errorMessage = error.localizedDescription
                    }
                    self.showingErrorAlert = true
                }
            }
        }
    }
}

/**
 A custom toggle view for privacy settings that includes a title and subtitle.
 */
struct PrivacyToggle: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
        }
    }
}
