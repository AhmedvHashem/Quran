import SwiftUI

struct SidebarView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        List(selection: $viewModel.selectedChapter) {
            ForEach(viewModel.chapters) { chapter in
                HStack {
                    Text("\(chapter.id).")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 25, alignment: .leading)
                    
                    VStack(alignment: .leading) {
                        Text(chapter.nameSimple)
                            .font(.headline)
                        Text(chapter.translatedName?.name ?? "")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(chapter.nameArabic)
                        .font(.body)
                }
                .tag(chapter)
                .padding(.vertical, 4)
            }
        }
        .listStyle(SidebarListStyle())
        .frame(minWidth: 250)
    }
}

