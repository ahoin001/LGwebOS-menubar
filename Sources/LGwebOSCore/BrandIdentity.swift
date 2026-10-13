import Foundation

public struct RGBColor: Equatable, Sendable {
    public var red: Double
    public var green: Double
    public var blue: Double
    public init(red: Double, green: Double, blue: Double) {
        self.red = red
        self.green = green
        self.blue = blue
    }
    public static let lgPink = RGBColor(red: 0.91, green: 0.17, blue: 0.35)
}

public struct BrandIdentity: Equatable, Sendable {
    public var color: RGBColor
    public var label: String
    public var tagline: String
    /// True when the color comes from a known app, so icon sampling should not replace it.
    public var usesKnownColor: Bool

    public static func forApp(_ id: String, title: String = "") -> BrandIdentity {
        let key = (id + " " + title).lowercased()
        if key.contains("ps5") || key.contains("playstation") {
            return known(RGBColor(red: 0.12, green: 0.43, blue: 1), "PlayStation 5", "Your next adventure starts here.")
        }
        if key.contains("netflix") {
            return known(RGBColor(red: 0.94, green: 0.08, blue: 0.13), "Netflix", "A great story is waiting for you.")
        }
        if key.contains("youtube") {
            return known(RGBColor(red: 1, green: 0.18, blue: 0.23), "YouTube", "Everything you love, on the big screen.")
        }
        if key.contains("amazon") || key.contains("prime") {
            return known(RGBColor(red: 0.08, green: 0.64, blue: 1), "Prime Video", "Time for popcorn.")
        }
        if key.contains("disney") {
            return known(RGBColor(red: 0.20, green: 0.38, blue: 1), "Disney+", "A universe of stories.")
        }
        if key.contains("spotify") {
            return known(RGBColor(red: 0.12, green: 0.84, blue: 0.43), "Spotify", "Set the mood. Press play.")
        }
        if key.contains("twitch") {
            return known(RGBColor(red: 0.61, green: 0.35, blue: 1), "Twitch", "Your community, live.")
        }
        if key.contains("hbo") || key.contains("max") {
            return known(RGBColor(red: 0.60, green: 0.34, blue: 1), title.isEmpty ? "Max" : title, "Great stories. Unforgettable moments.")
        }
        if key.contains("globo") {
            return known(RGBColor(red: 1, green: 0.33, blue: 0.23), title, "Your entertainment, your way.")
        }
        if key.contains("apple") {
            return known(RGBColor(red: 0.9, green: 0.9, blue: 0.9), title, "Cinema in your living room.")
        }
        if key.contains("chromecast") {
            return known(RGBColor(red: 0.28, green: 0.66, blue: 0.93), "Chromecast", "From your device to your TV.")
        }
        return BrandIdentity(color: .lgPink, label: title, tagline: "Your LG. Your room. Your remote.", usesKnownColor: false)
    }

    private static func known(_ color: RGBColor, _ label: String, _ tagline: String) -> BrandIdentity {
        BrandIdentity(color: color, label: label, tagline: tagline, usesKnownColor: true)
    }
}
