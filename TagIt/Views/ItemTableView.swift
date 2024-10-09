//
//  ItemTableView.swift
//  Assignment2
//
//  Created by Chenghou Si on 2024-10-07.
//

import SwiftUI

struct ItemTableView: View {
    @State private var items = AllItems().items
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(searchResult) { item in
                    ItemView(item: item)
                }
            }
            //.navigationTitle("All Item List")
        }
        .searchable(text: $searchText, prompt: "Looking for a product or grocery store?")
        
        Spacer()
    }
    
    var searchResult: [TableItem] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter { $0.productName.lowercased().contains(searchText.lowercased()) ||
                $0.location.lowercased().contains(searchText.lowercased())
            }
        }
    }
}

#Preview {
    ItemTableView()
}
