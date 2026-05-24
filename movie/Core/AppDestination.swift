import Combine
import SwiftUI

enum AppDestination: NavigationDestination {
    case movieList(any View)

    static func == (lhs: AppDestination, rhs: AppDestination) -> Bool {
        switch (lhs, rhs) {
        case (.movieList, .movieList): return true
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .movieList:   hasher.combine("movieList")
        }
    }

    var view: some View {
        switch self {
        case .movieList(let view):
            return AnyView(view)
        }
    }
}
