import SwiftUI

/**
 `ProfileView` allows the user to view and edit their profile information.
 It displays the profile image, username, email, and options for account settings like changing the username, password, and logging out.
 */
struct ProfileView: View {
    @StateObject var viewModel = ProfileViewModel() // ViewModel to manage the profile data and image
    @State private var isEditingUsername = false // Flag to track if the username is being edited
    @State private var newUsername = "" // Store the new username when editing

    var body: some View {
        ScrollView {
            VStack {
                // Profile image upload section
                ImageUploadView(
                    imageToUpload: $viewModel.image,
                    placeholderImage: viewModel.avatarImage ?? UIImage(named: "uploadProfileIcon")!,
                    width: 120,
                    height: 120
                )
                .onChange(of: viewModel.image) { _, newImage in
                    if let newImage {
                        viewModel.updateProfileImage(newImage: newImage) // Update profile image when a new image is selected
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 40)

                VStack(alignment: .leading, spacing: 15) {
                    Group {
                        Text("Profile Information") // Section header for profile details
                            .fontWeight(.heavy)

                        Divider()

                        // Username Section
                        HStack {
                            Text("Username")
                                .fontWeight(.semibold)
                            Spacer()
                            if let username = viewModel.userProfile?.displayName {
                                Text(username) // Display current username
                                    .foregroundColor(.gray)
                            } else {
                                ProgressView() // Show loading indicator if username is being fetched
                            }
                        }

                        Divider()

                        // Email Section
                        HStack {
                            Text("Email")
                                .fontWeight(.semibold)
                            Spacer()
                            if let email = viewModel.userProfile?.email {
                                Text(email) // Display current email
                                    .foregroundColor(.gray)
                            } else {
                                ProgressView() // Show loading indicator if email is being fetched
                            }
                        }

                        Divider()

                        // My Reviews Section
                        NavigationLink(destination: ReviewedItemsView()) {
                            HStack {
                                Text("Reviewed Posts")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        Divider()
                            .padding(.bottom, 20)

                        Text("Account Settings") // Section header for account settings
                            .fontWeight(.heavy)

                        Divider()

                        // Edit Username Section
                        NavigationLink(destination: EditUsernameView()) {
                            HStack {
                                Text("Edit Username")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                Spacer()
                            }
                        }

                        Divider()

                        // Change Password Section
                        NavigationLink(destination: ChangePasswordView()) {
                            HStack {
                                Text("Change Password")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                Spacer()
                            }
                        }

                        Divider()

                        // Logout Button
                        Button(action: {
                            viewModel.logout() // Log out the user when pressed
                        }) {
                            Text("Log Out")
                                .foregroundColor(.red)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
                .padding()
                .background(Color(.systemGray6)) // Background color for the profile section
                .cornerRadius(10)

                // Display error message if there is an issue fetching data
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                Spacer()
            }
        }
        .onAppear {
            // Fetch user profile and image when the view appears
            viewModel.fetchCachedUser()
            viewModel.fetchProfileImage()
        }
        .background(Color(.systemGray6)) // Set background color for the entire view
    }
}

#Preview {
    ProfileView()
}
