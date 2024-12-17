//
//  PrivacySettingsModel.swift
//  TagIt
//
//  Created by Peter Tran on 2024-12-16.
//
import FirebaseFirestore
import Foundation

/**
 Represents a user's privacy and data collection preferences.
 This model stores settings for various types of data collection and tracking.
 */
struct PrivacySettings: Codable {
    var analyticsEnabled: Bool
    var locationEnabled: Bool
    var marketingEnabled: Bool
    @ServerTimestamp var lastUpdated: Timestamp?
    
    static func defaultSettings() -> PrivacySettings {
        PrivacySettings(
            analyticsEnabled: false,
            locationEnabled: false,
            marketingEnabled: false,
            lastUpdated: nil
        )
    }
}
