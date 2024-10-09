//
//  ItemView.swift
//  Assignment2
//
//  Created by Chenghou Si on 2024-10-07.
//

import SwiftUI

struct ItemView: View {
    let item: TableItem

    var body: some View {
        NavigationLink(destination: ItemDetailView(item: item)) {
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
                    
                    Text("$" + item.price)
                    
                    HStack (spacing: 0) {
                        Text("\"")
                        Text(item.comment)
                            .lineLimit(1)
                            .italic()
                        Text("\"")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    HStack {
                        Image(systemName: "mappin")
                        Text(item.location)
                            .foregroundStyle(Color.green)
                    }
                }
                
                Image(systemName: item.productImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100)
            }
        }
    }
}

#Preview {
    ItemView(item: TableItem(username: "Alice", time: "2h", productName: "Carrot", price: "3.00", comment: "Carrots on sale! This is the best offer!", location: "Freshco", userImage: "person.circle.fill", productImage: "pills.fill"))
}
