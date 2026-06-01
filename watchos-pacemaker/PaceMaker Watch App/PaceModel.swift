import Foundation

enum PaceZone: Equatable {
    case idle
    case tooSlow
    case onTarget
    case tooFast
}

class PaceSettings: ObservableObject {
    @Published var targetPaceSeconds: Int = 360
    @Published var toleranceSeconds: Int = 30

    var formatted: String { Self.format(targetPaceSeconds) }

    static func format(_ totalSeconds: Int) -> String {
        String(format: "%d:%02d", totalSeconds / 60, totalSeconds % 60)
    }

    func zone(for paceSecondsPerKm: Double) -> PaceZone {
        guard paceSecondsPerKm > 0 else { return .idle }
        let lower = Double(targetPaceSeconds - toleranceSeconds)
        let upper = Double(targetPaceSeconds + toleranceSeconds)
        if paceSecondsPerKm < lower { return .tooFast }
        if paceSecondsPerKm > upper { return .tooSlow }
        return .onTarget
    }
}
