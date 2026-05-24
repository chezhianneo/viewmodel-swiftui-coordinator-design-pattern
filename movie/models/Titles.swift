//
//  Titles.swift
//  movie
//
//  Created by Elan Arulraj on 6/25/25.
//

import Foundation

struct Titles: Decodable {
    let titles: [Title]?
    
    init(_ titles: [Title]? = nil) {
        self.titles = titles
    }
}
