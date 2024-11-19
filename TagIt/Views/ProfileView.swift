//
//  ProfileView.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-16.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel = ProfileViewModel()
    var body: some View {
        ScrollView {
            VStack {
                ImageUploadView(
                    imageToUpload: $viewModel.image,
                    placeholderImage: UIImage(named: "uploadProfileIcon")!,
                    width: 120,
                    height: 120
                )
                .padding(.top, 20)
                .padding(.bottom, 40)
                
                VStack(alignment: .leading, spacing: 15) {
                    Group {
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
                        
                        // User ID
                        HStack {
                            Text("UserID")
                                .fontWeight(.semibold)
                            Spacer()
                            if let userID = viewModel.userProfile?.id {
                                Text(userID)
                                    .foregroundColor(.gray)
                            } else {
                                ProgressView()
                            }
                        }
                        
                        Divider()
                        
                        // Upvoted Posts
                        NavigationLink(destination: UpvotedPostsView()) {
                            HStack {
                                Text("Upvoted Posts")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        Divider()
                        
                        // My Listings
                        NavigationLink(destination: MyListingsView()) {
                            HStack {
                                Text("My Listings")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
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
                        
                        Text("Log Out")
                            .foregroundColor(.red)
                            .onTapGesture {
                                viewModel.logout()
                            }
                        Divider()
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
        .background(Color(.systemGray6))
    }
}

#Preview {
    ProfileView()
}
