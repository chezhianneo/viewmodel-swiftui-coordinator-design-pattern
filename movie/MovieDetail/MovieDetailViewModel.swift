import Foundation

@Observable
final class MovieDetailViewModel {
    let title: Title
    var movie: Movie?
    var isLoading = false
    var errorMessage: String?

    @ObservationIgnored private let detailService: MovieDetailServicing

    init(title: Title, detailService: MovieDetailServicing) {
        self.title = title
        self.detailService = detailService
    }

    private var hasLoaded = false

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
