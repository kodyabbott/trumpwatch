import SwiftUI
import BackgroundTasks

@main
struct TrumpWatchApp: App {
    @StateObject private var monitor = PresidencyMonitor.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(monitor)
                .preferredColorScheme(.dark)
                .task {
                    NotificationManager.shared.requestPermission()
                    monitor.check()
                    scheduleRefresh()
                }
        }
        .backgroundTask(.appRefresh("com.trumpwatch.refresh")) {
            await PresidencyMonitor.shared.performCheck()
            scheduleRefresh()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                monitor.check()
            }
        }
    }
}

private func scheduleRefresh() {
    let request = BGAppRefreshTaskRequest(identifier: "com.trumpwatch.refresh")
    request.earliestBeginDate = Date(timeIntervalSinceNow: 3600)
    try? BGTaskScheduler.shared.submit(request)
}
