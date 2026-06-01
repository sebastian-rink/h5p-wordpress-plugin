import SwiftUI

@main
struct PaceMakerApp: App {
    @StateObject private var paceSettings = PaceSettings()
    @StateObject private var workoutManager = WorkoutManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(paceSettings)
                .environmentObject(workoutManager)
        }
    }
}
