import SwiftUI
import LGwebOSCore
#if os(macOS)
import AppKit
#else
import UIKit
#endif

public struct AppMark: View {
    private let app: TVApp
    private let size: CGFloat
    public init(app: TVApp, size: CGFloat = 36) {
        self.app = app
        self.size = size
    }
    public var body: some View {
        Group {
            if let filename = app.icon,
               let url = AppResources.bundle.url(forResource: filename, withExtension: nil, subdirectory: "AppAssets"),
               let image = BundledImage.make(url) {
                image.resizable().interpolation(.high).scaledToFit()
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.08))
                    Image(systemName: "app").foregroundStyle(RemotePalette.muted)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.23))
        .accessibilityHidden(true)
    }
}

public struct BrandImage: View {
    private let name: String
    private let width: CGFloat
    private let height: CGFloat
    public init(name: String, width: CGFloat = 28, height: CGFloat = 28) {
        self.name = name
        self.width = width
        self.height = height
    }
    public var body: some View {
        Group {
            if let url = AppResources.bundle.url(forResource: name, withExtension: "png", subdirectory: "AppAssets"),
               let image = BundledImage.make(url) {
                image.resizable().interpolation(.high).scaledToFit()
            }
        }
        .frame(width: width, height: height)
        .accessibilityHidden(true)
    }
}

enum BundledImage {
    static func make(_ url: URL) -> Image? {
        #if os(macOS)
        guard let image = NSImage(contentsOf: url) else { return nil }
        return Image(nsImage: image)
        #else
        guard let image = UIImage(contentsOfFile: url.path) else { return nil }
        return Image(uiImage: image)
        #endif
    }
}
