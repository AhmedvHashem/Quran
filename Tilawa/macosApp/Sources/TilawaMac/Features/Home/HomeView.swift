import Shared
import SwiftUI

/// The app's landing screen. For now it holds the curated featured reciters;
/// the whole catalog lives under Reciters.
struct HomeView: View {
    @EnvironmentObject private var catalog: Catalog

    var body: some View {
        CatalogGate {
            let featured = catalog.reciters.filter { reciter in
                catalog.editions(of: reciter).contains(where: \.isFeatured)
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    SectionHeading(title: "Featured reciters", detail: "\(featured.count)")
                    ReciterGrid(reciters: featured)
                }
                .padding(.horizontal, 32)
                .padding(.top, 26)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Home")
    }
}
