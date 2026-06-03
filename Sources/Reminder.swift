import Foundation

struct Reminder: Identifiable, Codable {
    var id = UUID()
    var title: String
    var time: String
    var done: Bool = false
}
