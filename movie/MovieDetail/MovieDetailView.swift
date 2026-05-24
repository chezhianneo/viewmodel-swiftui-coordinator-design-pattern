import SwiftUI

struct MovieDetailView: View {
    @State var viewModel: MovieDetailViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else if let error = viewModel.errorMessage {
                ContentUnavailableView(
                    "Failed to Load",
                    systemImage: "exclamationmark.triangle",
                    description: Text(error)
                )
            } else if let movie = viewModel.movie {
                movieContent(movie)
            }
        }
        .navigationTitle(viewModel.title.primaryTitle ?? "Movie detail")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.onLoad() }
    }

    @ViewBuilder
    private func movieContent(_ movie: Movie) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerSection(movie)
                infoSection(movie)

                if let plot = movie.plot, !plot.isEmpty {
                    plotSection(plot)
                }

                if let genres = movie.genres, !genres.isEmpty {
                    genreSection(genres)
                }

                if let directors = movie.directors, !directors.isEmpty {
                    peopleSection(title: "Directors", people: directors)
                }

                if let writers = movie.writers, !writers.isEmpty {
                    peopleSection(title: "Writers", people: writers)
                }

                if let stars = movie.stars, !stars.isEmpty {
                    peopleSection(title: "Stars", people: stars)
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    private func headerSection(_ movie: Movie) -> some View {
        HStack(alignment: .top, spacing: 16) {
            AsyncImage(url: URL(string: movie.primaryImage?.url ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fit)
                case .failure:
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                default:
                    ProgressView()
                }
            }
            .frame(width: 120, height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 8) {
                Text(movie.primaryTitle ?? "")
                    .font(.title2).bold()

                if let year = movie.startYear {
                    Text(String(year))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if let rating = movie.rating?.aggregateRating {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                        Text(String(format: "%.1f", rating))
                            .font(.subheadline).bold()
                        if let votes = movie.rating?.voteCount {
                            Text("(\(votes.formatted()))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if let runtime = movie.runtimeSeconds {
                    let minutes = runtime / 60
                    Text("\(minutes / 60)h \(minutes % 60)m")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    @ViewBuilder
    private func infoSection(_ movie: Movie) -> some View {
        if let metacritic = movie.metacritic, let score = metacritic.score {
            HStack(spacing: 8) {
                Text("Metacritic")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("\(score)")
                    .font(.subheadline).bold()
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(metacriticColor(score))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }

        if let countries = movie.originCountries, !countries.isEmpty {
            HStack {
                Text("Country")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(countries.compactMap(\.name).joined(separator: ", "))
                    .font(.subheadline)
            }
        }

        if let languages = movie.spokenLanguages, !languages.isEmpty {
            HStack {
                Text("Language")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(languages.compactMap(\.name).joined(separator: ", "))
                    .font(.subheadline)
            }
        }
    }

    @ViewBuilder
    private func plotSection(_ plot: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Plot")
                .font(.headline)
            Text(plot)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private func genreSection(_ genres: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Genres")
                .font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(genres, id: \.self) { genre in
                        Text(genre)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func peopleSection(title: String, people: [Person]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(people) { person in
                        VStack(spacing: 4) {
                            AsyncImage(url: URL(string: person.primaryImage?.url ?? "")) { phase in
                                switch phase {
                                case .success(let image):
                                    image.resizable().aspectRatio(contentMode: .fill)
                                default:
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())

                            Text(person.displayName ?? "")
                                .font(.caption)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 80)
                    }
                }
            }
        }
    }

    private func metacriticColor(_ score: Int) -> Color {
        if score >= 61 { return .green }
        if score >= 40 { return .yellow }
        return .red
    }
}

struct RatingView: View {
    private let rating: Double

    init(rating: Double) {
        self.rating = rating
    }

    var body: some View {
        HStack(spacing: 1) {
            ForEach(1...5, id: \.self) { i in
                Image(systemName: i <= Int(rating) ? "star.fill" : "star")
                    .foregroundColor(.yellow)
            }
        }
    }
}
