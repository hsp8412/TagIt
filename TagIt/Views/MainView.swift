//
//  MainView.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-08.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel = MainViewModel()
    
    var body: some View {
        if viewModel.isSignedIn, !viewModel.currentUserId.isEmpty{
            // signed in
            ContentView()
        }else{
            LoginView()
        }
    }
}

#Preview {
    ContentView()
}
