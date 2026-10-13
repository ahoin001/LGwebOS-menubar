import AppKit
import LGwebOSCore

let app = NSApplication.shared
if CommandLine.arguments.contains("--help") {
    print("""
    LGwebOS-menubar — a macOS menu bar remote for LG webOS TVs

    Run the app normally to discover or configure your TV in Settings.
    --background   Start without showing the panel.
    --self-check   Run offline checks without accessing a TV or saved pairing.
    --diagnose --host <tv-ip> [--report <file>] [--check-home] [--trust-new-tv]
                   Run read-only TV diagnostics. A new TV needs explicit certificate
                   approval with --trust-new-tv and pairing approval on the TV.
                   Diagnostic reports contain local device information.
    """)
} else if CommandLine.arguments.contains("--self-check") {
    Task {
        do { try await FeatureChecks.run(); exit(0) }
        catch { print("FAIL: \(error)"); exit(1) }
    }
    RunLoop.main.run()
} else if CommandLine.arguments.contains("--diagnose") {
    Task { @MainActor in
        guard let hostIndex = CommandLine.arguments.firstIndex(of: "--host"), CommandLine.arguments.count > hostIndex + 1,
              WebOSConnection.localHost(CommandLine.arguments[hostIndex + 1]) else {
            print("ERROR: use --diagnose --host <tv-ip> with the TV's local IPv4 address.")
            exit(2)
        }
        let host = CommandLine.arguments[hostIndex + 1]
        let client = WebOSConnection(host: host)
        client.onPairing = { print("PAIRING: accept LG Remote App on your TV."); fflush(stdout) }
        client.onCertificateTrust = { host, fingerprint in await ConnectionTrustPrompt.confirm(host: host, fingerprint: fingerprint) }
        do {
            try await client.connect(allowFirstUseTrust: CommandLine.arguments.contains("--trust-new-tv"))
            print("PAIRED: connection authorized; pairing stored in Keychain.")
            let system = try? await client.request(SSAP.System.info)
            let volume = try await client.request(SSAP.Audio.getVolume)
            let apps = try await client.request(SSAP.System.listApps)
            let inputs = try? await client.request(SSAP.Inputs.list)
            let foreground = try? await client.request(SSAP.Launcher.foreground)
            var homeStates: [String: Any] = [:]
            if CommandLine.arguments.contains("--check-home") {
                for id in ["com.webos.app.home", "com.webos.app.fullhome", SSAPPayload.foregroundAppID(foreground ?? [:])] where !id.isEmpty {
                    do { homeStates[id] = try await client.request(SSAP.Launcher.appState, ["id": id]) }
                    catch { homeStates[id] = ["error": error.localizedDescription] }
                }
            }
            var pointerError: String?
            do { try await client.checkPointer() } catch { pointerError = error.localizedDescription }
            let report: [String: Any] = [
                "host": host,
                "system": system ?? [:],
                "volume": volume,
                "apps": apps,
                "inputs": inputs ?? [:],
                "foreground": foreground ?? [:],
                "homeStates": homeStates,
                "pointerAvailable": pointerError == nil,
                "pointerError": pointerError ?? "",
            ]
            let data = try JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted, .sortedKeys])
            if let index = CommandLine.arguments.firstIndex(of: "--report"), CommandLine.arguments.count > index + 1 {
                try data.write(to: URL(fileURLWithPath: CommandLine.arguments[index + 1]))
            }
            print("DIAGNOSIS: TV metadata read; navigation channel \(pointerError == nil ? "ready" : "unavailable").")
            client.close()
            exit(0)
        } catch {
            print("ERROR: \(error.localizedDescription)")
            client.close()
            exit(1)
        }
    }
    RunLoop.main.run()
} else {
    let delegate = MainActor.assumeIsolated { AppDelegate() }
    app.delegate = delegate
    withExtendedLifetime(delegate) { app.run() }
}
