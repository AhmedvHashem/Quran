import Shared
import SwiftUI

struct ContentView: View {
    @State private var status = "Loading reciters…"
    private let library = QuranLibrary()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if status.hasPrefix("Loading") {
                    ProgressView()
                }
                Text(status)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .navigationTitle("Tilawa")
            .task { await loadReciters() }
        }
    }

    @MainActor
    private func loadReciters() async {
        do {
            let result = try await library.reciters()
            guard !Task.isCancelled else { return }
            status = result.failure?.message ?? "\(result.reciters.count) reciters available"
        } catch is CancellationError {
            return
        } catch {
            status = "Could not load reciters: \(error.localizedDescription)"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
