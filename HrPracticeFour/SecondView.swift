import SwiftUI

struct SecondView: View {
    @State private var heartRate: Double = 72 // Static heart rate value

    var body: some View {
        VStack {
            Spacer()

            Text("Heart Rate")
                .font(.largeTitle)
                .bold()
                .padding()

            Text("\(Int(heartRate)) BPM")
                .font(.title)
                .foregroundColor(.red)
                .padding()

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .navigationTitle("Heart Rate Page")
    }
}

#Preview {
    SecondView()
}
