import HealthKit

#if os(watchOS) // Ensure this code is only compiled for watchOS

class HealthKitManager: NSObject, HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {
    let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    private var workoutBuilder: HKLiveWorkoutBuilder?

    // Request authorization for HealthKit
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            completion(false, NSError(domain: "HealthKitManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Heart rate type not available"]))
            return
        }

        let workoutType = HKObjectType.workoutType() // ✅ No need for optional binding
        let readTypes: Set = [heartRateType, workoutType]
        let writeTypes: Set = [workoutType] // Workout sessions require write permission

        healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { success, error in
            completion(success, error)
        }
    }



    // Start workout session for live heart rate updates
    func startWorkoutSession(completion: @escaping (Bool, Error?) -> Void) {
        guard HKQuantityType.quantityType(forIdentifier: .heartRate) != nil else {
            completion(false, NSError(domain: "HealthKitManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Heart rate type not available"]))
            return
        }

        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .other
        configuration.locationType = .unknown

        do {
            let session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            session.delegate = self
            self.workoutSession = session

            let builder = session.associatedWorkoutBuilder()
            builder.delegate = self
            builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
            self.workoutBuilder = builder

            session.startActivity(with: Date())
            builder.beginCollection(withStart: Date()) { success, error in
                completion(success, error)
            }
        } catch {
            completion(false, error)
        }
    }

    // Stop Workout Session
    func stopWorkoutSession() {
        workoutSession?.end()
        workoutBuilder?.endCollection(withEnd: Date()) { success, error in
            self.workoutBuilder?.finishWorkout { _, _ in }
        }
    }

    // MARK: - HKWorkoutSessionDelegate
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout Session Failed: \(error.localizedDescription)")
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        // Handle state changes if necessary
    }

    // MARK: - HKLiveWorkoutBuilderDelegate
    @objc func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        // Required but not used in our case
    }

    @objc func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf types: Set<HKSampleType>) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate),
              types.contains(heartRateType),
              let statistics = workoutBuilder.statistics(for: heartRateType),
              let quantity = statistics.mostRecentQuantity() else { return }

        let heartRate = quantity.doubleValue(for: HKUnit(from: "count/min"))

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .didReceiveHeartRate, object: self, userInfo: ["heartRate": heartRate])
        }
    }
}

// Notification for heart rate updates
extension Notification.Name {
    static let didReceiveHeartRate = Notification.Name("didReceiveHeartRate")
}

#endif // End watchOS check
