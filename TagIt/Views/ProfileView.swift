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
    }
}

#Preview {
    ProfileView()
}
