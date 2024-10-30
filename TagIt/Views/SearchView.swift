//
//  SearchView.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-07.
//

import SwiftUI

struct SearchView: View {
    @StateObject var viewModel: SearchViewModel = SearchViewModel();
    var body: some View {
        VStack{
            ZStack{
                Color(UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1))
                VStack{
                    GradientTitle(icon: "magnifyingglass.circle.fill", text:"Search deals", fontSize: 40, color1:.green, color2:.purple)
                    // Form
                    VStack(spacing:20){
                        VStack(alignment:.leading){
                            Text("Item Name")
                                .padding(.horizontal, 40)
                                .foregroundStyle(.green)
                            TextField("Item Name", text: $viewModel.searchText)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .padding(.horizontal, 40)
                                .shadow(radius: 5)
                                .autocapitalization(.none)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SearchView()
}
