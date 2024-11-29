//
//  ProfileView.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-16.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel = ProfileViewModel()
    @State private var isEditingUsername = false
    @State private var newUsername = ""
    
    var body: some View {
        ScrollView {
            VStack {
                ImageUploadView(
                    imageToUpload: $viewModel.image,
                    placeholderImage: viewModel.avatarImage ?? UIImage(named: "uploadProfileIcon")!,
                    width: 120,
                    height: 120
                )
                .onChange(of: viewModel.image) { _, newImage in
                    if let newImage = newImage {
                        viewModel.updateProfileImage(newImage: newImage)
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 40)
                
                VStack(alignment: .leading, spacing: 15) {
                    Group {
                        Text("Profile Information")
                            .fontWeight(.heavy)
                        
                        Divider()
                        
                        // Username
                        HStack {
                            Text("Username")
                                .fontWeight(.semibold)
                            Spacer()
                            if let username = viewModel.userProfile?.displayName {
                                Text(username)
                                    .foregroundColor(.gray)
                            } else {
                                ProgressView()
                            }
                        }
                        
                        Divider()
                        
                        // Email
                        HStack {
                            Text("Email")
                                .fontWeight(.semibold)
                            Spacer()
                            if let email = viewModel.userProfile?.email {
                                Text(email)
                                    .foregroundColor(.gray)
                            } else {
                                ProgressView()
                            }
                        }
                        
                        Divider()
                        
                        // My Reviews
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
                        
                        Text("Account Settings")
                            .fontWeight(.heavy)
                        
                        Divider()
                        // Edit Username
                        NavigationLink(destination: EditUsernameView()) {
                                HStack {
                                    Text("Edit Username")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)
                                    Spacer()
                                }
                            }
                        
                        Divider()
                        
                        // Change Password
                        NavigationLink(destination: ChangePasswordView()) {
                                HStack {
                                    Text("Change Password")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)
                                    Spacer()
                                }
                            }
                        
                        Divider()
                        
                        Button(action: {
                            viewModel.logout()
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
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
        }
        .onAppear {
            viewModel.fetchCachedUser() // Fetch user profile and image on view load
            viewModel.fetchProfileImage()
        }
        .background(Color(.systemGray6))
    }
}

#Preview {
    ProfileView()
}
