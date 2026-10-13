import Foundation

public enum HomeNavigation {
    public static func shouldClose(_ appID: String, installedApps: Set<String>) -> Bool {
        !appID.isEmpty && installedApps.contains(appID) && !appID.hasPrefix("com.webos.") && !appID.hasPrefix("com.lge.")
    }

    @MainActor public static func run(
        appID: String,
        installedApps: Set<String>,
        closeApp: (String) async throws -> Void,
        pressHome: () async throws -> Void
    ) async throws {
        var closeError: Error?
        if shouldClose(appID, installedApps: installedApps) {
            do { try await closeApp(appID) } catch { closeError = error }
        }
        try Task.checkCancellation()
        try await pressHome()
        if let closeError {
            throw RemoteError.message("Home opened, but the TV could not close the app: \(closeError.localizedDescription)")
        }
    }
}
