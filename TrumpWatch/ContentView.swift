import SwiftUI

struct ContentView: View {
    @EnvironmentObject var monitor: PresidencyMonitor

    var body: some View {
        Group {
            if monitor.isStillPresident {
                MonitoringView()
            } else {
                DepartureView(date: monitor.departureDate)
            }
        }
        .animation(.easeInOut(duration: 0.8), value: monitor.isStillPresident)
    }
}

private struct MonitoringView: View {
    @EnvironmentObject var monitor: PresidencyMonitor
    @State private var pulsing = false

    var body: some View {
        ZStack {
            Color(white: 0.04)
                .ignoresSafeArea()

            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .stroke(.green.opacity(0.25), lineWidth: 2)
                    .scaleEffect(pulsing ? 5 : 0.1)
                    .opacity(pulsing ? 0 : 0.6)
                    .animation(
                        .easeOut(duration: 4)
                            .repeatForever(autoreverses: false)
                            .delay(Double(i) * 1.3),
                        value: pulsing
                    )
            }

            VStack(spacing: 24) {
                Text("Donald J. Trump is\ncurrently the President\nof the United States.")
                    .font(.system(size: 22, weight: .light, design: .serif))
                    .foregroundStyle(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)

                VStack(spacing: 8) {
                    Text(monitor.isChecking ? "Checking..." : "Monitoring")
                        .font(.system(size: 14))
                        .foregroundStyle(.green.opacity(monitor.isChecking ? 1 : 0.6))
                        .animation(.easeInOut(duration: 0.3), value: monitor.isChecking)

                    if let date = monitor.lastChecked {
                        Text("Last checked \(date.formatted(date: .omitted, time: .standard))")
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.2))
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { monitor.check() }
        .onAppear { pulsing = true }
    }
}

private struct DepartureView: View {
    let date: Date?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                Text("President Donald J. Trump\nis no longer President\nof the United States.")
                    .font(.system(size: 22, weight: .light, design: .serif))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)

                if let date {
                    Text(date.formatted(date: .long, time: .omitted))
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
            .padding(.horizontal, 40)
        }
    }
}
