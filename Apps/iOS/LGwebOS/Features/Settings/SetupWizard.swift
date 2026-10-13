import SwiftUI
import LGwebOSCore
import LGwebOSUI

struct SetupWizard: View {
    let model: RemoteCoordinator
    var allowsDismiss: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var draftHost = ""
    @State private var draftName = ""
    @State private var draftMAC = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Use the same Wi-Fi as the TV. This app needs an IPv4 address, such as 192.168.0.20. Hostnames and IPv6 addresses are not accepted.")
                }
                Section("On the TV") {
                    Text("Open the network or connection-status screen and copy the IPv4 address. The label on the back of the set is the model number, not the address.")
                }
                Section("Other places to look") {
                    Text("Your router’s list of connected devices shows the same address. The Mac menu bar app can show it too.")
                }
                Section("This device") {
                    TextField("Name", text: $draftName)
                    TextField("TV IP address", text: $draftHost)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.numbersAndPunctuation)
                    TextField("Wi-Fi MAC address for wake", text: $draftMAC)
                        .textInputAutocapitalization(.never)
                    Text("The MAC address is only needed to wake the TV.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Section {
                    DisclosureGroup("Why this app can’t search for the TV") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("A wireless scan sends a multicast packet. Apple only allows that on iPhone and iPad when the app is signed with a paid Apple Developer account.")
                            Text("This copy is signed with a free personal Apple ID, so that scan is not included.")
                            Text("The remote, apps, inputs, picture, and cast still work after you enter the address.")
                            Text("A build signed with a paid account could turn Find TVs back on.")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                    }
                }
            }
            .navigationTitle("Find your TV")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if allowsDismiss {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { dismiss() }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save and connect", action: save)
                        .disabled(!HostAddress.isLocalIPv4(trimmedHost) || model.session.connecting)
                }
            }
            .interactiveDismissDisabled(!allowsDismiss)
            .onAppear {
                draftHost = model.identity.host
                draftName = model.identity.name
                draftMAC = model.identity.mac
            }
        }
    }

    private var trimmedHost: String {
        draftHost.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func save() {
        model.disconnect()
        model.identity.model = ""
        model.session.resetSoftwareIdentity()
        model.identity.host = trimmedHost
        let name = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
        model.identity.name = name.isEmpty ? "LG TV" : name
        model.identity.mac = draftMAC.trimmingCharacters(in: .whitespacesAndNewlines)
        model.connect()
        dismiss()
    }
}
