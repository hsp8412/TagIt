//
//  Extensions.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-16.
//

import Foundation
import SwiftUI

/**
 Extension for the `Encodable` protocol to convert conforming types into dictionaries.

 This extension provides a convenient method to transform any `Encodable` object into a `[String: Any]` dictionary.
 It is useful for scenarios where a dictionary representation of the object is required, such as preparing data for network requests.
 */
extension Encodable {
    /**
         Converts the `Encodable` instance into a `[String: Any]` dictionary.

         - Returns: A dictionary representation of the `Encodable` instance. Returns an empty dictionary if encoding fails.
     */
    func asDictionary() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self) else {
            return [:]
        }

        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            return json ?? [:]
        } catch {
            return [:]
        }
    }
}

/**
 Extension for the `Array` type to provide functionality for chunking the array into smaller arrays.

 This extension adds a method to split an array into chunks of a specified size, which is useful for processing large datasets in manageable segments.
 */
extension Array {
    /**
         Splits the array into smaller arrays (chunks) of the specified size.

         - Parameter size: The maximum number of elements each chunk should contain.
         - Returns: An array of arrays, where each sub-array contains up to `size` elements from the original array.
     */
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

/**
 Extension for `UIApplication` to provide a method for hiding the keyboard.

 This extension adds a convenient method to dismiss the keyboard from anywhere within the application, enhancing user experience by allowing easy dismissal of the keyboard when it's no longer needed.
 */
extension UIApplication {
    /**
         Dismisses the keyboard by resigning the first responder status.
     */
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
