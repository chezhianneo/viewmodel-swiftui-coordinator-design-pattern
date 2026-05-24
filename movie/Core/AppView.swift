//
//  AppView.swift
//  movie
//
//  Created by Elan Arulraj on 5/20/26.
//

import SwiftUI
import Combine

@MainActor
struct AppView: View {

    let navigation: NavigationStream<AppDestination>
    @State private var view: (any View)?

    var body: some View {
        Group {
            if let view = view {
                AnyView(view)
            }
        }
        .onReceive(navigation.compactMap {$0}) { navigationDestination in
            self.view = navigationDestination.view
        }
    }
}
