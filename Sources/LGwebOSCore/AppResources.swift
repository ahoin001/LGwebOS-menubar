import Foundation

public enum AppResources {
    public static let bundle: Bundle = {
        let names = ["LGwebOSCore_LGwebOSCore.bundle", "LGwebOSMenubar_LGwebOSCore.bundle"]
        let roots = [Bundle.main.resourceURL, Bundle.main.executableURL?.deletingLastPathComponent()]
        for root in roots.compactMap({ $0 }) {
            for name in names {
                if let packaged = Bundle(url: root.appendingPathComponent(name)) {
                    return packaged
                }
            }
        }
        return Bundle.module
    }()

    public static func catalog() -> [TVApp] {
        guard let url = bundle.url(forResource: "app-catalog", withExtension: "json"),
              let apps = try? JSONDecoder().decode([TVApp].self, from: Data(contentsOf: url)) else { return [] }
        return apps
    }
}
