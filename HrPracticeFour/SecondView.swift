import SwiftUI
import HealthKit

struct SecondView: View {
    private let healthKitManager = HealthKitManager()
    @State private var heartRate: Double? // Stores the fetched heart rate
    @State private var errorMessage: String? // Stores any error message

    init() {
        healthKitManager.isMockMode = true // Enable mock mode for testing
    }

    var body: some View {
        VStack {
            Spacer()

            Text("Heart Rate")
                .font(.largeTitle)
                .bold()
                .padding()

            if let heartRate = heartRate {
                Text("\(Int(heartRate)) BPM")
                    .font(.title)
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

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .navigationTitle("Heart Rate Page")
        .onAppear {
            startLiveUpdates()
        }
    }

    private func startLiveUpdates() {
        healthKitManager.startLiveHeartRateUpdates { rate, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Failed to get live updates: \(error.localizedDescription)"
                } else if let rate = rate {
                    self.heartRate = rate
                } else {
                    self.errorMessage = "No heart rate data available."
                }
            }
        }
    }
}
