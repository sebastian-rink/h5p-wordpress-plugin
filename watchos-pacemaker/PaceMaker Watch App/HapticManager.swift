import WatchKit
import Foundation

class HapticManager {
    static let shared = HapticManager()

    private var lastZone: PaceZone?
    private var lastHapticDate: Date = .distantPast
    private let repeatInterval: TimeInterval = 12

    private init() {}

    func update(zone: PaceZone) {
        let now = Date()
        let zoneChanged = zone != lastZone
        let repeatDue = now.timeIntervalSince(lastHapticDate) >= repeatInterval

        guard zoneChanged || (repeatDue && zone != .onTarget && zone != .idle) else { return }

        lastZone = zone
        lastHapticDate = now

        switch zone {
        case .tooSlow:
            WKInterfaceDevice.current().play(.directionUp)
        case .tooFast:
            WKInterfaceDevice.current().play(.directionDown)
        case .onTarget:
            WKInterfaceDevice.current().play(.success)
        case .idle:
            break
        }
    }

    func reset() {
        lastZone = nil
        lastHapticDate = .distantPast
    }
}
