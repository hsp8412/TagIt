import SwiftUI

/**
 `EditUsernameView` allows the user to edit their username. It provides a text field for the user to input a new username and a button to save the changes.
 */
struct EditUsernameView: View {
    @State private var newUsername: String = "" // State variable to track the new username input

    var body: some View {
        VStack {
            // Title section
            Text("Edit Username")
                .font(.title) // Title of the page
                .padding(.bottom, 40)

            // New username input section
            VStack(alignment: .leading, spacing: 5) {
                Text("New Username") // Label for the input field
                    .font(.body)
                TextField("Enter new username", text: $newUsername) // TextField for the new username
                    .textFieldStyle(RoundedBorderTextFieldStyle()) // Rounded border style for the input field
            }
            .padding(.horizontal) // Horizontal padding for the input field container
            .padding(.bottom, 20) // Padding below the input field

            // Save button to update the username
            Button(action: {
                print("Username updated to: \(newUsername)") // Placeholder for saving logic
            }) {
                Text("Save")
                    .font(.headline) // Text style for the button
                    .foregroundColor(.white) // White text color
                    .padding() // Padding inside the button
                    .frame(maxWidth: .infinity) // Button takes full width
                    .background(Color.green) // Green background color for the button
                    .cornerRadius(10) // Rounded corners for the button
                    .padding(.horizontal) // Padding on the left and right of the button
            }
            .padding(.top, 20) // Padding on top of the button

            Spacer() // Spacer to push the content to the top of the screen
        }
        .padding() // Padding around the entire view
        .background(Color.white // Background color for the view
            .onTapGesture { // Add a tap gesture to dismiss the keyboard when tapping outside
                UIApplication.shared.hideKeyboard()
            })
    }
}

#Preview {
    EditUsernameView() // Preview for the EditUsernameView
}
