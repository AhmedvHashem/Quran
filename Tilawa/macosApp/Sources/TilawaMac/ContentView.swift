import Shared
import SwiftUI

struct ContentView: View {
    private let sections = ["Home", "Library", "Settings"]
    @State private var selection: String? = "Home"

    var body: some View {
        NavigationSplitView {
            List(sections, id: \.self, selection: $selection) { section in
                Label(section, systemImage: "circle")
            }
            .navigationTitle("Tilawa")
        } detail: {
            VStack(spacing: 16) {
                Text(selection ?? "Tilawa")
                    .font(.largeTitle)
                Text(Greeting().greet())
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    ContentView()
}
