import SwiftUI
import CoreGraphics
import ImageIO
import LGwebOSCore

public struct BrandTheme: Equatable {
    public let color: Color
    public let label: String
    public let tagline: String

    public static func forApp(_ id: String, title: String = "") -> BrandTheme {
        let identity = BrandIdentity.forApp(id, title: title)
        let sampled = identity.usesKnownColor ? nil : LogoSampler.colors[id]
        return BrandTheme(
            color: sampled ?? Color(webOS: identity.color),
            label: identity.label,
            tagline: identity.tagline
        )
    }
}

extension Color {
    init(webOS rgb: LGwebOSCore.RGBColor) {
        self.init(red: rgb.red, green: rgb.green, blue: rgb.blue)
    }
}

private enum LogoSampler {
    static let colors: [String: Color] = {
        var result: [String: Color] = [:]
        for app in AppResources.catalog() {
            guard let icon = app.icon,
                  let url = AppResources.bundle.url(forResource: icon, withExtension: nil, subdirectory: "AppAssets"),
                  let color = dominantColor(at: url) else { continue }
            result[app.id] = color
        }
        return result
    }()

    static func dominantColor(at url: URL) -> Color? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else { return nil }
        let width = image.width
        let height = image.height
        guard width > 0, height > 0 else { return nil }
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        guard let context = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        var buckets: [Int: (count: Int, r: CGFloat, g: CGFloat, b: CGFloat)] = [:]
        let stepX = max(1, width / 24)
        let stepY = max(1, height / 24)
        for y in stride(from: 0, to: height, by: stepY) {
            for x in stride(from: 0, to: width, by: stepX) {
                let index = (y * width + x) * 4
                let alpha = CGFloat(pixels[index + 3]) / 255
                guard alpha > 0.6 else { continue }
                let red = CGFloat(pixels[index]) / 255 / alpha
                let green = CGFloat(pixels[index + 1]) / 255 / alpha
                let blue = CGFloat(pixels[index + 2]) / 255 / alpha
                let hsb = hsb(red, green, blue)
                guard hsb.saturation > 0.25, hsb.brightness > 0.25 else { continue }
                let bucket = Int(hsb.hue * 20)
                let previous = buckets[bucket] ?? (0, 0, 0, 0)
                buckets[bucket] = (previous.count + 1, previous.r + red, previous.g + green, previous.b + blue)
            }
        }
        guard let best = buckets.values.max(by: { $0.count < $1.count }) else { return Color(white: 0.78) }
        let count = CGFloat(best.count)
        return Color(red: best.r / count, green: best.g / count, blue: best.b / count)
    }

    static func hsb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> (hue: CGFloat, saturation: CGFloat, brightness: CGFloat) {
        let maxValue = max(red, green, blue)
        let minValue = min(red, green, blue)
        let delta = maxValue - minValue
        let saturation = maxValue == 0 ? 0 : delta / maxValue
        var hue: CGFloat = 0
        if delta > 0 {
            if maxValue == red { hue = (green - blue) / delta }
            else if maxValue == green { hue = 2 + (blue - red) / delta }
            else { hue = 4 + (red - green) / delta }
            hue /= 6
            if hue < 0 { hue += 1 }
        }
        return (hue, saturation, maxValue)
    }
}
