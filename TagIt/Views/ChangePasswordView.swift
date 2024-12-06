import SwiftUI

/**
 `ChangePasswordView` allows the user to change their password by entering their old password, new password, and confirming the new password.
 It provides validation for the fields and shows relevant error messages when necessary.
 */
struct ChangePasswordView: View {
    @State private var currentPassword = "" // Holds the old password input
    @State private var newPassword = "" // Holds the new password input
    @State private var confirmPassword = "" // Holds the confirmation of the new password
    @State private var errorMessage: String? = nil // Holds any error message related to password validation
    @State private var isLoading = false // Tracks the loading state when the password change request is being processed

    var body: some View {
        VStack(spacing: 20) {
            // Title of the screen
            Text("Change Password")
                .font(.title)
                .padding(.top)
                .padding(.bottom)

            // Old Password Input
            VStack(alignment: .leading, spacing: 5) {
                Text("Old Password")
                    .font(.body)
                SecureField("Enter your current password", text: $currentPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle()) // Styled with rounded borders
            }
            .padding(.horizontal)

            // New Password Input
            VStack(alignment: .leading, spacing: 5) {
                Text("New Password")
                    .font(.body)
                SecureField("Enter your new password", text: $newPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle()) // Styled with rounded borders
            }
            .padding(.horizontal)

            // Confirm New Password Input
            VStack(alignment: .leading, spacing: 5) {
                Text("Confirm New Password")
                    .font(.body)
                SecureField("Re-enter your new password", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle()) // Styled with rounded borders
            }
            .padding(.horizontal)
            .padding(.bottom, 20)

            // Displaying error message if there is any
            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }

            // Submit Button
            Button(action: changePassword) {
                if isLoading {
                    ProgressView() // Show loading spinner when the process is ongoing
                } else {
                    Text("Submit")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green) // Green background for the button
                        .cornerRadius(10) // Rounded corners for the button
                        .padding(.horizontal)
                }
            }
            .padding(.top)

            Spacer() // Spacer to push the content to the top
        }
        .padding() // Padding around the entire view
        .navigationTitle("Change Password") // Title for the navigation bar
    }

    /**
     Validates the entered password fields and handles the password change logic.
     */
    private func changePassword() {
        errorMessage = nil // Clear previous error message

        // Check if any field is empty
        guard !currentPassword.isEmpty, !newPassword.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "All fields are required." // Display error if any field is empty
            return
        }

        // Check if new passwords match
        guard newPassword == confirmPassword else {
            errorMessage = "New passwords do not match." // Display error if the new passwords do not match
            return
        }

        // Additional logic for changing password can be added here
    }
}

#Preview {
    ChangePasswordView() // Preview for ChangePasswordView
}
