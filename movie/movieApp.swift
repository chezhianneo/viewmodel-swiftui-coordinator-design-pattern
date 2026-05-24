//
//  movieApp.swift
//  movie
//
//  Created by Elan Arulraj on 5/23/26.
//

import SwiftUI

@main
struct movieApp: App {
    let cordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            cordinator.make()
        }
    }
}
