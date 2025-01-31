import SwiftUI
import HealthKit

struct ContentView: View {
    private let healthKitManager = HealthKitManager()
    @State private var heartRate: Double?
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            Text("Heart Rate")
                .font(.headline)
                .padding()

            if let heartRate = heartRate {
                Text("\(Int(heartRate)) BPM")
                    .font(.largeTitle)
                    .foregroundColor(.red)
                    .padding()
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                Text("Waiting for heart rate...")
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding()
            }

            Button(action: {
                stopWorkout()
            }) {
                Text("Stop Workout")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .onAppear {
            requestAuthorization()
        }
        .onReceive(NotificationCenter.default.publisher(for: .didReceiveHeartRate)) { notification in
            if let userInfo = notification.userInfo, let newHeartRate = userInfo["heartRate"] as? Double {
                self.heartRate = newHeartRate
            }
        }
    }

    private func requestAuthorization() {
        healthKitManager.requestAuthorization { success, error in
            if success {
                startWorkout()
            } else if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Authorization failed: \(error.localizedDescription)"
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Authorization not granted."
                }
            }
        }
    }

    private func startWorkout() {
        healthKitManager.startWorkoutSession { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Workout session failed: \(error.localizedDescription)"
                }
            }
        }
    }

    private func stopWorkout() {
        healthKitManager.stopWorkoutSession()
    }
}

#Preview {
    ContentView()
}
//test
