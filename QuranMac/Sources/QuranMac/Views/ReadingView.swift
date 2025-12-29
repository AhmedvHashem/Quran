import SwiftUI

struct ReadingView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else if let chapter = viewModel.selectedChapter {
                ScrollView {
                    LazyVStack(spacing: 20) {
                        Text("سورة \(chapter.nameArabic)")
                            .font(.system(size: 32, weight: .bold, design: .serif))
                            .padding(.top)
                        
                        Text(chapter.nameSimple)
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Divider()
                            .padding(.horizontal)
                        
                        if chapter.id != 1 && chapter.id != 9 {
                            Text("بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ")
                                .font(.system(size: 24, design: .serif))
                                .padding(.vertical)
                        }
                        Text(combinedVersesText)
                            .font(.system(size: 28, design: .serif))
                            .multilineTextAlignment(.trailing)
                            .lineSpacing(12)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.horizontal)
                    }
                    .padding()
                }
            } else {
                Text("Select a Chapter")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
        }
        .background(Color(NSColor.textBackgroundColor))
    }
}

private extension ReadingView {
    var combinedVersesText: String {
        viewModel.verses
            .map { "\($0.textUthmani) ﴿\($0.verseNumber)﴾" }
            .joined(separator: " ")
    }
}
