//
//  LaunchScreenView.swift
//  TagIt
//
//  Created by Peter Tran on 2024-12-15.
//
import SwiftUI

struct LaunchScreenView: View {
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.green, Color.cyan]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "tag.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(.white)
                
                Text("TagIt")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Discover. Share. Save.")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
            .scaleEffect(size)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 1.2)) {
                    self.size = 1.0
                    self.opacity = 1.0
                }
            }
        }
    }
}

struct LaunchScreenTransitionView<Content: View>: View {
    @StateObject private var viewModel = LaunchScreenViewModel()
    let content: Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            if viewModel.showLaunchScreen {
                LaunchScreenView()
                    .transition(.opacity)
            } else {
                content
                    .transition(.opacity)
            }
        }
    }
}
