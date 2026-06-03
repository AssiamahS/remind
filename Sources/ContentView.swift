import SwiftUI

struct ContentView: View {
    @State private var reminders: [Reminder] = [
        Reminder(title: "Morning standup", time: "9:00 AM"),
        Reminder(title: "Take a break", time: "2:00 PM"),
    ]
    @State private var newTitle = ""
    @State private var newTime = ""
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.1, green: 0.1, blue: 0.18).ignoresSafeArea()

                VStack(spacing: 0) {
                    if reminders.isEmpty {
                        Spacer()
                        Text("No reminders yet")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        Spacer()
                    } else {
                        List {
                            ForEach($reminders) { $reminder in
                                ReminderRow(reminder: $reminder)
                                    .listRowBackground(Color(red: 0.09, green: 0.13, blue: 0.24))
                                    .listRowSeparatorTint(Color.white.opacity(0.08))
                            }
                            .onDelete { reminders.remove(atOffsets: $0) }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Sly Reminders")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color(red: 0.1, green: 0.1, blue: 0.18), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAdd = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(.purple)
                            .fontWeight(.semibold)
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                        .foregroundColor(.purple)
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddReminderSheet(reminders: $reminders, isPresented: $showingAdd)
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct ReminderRow: View {
    @Binding var reminder: Reminder

    var body: some View {
        HStack(spacing: 14) {
            Button(action: { reminder.done.toggle() }) {
                Image(systemName: reminder.done ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(reminder.done ? .green : .gray)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 3) {
                Text(reminder.title)
                    .foregroundColor(reminder.done ? .gray : .white)
                    .font(.body)
                    .strikethrough(reminder.done)
                if !reminder.time.isEmpty {
                    Text(reminder.time)
                        .foregroundColor(.purple)
                        .font(.caption)
                }
            }

            Spacer()
        }
        .padding(.vertical, 6)
    }
}

struct AddReminderSheet: View {
    @Binding var reminders: [Reminder]
    @Binding var isPresented: Bool
    @State private var title = ""
    @State private var time = ""
    @FocusState private var titleFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.1, green: 0.1, blue: 0.18).ignoresSafeArea()

                VStack(spacing: 16) {
                    TextField("What do you need to do?", text: $title)
                        .focused($titleFocused)
                        .padding()
                        .background(Color(red: 0.09, green: 0.13, blue: 0.24))
                        .cornerRadius(10)
                        .foregroundColor(.white)

                    TextField("Time (e.g. 3:00 PM)", text: $time)
                        .padding()
                        .background(Color(red: 0.09, green: 0.13, blue: 0.24))
                        .cornerRadius(10)
                        .foregroundColor(.white)

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("New Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(red: 0.1, green: 0.1, blue: 0.18), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { isPresented = false }
                        .foregroundColor(.gray)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        let r = Reminder(title: title, time: time)
                        NotificationManager.schedule(reminder: r)
                        reminders.append(r)
                        isPresented = false
                    }
                    .foregroundColor(.purple)
                    .fontWeight(.semibold)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { titleFocused = true }
        }
        .presentationDetents([.medium])
    }
}
