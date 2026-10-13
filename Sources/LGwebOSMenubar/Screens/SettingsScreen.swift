import AppKit
import SwiftUI
import LGwebOSCore
import LGwebOSUI

struct SettingsScreen: View {
    let model: RemoteCoordinator
    let close: () -> Void
    @State private var draftHost = ""
    @State private var draftName = ""
    @State private var draftMAC = ""
    @State private var showEvents = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RemoteCard {
                HStack(spacing: 13) {
                    BrandImage(name: "lg", width: 38, height: 38)
                    VStack(alignment: .leading, spacing: 5) {
                        Text(model.identity.model.isEmpty ? "LG TV" : "LG \(model.identity.model)").font(.system(size: 14, weight: .semibold))
                        Text([model.session.webOS, model.session.firmware].filter { !$0.isEmpty }.joined(separator: " · "))
                            .font(.system(size: 10)).foregroundStyle(RemotePalette.muted)
                    }
                    Spacer()
                }
            }
            RemoteSectionTitle("CONNECTION")
            RemoteCard {
                VStack(alignment: .leading, spacing: 11) {
                    Text("Your TV").fontWeight(.semibold)
                    TextField("Name", text: $draftName).textFieldStyle(.roundedBorder)
                    TextField("TV IP address", text: $draftHost).textFieldStyle(.roundedBorder)
                    TextField("Wi-Fi MAC address for wake", text: $draftMAC).textFieldStyle(.roundedBorder)
                    Text("Optional: the MAC address is only needed to wake the TV.").font(.system(size: 10)).foregroundStyle(RemotePalette.muted)
                    Button("Save and connect", action: save)
                        .disabled(!HostAddress.isLocalIPv4(draftHost.trimmingCharacters(in: .whitespacesAndNewlines)) || model.session.connecting)
                    if !model.identity.host.isEmpty {
                        Button("Forget pairing", action: forget).disabled(model.session.connecting)
                    }
                }
            }
            RemoteCard {
                VStack(alignment: .leading, spacing: 11) {
                    Button(model.discovering ? "Searching for TVs…" : "Find TVs on your network") { model.discover() }
                        .disabled(model.discovering)
                    ForEach(model.devices) { device in
                        Button { model.select(device); close() } label: {
                            HStack { Text(device.name); Spacer(); Text(device.host).foregroundStyle(RemotePalette.muted) }
                        }
                        .buttonStyle(.plain)
                    }
                    Text("To wake your TV from your Mac, enable Wi-Fi wake in TV settings.").font(.system(size: 11)).foregroundStyle(RemotePalette.muted)
                }
            }
            DisclosureGroup("Event history", isExpanded: $showEvents) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("LGwebOS-menubar connections and actions saved on this Mac. Internal TV logs require developer mode.")
                        .font(.system(size: 11)).foregroundStyle(RemotePalette.muted)
                    RemoteCard {
                        LazyVStack(alignment: .leading, spacing: 13) {
                            ForEach(model.activity.events.filter { $0.title != "Read" }) { event in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(event.title).fontWeight(.semibold)
                                        Spacer()
                                        Text(event.date, style: .time).foregroundStyle(RemotePalette.muted).monospacedDigit()
                                    }
                                    Text(event.detail).font(.system(size: 10)).foregroundStyle(RemotePalette.muted).lineLimit(3).textSelection(.enabled)
                                }
                                .font(.system(size: 11))
                            }
                            if model.activity.events.isEmpty { Text("No events yet.").foregroundStyle(RemotePalette.muted).padding(.vertical, 12) }
                        }
                    }
                }
                .padding(.top, 10)
            }
            .font(.system(size: 11))
        }
        .onAppear {
            draftHost = model.identity.host
            draftName = model.identity.name
            draftMAC = model.identity.mac
        }
    }

    private func save() {
        model.disconnect()
        model.identity.model = ""
        model.session.resetSoftwareIdentity()
        model.identity.host = draftHost.trimmingCharacters(in: .whitespacesAndNewlines)
        let name = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
        model.identity.name = name.isEmpty ? "LG TV" : name
        model.identity.mac = draftMAC.trimmingCharacters(in: .whitespacesAndNewlines)
        model.connect()
        close()
    }

    private func forget() {
        let alert = NSAlert()
        alert.messageText = "Forget this TV's pairing?"
        alert.informativeText = "The saved key and certificate for this TV will be removed from this Mac. You can connect and pair again."
        alert.addButton(withTitle: "Forget pairing")
        alert.addButton(withTitle: "Cancel")
        guard alert.runModal() == .alertFirstButtonReturn else { return }
        Task { await model.forgetPairing() }
    }
}
