import SwiftUI
import LGwebOSCore
import LGwebOSUI

struct LogsScreen: View {
    let model: RemoteCoordinator
    @State private var scope: LogScope = .connection
    @State private var confirmClear = false

    var body: some View {
        let groups = LogDayGroup.make(from: model.activity.events, scope: scope)
        List {
            if groups.isEmpty {
                Section {
                    LogEmptyState(scope: scope)
                }
            } else {
                ForEach(groups) { group in
                    Section(group.title) {
                        ForEach(group.events) { event in
                            LogEntryRow(event: event)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(RemoteBackground())
        .safeAreaInset(edge: .top, spacing: 0) {
            LogScopePicker(scope: $scope)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if !model.activity.events.isEmpty {
                Button("Clear log", role: .destructive) { confirmClear = true }
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.bar)
            }
        }
        .confirmationDialog("Clear the log on this iPhone?", isPresented: $confirmClear, titleVisibility: .visible) {
            Button("Clear log", role: .destructive) { model.activity.clear() }
        } message: {
            Text("This removes connection and command entries saved on this iPhone.")
        }
    }
}

private struct LogScopePicker: View {
    @Binding var scope: LogScope

    var body: some View {
        Picker("Show", selection: $scope) {
            Text("Connection").tag(LogScope.connection)
            Text("Commands").tag(LogScope.commands)
            Text("All").tag(LogScope.all)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.bar)
    }
}

private struct LogEmptyState: View {
    let scope: LogScope

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(scope == .connection ? "No connection entries yet" : "Nothing in this view")
                .font(.headline)
            Text("Connect to the TV. Each step, including a rejection from the TV, is saved here. Pairing keys are not included.")
                .font(.subheadline)
                .foregroundStyle(RemotePalette.muted)
        }
        .padding(.vertical, 8)
    }
}

private struct LogEntryRow: View {
    let event: RemoteEvent

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: LogKind.symbol(for: event.title))
                .font(.body.weight(.semibold))
                .foregroundStyle(LogKind.tint(for: event.title))
                .frame(width: 22)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(event.title)
                        .font(.subheadline.weight(.semibold))
                    Spacer(minLength: 8)
                    Text(event.date, format: .dateTime.hour().minute().second())
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(RemotePalette.muted)
                }
                Text(event.detail)
                    .font(.subheadline)
                    .foregroundStyle(RemotePalette.ink)
                    .textSelection(.enabled)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

private enum LogScope: Hashable {
    case connection
    case commands
    case all

    func includes(_ title: String) -> Bool {
        switch self {
        case .all:
            return title != "Read"
        case .connection:
            return LogKind.connectionTitles.contains(title)
        case .commands:
            return title == "Command" || title == "Command failed" || title == "Error"
        }
    }
}

private enum LogKind {
    static let connectionTitles: Set<String> = [
        "Connecting", "Certificate", "Socket open", "Register", "Pairing prompt",
        "Pairing rejected", "Connected", "Connection failed", "Connection lost",
        "Reconnecting", "Remote ready", "Remote unavailable"
    ]

    static func symbol(for title: String) -> String {
        switch title {
        case "Connecting", "Reconnecting":
            return "arrow.triangle.2.circlepath"
        case "Socket open", "Connected", "Remote ready":
            return "checkmark.circle"
        case "Connection failed", "Connection lost", "Pairing rejected", "Remote unavailable", "Command failed", "Error":
            return "exclamationmark.circle"
        case "Certificate", "Register", "Pairing prompt":
            return "checkmark.shield"
        case "Command":
            return "bolt"
        default:
            return "text.alignleft"
        }
    }

    static func tint(for title: String) -> Color {
        switch title {
        case "Socket open", "Connected", "Remote ready", "Pairing prompt":
            return .green
        case "Connection failed", "Connection lost", "Pairing rejected", "Remote unavailable", "Command failed", "Error":
            return .orange
        default:
            return RemotePalette.muted
        }
    }
}

private struct LogDayGroup: Identifiable {
    let day: Date
    let events: [RemoteEvent]
    var id: Date { day }

    var title: String {
        if Calendar.current.isDateInToday(day) { return "Today" }
        if Calendar.current.isDateInYesterday(day) { return "Yesterday" }
        return day.formatted(date: .abbreviated, time: .omitted)
    }

    static func make(from events: [RemoteEvent], scope: LogScope) -> [LogDayGroup] {
        let calendar = Calendar.current
        var groups: [LogDayGroup] = []
        for event in events where scope.includes(event.title) {
            let day = calendar.startOfDay(for: event.date)
            if let index = groups.lastIndex(where: { $0.day == day }) {
                groups[index] = LogDayGroup(day: day, events: groups[index].events + [event])
            } else {
                groups.append(LogDayGroup(day: day, events: [event]))
            }
        }
        return groups
    }
}
