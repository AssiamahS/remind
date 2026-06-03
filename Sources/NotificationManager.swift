import UserNotifications
import Foundation

struct NotificationManager {
    static func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    static func schedule(reminder: Reminder) {
        guard !reminder.done, let fireDate = parseTime(reminder.time) else { return }

        let content = UNMutableNotificationContent()
        content.title = "Sly Reminders"
        content.body = reminder.title
        content.sound = .default

        var comps = Calendar.current.dateComponents([.hour, .minute], from: fireDate)
        comps.second = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let request = UNNotificationRequest(identifier: reminder.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    static func cancel(id: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }

    // Parses "3:00 PM", "9:00 AM", "10:36pm", "10:36PM", "14:30", "9am"
    private static func parseTime(_ raw: String) -> Date? {
        // normalize: lowercase, collapse spaces around colon, insert space before am/pm if missing
        var s = raw.trimmingCharacters(in: .whitespaces)
        s = s.replacingOccurrences(of: #"(\d)(am|pm)"#, with: "$1 $2",
                                    options: .regularExpression)
        s = s.uppercased()

        let formats = ["h:mm a", "h:mma", "h a", "ha", "H:mm", "h:mm"]
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        for fmt in formats {
            df.dateFormat = fmt
            if let d = df.date(from: s) { return d }
        }
        return nil
    }
}
