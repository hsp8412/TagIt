//
//  Utils.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-11-26.
//

import FirebaseFirestore
import SwiftUI

/// A utility class providing helper functions for the TagIt application.
class Utils {
    /// Converts a Firebase `Timestamp` to a human-readable "time ago" string.
    ///
    /// This method calculates the time difference between the current date and the provided timestamp,
    /// then returns a string representing how much time has passed in a concise format.
    ///
    /// - Parameter timestamp: The Firebase `Timestamp` to convert.
    /// - Returns: A `String` representing the time elapsed since the given timestamp.
    ///
    /// ## Time Difference Categories
    /// - **Less than 1 minute:** Returns `"Just Now"`.
    /// - **Less than 1 hour:** Returns the number of minutes followed by `"m"`.
    /// - **Less than 1 day:** Returns the number of hours followed by `"h"`.
    /// - **Less than 1 month:** Returns the number of days followed by `"d"`.
    /// - **Less than 1 year:** Returns the number of months followed by `"mo"`.
    /// - **1 year or more:** Returns the number of years followed by `"y"`.
    ///
    /// ## Example
    /// ```swift
    /// let timestamp = Timestamp(date: Date().addingTimeInterval(-3600)) // 1 hour ago
    /// let timeAgo = Utils.timeAgoString(from: timestamp) // "1h"
    /// ```
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
        } else if timeDifference < 2_592_000 {
            let days = Int(timeDifference / 86400)
            return "\(days)d" // Less than 1 month
        } else if timeDifference < 31_536_000 {
            let months = Int(timeDifference / 2_592_000)
            return "\(months)mo" // Less than 1 year
        } else {
            let years = Int(timeDifference / 31_536_000)
            return "\(years)y" // 1 year or more
        }
    }
}
