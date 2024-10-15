//
//  TableModel.swift
//  Assignment2
//
//  Created by Chenghou Si on 2024-10-07.
//

import Foundation

struct TableItem: Identifiable {
    let id = UUID()
    let username: String
    let time: String
    let productName: String
    let price: String
    let comment: String
    let location: String
    let userImage: String
    let productImage: String
}

@Observable class AllItems {
    var items: [TableItem] = [
        TableItem(username: "Alice", time: "2h", productName: "Carrot", price: "3.00", comment: "Carrots on sale! This is the best offer!", location: "Freshco", userImage: "person.circle.fill", productImage: "https://i.imgur.com/8ciNZcY.jpeg"),
        TableItem(username: "Peter", time: "3h", productName: "Sausage", price: "5.99", comment: "I saw that Italian sausage is on sale!", location: "Safeway", userImage: "person.crop.circle.badge.fill", productImage: "https://i.imgur.com/8ciNZcY.jpeg"),
        TableItem(username: "Cindy", time: "1d", productName: "Tropicana Juice", price: "4.48", comment: "My favourite juice is on sale!", location: "Safeway", userImage: "person.crop.circle.badge", productImage: "https://i.imgur.com/8ciNZcY.jpeg"),
        TableItem(username: "Bob", time: "1d", productName: "Carrot", price: "5.00", comment: "Carrots on sale! This is the best offer!", location: "Safeway", userImage: "person.circle.fill", productImage: "https://i.imgur.com/8ciNZcY.jpeg"),
        TableItem(username: "Alice", time: "2d", productName: "Apple", price: "0.99", comment: "Apples on sale!", location: "Walmart", userImage: "person.circle.fill", productImage: "https://i.imgur.com/8ciNZcY.jpeg"),
        TableItem(username: "Eve", time: "2d", productName: "Orange", price: "10.00", comment: "Oranges are so expensive! Don't buy!", location: "ABC", userImage: "person.circle.fill", productImage: "https://i.imgur.com/8ciNZcY.jpeg"),
        TableItem(username: "Frank", time: "1w", productName: "Broccoli", price: "5.00", comment: "Broccoli on sale!", location: "Freshco", userImage: "person.circle.fill", productImage: "https://i.imgur.com/8ciNZcY.jpeg"),
        TableItem(username: "Peter", time: "1w", productName: "Cereal", price: "25.0", comment: "Cereal on sale! I bought it!", location: "Safeway", userImage: "person.crop.circle.badge.fill", productImage: "https://i.imgur.com/8ciNZcY.jpeg")
    ]
}
