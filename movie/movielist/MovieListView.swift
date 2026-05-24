import SwiftUI
import Combine

@MainActor
struct MovieListView: View {
    @State var viewModel: MovieListViewModel
    @State private var path = NavigationPath()
    @Namespace private var heroAnimation

    let navigationStream: NavigationStream<MovieListDestination>

    private let columns = [
        GridItem(.adaptive(minimum: 150))
    ]

    var body: some View {
        TabView {
            NavigationStack(path: $path) {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.items, id: \.id) { item in
                            Button {
                                viewModel.onMovieTapped(item)
                            } label: {
                                MovieRow(item: item)
                                    .matchedGeometryEffect(
                                        id: "movie-\(item.id ?? "")",
                                        in: heroAnimation
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
                .navigationDestination(for: MovieListDestination.self) { destination in
                    destination.view
                }
                .navigationTitle("Movies List")
                .searchable(text: $viewModel.searchText, prompt: "Search movies")
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
        }
        .onReceive(navigationStream.compactMap { $0 }) { destination in
            withAnimation(.spring(
                response: 0.6,
                dampingFraction: 0.75,
                blendDuration: 0.8
            )) {
                path.append(destination)
            }
        }
    }
}
