//
//  LocationModel.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-11-16.
//

import Foundation
import FirebaseFirestore

struct Store: Identifiable, Codable {
    @DocumentID var id: String?
    var latitude: Double
    var longitude: Double
    var name: String
}
