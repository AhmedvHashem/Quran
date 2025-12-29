import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()
    @StateObject var audioPlayer = AudioPlayer()
    
    var body: some View {
        NavigationView {
            SidebarView(viewModel: viewModel)
            ReadingView(viewModel: viewModel)
        }
        .frame(minWidth: 800, minHeight: 600)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar) {
                    Image(systemName: "sidebar.left")
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            PlayerView(viewModel: viewModel)
                .environmentObject(audioPlayer)
        }
    }
    
    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}
