//
//  Foundation+Extensions.swift
//  Movie AR
//
//  Created: December 2025
//  Foundation type extensions
//

import Foundation
import UIKit

// MARK: - String Extensions
extension String {

    /// Check if string is empty or contains only whitespace
    var isBlank: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Trim whitespace and newlines
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Truncate string to specified length
    func truncated(to length: Int, trailing: String = "...") -> String {
        if count > length {
            return String(prefix(length)) + trailing
        }
        return self
    }

    /// Check if string is valid email
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }

    /// Localized string
    var localized: String {
        NSLocalizedString(self, comment: "")
    }

    /// Localized string with arguments
    func localized(with arguments: CVarArg...) -> String {
        String(format: localized, arguments: arguments)
    }
}

// MARK: - Date Extensions
extension Date {

    /// Format date with specified format
    func formatted(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }

    /// Relative time string (e.g., "2 hours ago")
    var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    /// Check if date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    /// Check if date is yesterday
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    /// Days from now
    var daysFromNow: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: self).day ?? 0
    }
}

// MARK: - Array Extensions
extension Array {

    /// Safe subscript that returns nil if index is out of bounds
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }

    /// Split array into chunks of specified size
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

// MARK: - Dictionary Extensions
extension Dictionary {

    /// Merge with another dictionary
    func merged(with other: [Key: Value]) -> [Key: Value] {
        var result = self
        for (key, value) in other {
            result[key] = value
        }
        return result
    }
}

// MARK: - Optional Extensions
extension Optional where Wrapped == String {

    /// Returns true if nil or empty
    var isNilOrEmpty: Bool {
        self?.isEmpty ?? true
    }

    /// Returns empty string if nil
    var orEmpty: String {
        self ?? ""
    }
}

// MARK: - Collection Extensions
extension Collection {

    /// Check if collection is not empty
    var isNotEmpty: Bool {
        !isEmpty
    }
}

// MARK: - Double Extensions
extension Double {

    /// Format as currency
    func asCurrency(locale: Locale = .current) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        return formatter.string(from: NSNumber(value: self)) ?? "$\(self)"
    }

    /// Format as percentage
    func asPercentage(decimals: Int = 0) -> String {
        String(format: "%.\(decimals)f%%", self * 100)
    }

    /// Round to specified decimal places
    func rounded(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

// MARK: - Int Extensions
extension Int {

    /// Format with thousands separator
    var formatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }

    /// Ordinal string (1st, 2nd, 3rd, etc.)
    var ordinal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

// MARK: - URL Extensions
extension URL {

    /// Add query parameters to URL
    func appendingQueryParameters(_ parameters: [String: String]) -> URL? {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return nil
        }

        var queryItems = components.queryItems ?? []
        for (key, value) in parameters {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        components.queryItems = queryItems

        return components.url
    }
}

// MARK: - Data Extensions
extension Data {

    /// Convert to hex string
    var hexString: String {
        map { String(format: "%02x", $0) }.joined()
    }

    /// Pretty printed JSON string
    var prettyPrintedJSON: String? {
        guard let json = try? JSONSerialization.jsonObject(with: self),
              let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        return string
    }
}

// MARK: - Bundle Extensions
extension Bundle {

    /// App version string
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    /// Build number
    var buildNumber: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    /// Full version string
    var fullVersion: String {
        "\(appVersion) (\(buildNumber))"
    }
}

// MARK: - UserDefaults Extensions
extension UserDefaults {

    /// Get value with default
    func value<T>(forKey key: String, default defaultValue: T) -> T {
        object(forKey: key) as? T ?? defaultValue
    }

    /// Set Codable value
    func setCodable<T: Encodable>(_ value: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            set(data, forKey: key)
        }
    }

    /// Get Codable value
    func codable<T: Decodable>(forKey key: String) -> T? {
        guard let data = data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
