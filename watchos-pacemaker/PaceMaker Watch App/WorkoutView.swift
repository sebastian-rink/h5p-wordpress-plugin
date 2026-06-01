import SwiftUI

struct WorkoutView: View {
    @EnvironmentObject var paceSettings: PaceSettings
    @EnvironmentObject var workoutManager: WorkoutManager

    private var zone: PaceZone { paceSettings.zone(for: workoutManager.currentPaceSecondsPerKm) }

    private var zoneColor: Color {
        switch zone {
        case .tooSlow: return .orange
        case .onTarget: return .green
        case .tooFast: return .blue
        case .idle: return .secondary
        }
    }
    private var zoneLabel: String {
        switch zone {
        case .tooSlow: return "Schneller!"
        case .onTarget: return "Im Tempo ✓"
        case .tooFast: return "Langsamer!"
        case .idle: return "Warte auf GPS…"
        }
    }
    private var zoneIcon: String {
        switch zone {
        case .tooSlow: return "arrow.up.circle.fill"
        case .onTarget: return "checkmark.circle.fill"
        case .tooFast: return "arrow.down.circle.fill"
        case .idle: return "location.circle"
        }
    }

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: zoneIcon).foregroundColor(zoneColor)
                Text(zoneLabel).font(.caption.weight(.semibold)).foregroundColor(zoneColor)
            }
            VStack(spacing: 1) {
                Text(formatPace(workoutManager.currentPaceSecondsPerKm))
                    .font(.system(size: 38, weight: .bold, design: .monospaced))
                    .foregroundColor(zoneColor).minimumScaleFactor(0.6)
                Text("min/km  (Ziel: \(paceSettings.formatted))").font(.caption2).foregroundColor(.secondary)
            }
            HStack(spacing: 12) {
                statCell(value: formatDistance(workoutManager.distanceMeters), label: "km")
                statCell(value: formatTime(workoutManager.elapsedSeconds), label: "Zeit")
                if workoutManager.heartRate > 0 {
                    statCell(value: "\(Int(workoutManager.heartRate))", label: "♥︎")
                }
            }
            Button("Stopp") { HapticManager.shared.reset(); workoutManager.stopWorkout() }
                .buttonStyle(.borderedProminent).tint(.red)
        }
        .onChange(of: zone) { newZone in HapticManager.shared.update(zone: newZone) }
        .onAppear { HapticManager.shared.reset() }
    }

    @ViewBuilder
    private func statCell(value: String, label: String) -> some View {
        VStack(spacing: 1) {
            Text(value).font(.caption.weight(.semibold))
            Text(label).font(.caption2).foregroundColor(.secondary)
        }
    }
    private func formatPace(_ s: Double) -> String {
        guard s > 0 else { return "--:--" }
        let t = Int(s)
        return String(format: "%d:%02d", t / 60, t % 60)
    }
    private func formatDistance(_ m: Double) -> String { String(format: "%.2f", m / 1000) }
    private func formatTime(_ s: Int) -> String {
        let h = s / 3600, m = (s % 3600) / 60, sec = s % 60
        return h > 0 ? String(format: "%d:%02d:%02d", h, m, sec) : String(format: "%02d:%02d", m, sec)
    }
}
