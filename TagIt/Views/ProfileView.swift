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
        VStack {
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
                    .padding(.leading, 50)
                    .padding(.top, 50)
                
                Spacer()
            }
            
            if viewModel.userProfile == nil{
                ProgressView()
            }else{
                Text(viewModel.userProfile?.displayName ?? "error")
            }
            
            Button(action: {
                viewModel.logout()
            }) {
                if viewModel.isLoading {
                    ProgressView()
                }
                else{
                    Text("Log Out")
                        .padding(.horizontal,20)
                        .padding(.vertical, 15)
                        .background(.red)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
            }.padding(.top, 20)
            if let errorMessage = viewModel.errorMessage{
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
    }
}

#Preview {
    ProfileView()
}
