import SwiftUI

struct ContentView: View {
    @EnvironmentObject var paceSettings: PaceSettings
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var showSettings = false
    @State private var authDenied = false

    var body: some View {
        if workoutManager.isActive {
            WorkoutView()
        } else {
            homeScreen
        }
    }

    private var homeScreen: some View {
        VStack(spacing: 10) {
            Text("PaceMaker")
                .font(.headline)
            VStack(spacing: 2) {
                Text("Zieltempo")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(paceSettings.formatted + " /km")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.green)
            }
            if authDenied {
                Text("HealthKit-Zugriff verweigert.\nBitte in Einstellungen aktivieren.")
                    .font(.caption2).foregroundColor(.red).multilineTextAlignment(.center)
            }
            Button("Starten") {
                workoutManager.requestAuthorization { granted in
                    if granted { workoutManager.startWorkout() } else { authDenied = true }
                }
            }
            .buttonStyle(.borderedProminent).tint(.green)
            Button { showSettings = true } label: {
                Label("Einstellungen", systemImage: "gearshape").font(.caption)
            }
            .buttonStyle(.borderless).foregroundColor(.secondary)
        }
        .sheet(isPresented: $showSettings) { SettingsView() }
    }
}
