import UserNotifications

@MainActor
final class NotificationManager {
    static let shared = NotificationManager()

    func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func sendAlert() async {
        let content = UNMutableNotificationContent()
        content.title = "TrumpWatch"
        content.body = "President Donald J. Trump is no longer President of the United States."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "departure",
            content: content,
            trigger: nil
        )
        try? await UNUserNotificationCenter.current().add(request)
    }
}
