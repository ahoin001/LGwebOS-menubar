import SwiftUI
import LGwebOSCore
import LGwebOSUI

struct SettingsScreen: View {
    let model: RemoteCoordinator
    @Environment(\.dismiss) private var dismiss
    @State private var draftHost = ""
    @State private var draftName = ""
    @State private var draftMAC = ""
    @State private var confirmForget = false
    @State private var guide = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Your TV") {
                    TextField("Name", text: $draftName)
                    TextField("TV IP address", text: $draftHost)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.numbersAndPunctuation)
                    TextField("Wi-Fi MAC address for wake", text: $draftMAC)
                        .textInputAutocapitalization(.never)
                    Text("The MAC address is only needed to wake the TV.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
                Section {
                    Button("How to find your TV") { guide = true }
                } footer: {
                    Text("To wake the TV, enable Wi-Fi wake in the TV settings.")
                }
                if !model.identity.host.isEmpty {
                    Section {
                        Button("Forget pairing", role: .destructive) { confirmForget = true }
                            .disabled(model.session.connecting)
                    }
                }
                Section("This connection") {
                    LabeledContent("Model", value: model.identity.model.isEmpty ? "LG TV" : model.identity.model)
                    LabeledContent("webOS", value: [model.session.webOS, model.session.firmware].filter { !$0.isEmpty }.joined(separator: " · "))
                    LabeledContent("Status", value: model.statusText)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save and connect", action: save)
                        .disabled(!HostAddress.isLocalIPv4(draftHost.trimmingCharacters(in: .whitespacesAndNewlines)) || model.session.connecting)
                }
            }
            .confirmationDialog("Forget this TV's pairing?", isPresented: $confirmForget, titleVisibility: .visible) {
                Button("Forget pairing", role: .destructive) { Task { await model.forgetPairing() } }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("The saved key and certificate for this TV will be removed from this device. You can connect and pair again.")
            }
            .sheet(isPresented: $guide, onDismiss: loadDrafts) {
                SetupWizard(model: model, allowsDismiss: true)
            }
            .onAppear(perform: loadDrafts)
        }
    }

    private func loadDrafts() {
        draftHost = model.identity.host
        draftName = model.identity.name
        draftMAC = model.identity.mac
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
        dismiss()
    }
}
