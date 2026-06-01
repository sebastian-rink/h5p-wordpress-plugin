import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var paceSettings: PaceSettings
    @Environment(\.dismiss) var dismiss

    private let paceOptions = Array(stride(from: 180, through: 540, by: 5))
    private let toleranceOptions = [15, 20, 30, 45, 60]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Einstellungen").font(.headline)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Zieltempo (min/km)").font(.caption).foregroundColor(.secondary)
                    Picker("Zieltempo", selection: $paceSettings.targetPaceSeconds) {
                        ForEach(paceOptions, id: \.self) { s in Text(PaceSettings.format(s)).tag(s) }
                    }.labelsHidden()
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Toleranz (±Sek/km)").font(.caption).foregroundColor(.secondary)
                    Picker("Toleranz", selection: $paceSettings.toleranceSeconds) {
                        ForEach(toleranceOptions, id: \.self) { s in Text("±\(s) s").tag(s) }
                    }.labelsHidden()
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Vibrations-Signale").font(.caption).foregroundColor(.secondary)
                    Text("↑  Schneller laufen\n✓  Im Zieltempo\n↓  Langsamer laufen").font(.caption2)
                }
                Button("Fertig") { dismiss() }.buttonStyle(.borderedProminent).tint(.blue)
            }.padding(.horizontal)
        }
    }
}
