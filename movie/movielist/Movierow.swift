//
//  Movierow.swift
//  movie
//
//  Created by Elan Arulraj on 7/6/25.
//

import SwiftUI

struct MovieRow: View {
    private let item: Title
    init(item: Title) {
        self.item = item
    }
    
    
    var body: some View {
        VStack {
            HStack {
                AsyncImage(
                    url: URL(string: item.primaryImage?.url ?? ""),
                    transaction: Transaction(animation: .easeIn),
                    content: { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image.resizable()
                        default:
                            Image(systemName: "xmark.circle")
                                .resizable()
                        }
                    })
                .frame(width:60, height:60)
                LazyVStack(alignment: .leading, spacing: 1) {
                    Text(item.primaryTitle ?? "")
                        .font(.subheadline)
                    RatingView(rating: item.rating?.aggregateRating ?? 0)
                }
            }
            Spacer()
            Divider()
        }
    }
}
