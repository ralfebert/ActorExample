import SwiftUI

actor MessagesStore {
    var messages: [String] = ["hello"]

    func add(_ text: String) async {
        self.messages.append(text)
    }
}

class MessagesViewModel: ObservableObject {
    var messagesStore = MessagesStore()
    @Published var messages: [String] = []

    func reload() async {
        self.messages = await self.messagesStore.messages
    }
}

struct ContentView: View {
    @StateObject var messagesViewModel = MessagesViewModel()

    var body: some View {
        List {
            ForEach(messagesViewModel.messages, id: \.self) { msg in
                Text(msg)
            }
            Button("Simulate message in bg/via actor") {
                DispatchQueue.global(qos: .utility).async {
                    Task {
                        await self.messagesViewModel.messagesStore.add("123")
                    }
                }
                // TODO: how can the UI layer "observe" the storage actor /
                // be notified by it
            }
        }
        .task {
            await messagesViewModel.reload()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
