//
//  LaunchScreenViewModel.swift
//  TagIt
//
//  Created by Peter Tran on 2024-12-15.
//

import SwiftUI

class LaunchScreenViewModel: ObservableObject {
    @Published var showLaunchScreen = true
    
    init() {
        // Automatically dismiss launch screen after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: 0.5)) {
                self.showLaunchScreen = false
            }
        }
    }
}
