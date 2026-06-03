import Foundation

final class ReminderStore: ObservableObject {
    @Published var reminders: [Reminder] = []

    private let saveURL: URL = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("reminders.json")
    }()

    init() {
        load()
        rescheduleAll()
    }

    func add(_ reminder: Reminder) {
        reminders.append(reminder)
        NotificationManager.schedule(reminder: reminder)
        save()
    }

    func toggle(id: UUID) {
        guard let i = reminders.firstIndex(where: { $0.id == id }) else { return }
        reminders[i].done.toggle()
        if reminders[i].done { NotificationManager.cancel(id: id) }
        save()
    }

    func delete(at offsets: IndexSet) {
        offsets.forEach { NotificationManager.cancel(id: reminders[$0].id) }
        reminders.remove(atOffsets: offsets)
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(reminders) else { return }
        try? data.write(to: saveURL)
    }

    private func load() {
        guard let data = try? Data(contentsOf: saveURL),
              let saved = try? JSONDecoder().decode([Reminder].self, from: data) else { return }
        reminders = saved
    }

    private func rescheduleAll() {
        reminders.filter { !$0.done }.forEach { NotificationManager.schedule(reminder: $0) }
    }
}
