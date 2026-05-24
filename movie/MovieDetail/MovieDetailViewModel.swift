import Foundation

protocol MovieDetailViewModeling {
    /// The title used to fetch detail data.
    var title: Title { get }
    /// The fetched movie detail; nil until the request completes.
    var movie: Movie? { get set }
    /// True while the detail request is in flight.
    var isLoading: Bool { get set }
    /// Set with a human-readable message when the detail request fails.
    var errorMessage: String? { get set }
    /// Triggers the detail fetch; no-ops if already loaded or title id is nil.
    func onLoad() async
}

@Observable
final class MovieDetailViewModel: MovieDetailViewModeling {
    let title: Title
    var movie: Movie?
    var isLoading = false
    var errorMessage: String?

    @ObservationIgnored private let detailService: MovieDetailServicing
    @ObservationIgnored private var hasLoaded = false

    init(title: Title, detailService: MovieDetailServicing) {
        self.title = title
        self.detailService = detailService
    }

    func onLoad() async {
        guard !hasLoaded, let titleId = title.id else { return }
        hasLoaded = true
        await loadDetail(titleId: titleId)
    }

    @MainActor
    private func loadDetail(titleId: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            movie = try await detailService.fetchDetail(titleId: titleId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
