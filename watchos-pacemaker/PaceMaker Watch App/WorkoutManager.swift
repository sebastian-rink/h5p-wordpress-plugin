import Foundation
import HealthKit

class WorkoutManager: NSObject, ObservableObject {
    let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    private var ticker: Timer?
    private var startDate: Date?

    @Published var isActive = false
    @Published var currentPaceSecondsPerKm: Double = 0
    @Published var distanceMeters: Double = 0
    @Published var heartRate: Double = 0
    @Published var elapsedSeconds: Int = 0

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let share: Set<HKSampleType> = [HKQuantityType.workoutType()]
        var read: Set<HKObjectType> = [
            HKQuantityType(.heartRate),
            HKQuantityType(.distanceWalkingRunning),
        ]
        if #available(watchOS 9.0, *) {
            read.insert(HKQuantityType(.runningSpeed))
        }
        healthStore.requestAuthorization(toShare: share, read: read) { ok, _ in
            DispatchQueue.main.async { completion(ok) }
        }
    }

    func startWorkout() {
        let config = HKWorkoutConfiguration()
        config.activityType = .running
        config.locationType = .outdoor

        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: config)
            builder = session?.associatedWorkoutBuilder()
        } catch { return }

        session?.delegate = self
        builder?.delegate = self
        builder?.dataSource = HKLiveWorkoutDataSource(
            healthStore: healthStore,
            workoutConfiguration: config
        )

        let now = Date()
        startDate = now
        session?.startActivity(with: now)
        builder?.beginCollection(withStart: now) { _, _ in }

        ticker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self, let start = self.startDate else { return }
            DispatchQueue.main.async {
                self.elapsedSeconds = Int(Date().timeIntervalSince(start))
            }
        }
    }

    func stopWorkout() {
        ticker?.invalidate()
        ticker = nil
        session?.end()
        builder?.endCollection(withEnd: Date()) { [weak self] _, _ in
            self?.builder?.finishWorkout { _, _ in
                DispatchQueue.main.async {
                    self?.isActive = false
                    self?.reset()
                }
            }
        }
    }

    private func reset() {
        currentPaceSecondsPerKm = 0
        distanceMeters = 0
        heartRate = 0
        elapsedSeconds = 0
        startDate = nil
    }
}

extension WorkoutManager: HKWorkoutSessionDelegate {
    func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didChangeTo toState: HKWorkoutSessionState,
        from fromState: HKWorkoutSessionState,
        date: Date
    ) {
        DispatchQueue.main.async { self.isActive = toState == .running }
    }
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {}
}

extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilder(
        _ workoutBuilder: HKLiveWorkoutBuilder,
        didCollectDataOf collectedTypes: Set<HKSampleType>
    ) {
        for type in collectedTypes {
            guard let qType = type as? HKQuantityType else { continue }
            let stats = workoutBuilder.statistics(for: qType)
            DispatchQueue.main.async {
                switch qType {
                case HKQuantityType(.heartRate):
                    self.heartRate = stats?.mostRecentQuantity()?
                        .doubleValue(for: HKUnit.count().unitDivided(by: .minute())) ?? 0
                case HKQuantityType(.distanceWalkingRunning):
                    self.distanceMeters = stats?.sumQuantity()?.doubleValue(for: .meter()) ?? 0
                default:
                    if #available(watchOS 9.0, *),
                       qType == HKQuantityType(.runningSpeed),
                       let ms = stats?.mostRecentQuantity()?
                           .doubleValue(for: HKUnit.meter().unitDivided(by: .second())),
                       ms > 0.3 {
                        self.currentPaceSecondsPerKm = 1000.0 / ms
                    }
                }
            }
        }
    }
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
}
