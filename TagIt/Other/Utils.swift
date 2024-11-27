//
//  Utils.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-11-26.
//

import SwiftUI
import FirebaseFirestore

class Utils{
    static func timeAgoString(from timestamp: Timestamp) -> String {
        let currentDate = Date()
        let timestampDate = timestamp.dateValue()
        
        let timeDifference = currentDate.timeIntervalSince(timestampDate)
        
        if timeDifference < 60 {
            return "Just Now" // Less than 1 minute
        } else if timeDifference < 3600 {
            let minutes = Int(timeDifference / 60)
            return "\(minutes)m" // Less than 1 hour
        } else if timeDifference < 86400 {
            let hours = Int(timeDifference / 3600)
            return "\(hours)h" // Less than 1 day
        } else if timeDifference < 2592000 {
            let days = Int(timeDifference / 86400)
            return "\(days)d" // Less than 1 month
        } else if timeDifference < 31536000 {
            let months = Int(timeDifference / 2592000)
            return "\(months)mo" // Less than 1 year
        } else {
            let years = Int(timeDifference / 31536000)
            return "\(years)y" // 1 year or more
        }
    }
}
