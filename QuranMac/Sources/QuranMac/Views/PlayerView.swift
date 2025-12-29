import SwiftUI

struct PlayerView: View {
    @ObservedObject var viewModel: ContentViewModel
    @EnvironmentObject var audioPlayer: AudioPlayer
    
    var body: some View {
        HStack(spacing: 20) {
            // Album Art / Info
            HStack {
                Rectangle()
                    .fill(Color.green.opacity(0.8))
                    .frame(width: 50, height: 50)
                    .cornerRadius(4)
                    .overlay(
                        Image(systemName: "music.note")
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading) {
                    Text(audioPlayer.currentChapterName ?? "Select Surah")
                        .font(.headline)
                    Text(audioPlayer.currentReciterName ?? "Select Reciter")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 200, alignment: .leading)
            
            Spacer()
            
            // Controls
            HStack(spacing: 30) {
                Button(action: {
                    // Previous
                }) {
                    Image(systemName: "backward.fill")
                        .font(.title2)
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    if audioPlayer.isPlaying {
                        audioPlayer.pause()
                    } else if audioPlayer.currentChapterName != nil {
                        audioPlayer.resume()
                    } else {
                        // Trigger play if nothing playing but chapter selected
                        Task {
                            await viewModel.playChapterAudio(audioPlayer: audioPlayer)
                        }
                    }
                }) {
                    Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    // Next
                }) {
                    Image(systemName: "forward.fill")
                        .font(.title2)
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
            
            // Reciter Selector & Volume
            HStack {
                Picker("", selection: $viewModel.selectedReciter) {
                    ForEach(viewModel.reciters) { reciter in
                        Text(reciter.reciterName).tag(reciter as Reciter?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 150)
                .onChange(of: viewModel.selectedReciter) { _ in
                    // Stop current and maybe auto play new?
                    audioPlayer.pause()
                }
                
                Image(systemName: "speaker.wave.2.fill")
                    .foregroundColor(.secondary)
            }
            .frame(width: 200, alignment: .trailing)
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .overlay(Rectangle().frame(height: 1).foregroundColor(Color(NSColor.separatorColor)), alignment: .top)
    }
}
