import Foundation
import Observation

@MainActor
@Observable
public final class PictureController {
    public private(set) var values: [String: Int] = [:]
    public private(set) var applying = false
    weak var commands: TVCommanding?

    public init() {}

    public func refresh() async {
        guard let commands, commands.isConnected, let client = commands.client else { return }
        await refresh(client)
    }

    func refresh(_ client: WebOSConnection) async {
        let payload = ["category": "picture", "keys": SSAP.Picture.keys] as [String: Any]
        if let result = try? await client.request(SSAP.Picture.get, payload) {
            values = SSAPPayload.picture(result)
        }
    }

    public func apply(_ settings: [String: Int]) {
        guard let commands, commands.isConnected, let client = commands.client, !applying else { return }
        let validated = settings.filter { SSAP.Picture.allowed.contains($0.key) }.mapValues { min(100, max(0, $0)) }
        applying = true
        commands.clearError()
        Task { [weak self] in
            guard let self else { return }
            defer { self.applying = false }
            do {
                _ = try await client.request(SSAP.Picture.set, ["category": "picture", "settings": validated])
                await self.refresh(client)
                guard validated.allSatisfy({ self.values[$0.key] == $0.value }) else {
                    throw RemoteError.message("The TV did not confirm these settings. The displayed values have been read again.")
                }
                commands.reportNotice("Picture updated.")
                commands.log("Picture", "Picture settings applied.")
            } catch {
                await self.refresh(client)
                commands.reportError("Settings are unavailable on this connection: \(error.localizedDescription)")
            }
        }
    }
}
