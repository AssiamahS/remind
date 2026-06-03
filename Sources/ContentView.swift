import SwiftUI

struct ContentView: View {
    @StateObject private var store = ReminderStore()
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.1, green: 0.1, blue: 0.18).ignoresSafeArea()

                if store.reminders.isEmpty {
                    VStack {
                        Spacer()
                        Text("No reminders")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(store.reminders) { reminder in
                            ReminderRow(reminder: reminder) {
                                store.toggle(id: reminder.id)
                            }
                            .listRowBackground(Color(red: 0.09, green: 0.13, blue: 0.24))
                            .listRowSeparatorTint(Color.white.opacity(0.08))
                        }
                        .onDelete { store.delete(at: $0) }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
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
                    EditButton().foregroundColor(.purple)
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddReminderSheet(store: store, isPresented: $showingAdd)
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct ReminderRow: View {
    let reminder: Reminder
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button(action: onToggle) {
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
    @ObservedObject var store: ReminderStore
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
                    Button("Cancel") { isPresented = false }.foregroundColor(.gray)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        let t = title.trimmingCharacters(in: .whitespaces)
                        guard !t.isEmpty else { return }
                        store.add(Reminder(title: t, time: time))
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
