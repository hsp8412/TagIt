//
//  ItemDetailView.swift
//  Assignment2
//
//  Created by Chenghou Si on 2024-10-07.
//

import SwiftUI

struct ItemDetailView: View {
    let item: TableItem

    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                VStack (alignment: .leading) {
                    HStack {
                        Image(systemName: item.userImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40)
                        
                        VStack (alignment: .leading) {
                            Text(item.username)
                                .lineLimit(1)
                            
                            Text(item.time)
                        }
                    }
                    
                    Text(item.productName)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("$" + item.price)
                }
                
                Image(systemName: item.productImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100)
            }
            
            Text("\"" + item.comment + "\"")
                .italic()
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                Image(systemName: "mappin")
                Text(item.location)
                    .foregroundStyle(Color.green)
                
                HStack {
                    Image(systemName: "hand.thumbsup")
                    Image(systemName: "hand.thumbsdown")
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding()
        .navigationTitle(item.productName)
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    ItemDetailView(item: TableItem(username: "Alice", time: "2h", productName: "Carrot", price: "3.00", comment: "Carrots on sale! This is the best offer!", location: "Freshco", userImage: "person.circle.fill", productImage: "pills.fill"))
}
