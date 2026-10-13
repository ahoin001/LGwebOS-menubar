import SwiftUI
import LGwebOSCore
import LGwebOSUI

struct WakeSetupScreen: View {
    let model: RemoteCoordinator
    @State private var draft = ""
    @State private var rejected = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            RemoteCard {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Turn the TV on from this phone", systemImage: "power").font(.headline)
                    Text("The phone can wake the TV only when it has the TV’s Wi-Fi MAC address. Volume and apps work without it once the TV is already on.")
                        .font(.subheadline).foregroundStyle(RemotePalette.muted)
                    TextField("Wi-Fi MAC address", text: $draft)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .font(.body.monospaced())
                    if rejected {
                        Text("Use six pairs of letters and numbers, like AA:BB:CC:DD:EE:FF.")
                            .font(.footnote).foregroundStyle(.orange)
                    }
                    Button("Save MAC address") { save() }
                        .buttonStyle(.borderedProminent)
                        .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            RemoteCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("On the TV").font(.headline)
                    Text("All Settings → General → Devices → External Devices → TV On With Mobile → Turn on via Wi-Fi.")
                        .font(.subheadline).foregroundStyle(RemotePalette.muted)
                    Text("The address is in the TV’s network details, on the same screen as the IP address.")
                        .font(.footnote).foregroundStyle(RemotePalette.muted)
                }
            }
        }
        .onAppear { draft = model.identity.mac }
    }

    private func save() {
        rejected = !model.saveWakeAddress(draft)
        if !rejected, let formatted = HostAddress.normalizedMAC(draft) { draft = formatted }
    }
}
