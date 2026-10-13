import SwiftUI
import Observation

@MainActor
@Observable
final class CertificateApproval {
    struct Prompt: Identifiable, Equatable {
        let id = UUID()
        let host: String
        let fingerprint: String
    }

    private(set) var pending: Prompt?
    private var continuation: CheckedContinuation<Bool, Never>?

    func confirm(host: String, fingerprint: String) async -> Bool {
        if continuation != nil { resolve(false) }
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
            pending = Prompt(host: host, fingerprint: fingerprint)
        }
    }

    func resolve(_ approved: Bool) {
        continuation?.resume(returning: approved)
        continuation = nil
        pending = nil
    }
}

struct CertificateSheet: View {
    let prompt: CertificateApproval.Prompt
    let resolve: (Bool) -> Void
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Connect to the TV at \(prompt.host) on your local network? Accept the pairing request on that TV next. Its certificate fingerprint will be stored in this device's Keychain.")
                    .font(.body)
                Text(prompt.fingerprint)
                    .font(.system(.footnote, design: .monospaced))
                    .textSelection(.enabled)
                Spacer()
            }
            .padding(20)
            .navigationTitle("Trust this LG TV?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { resolve(false) } }
                ToolbarItem(placement: .confirmationAction) { Button("Trust and pair") { resolve(true) } }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
