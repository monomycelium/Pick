//
//  RatingView.swift
//  Pick
//
//  Created by Mashrafi Rahman on 3/9/23.
//

import SwiftUI

/// View to show and modify rating.
struct RatingView: View {
    /// Binding to rating value.
    @Binding var rating: UInt
    /// Maximum number of stars.
    let max: UInt
    /// Whether the rating will change when clicked.
    private let change: Bool
    
    init(rating: UInt, max: UInt = 5) {
        self._rating = .constant(rating)
        self.change = false
        self.max = max
    }
    
    init(rating: Binding<UInt>, max: UInt = 5) {
        self._rating = rating
        self.change = true
        self.max = max
    }
    
    var body: some View {
        HStack {
            ForEach(1...max, id: \.self) { r in
                Button {
                    rating = r
                } label: {
                    Image(systemName: rating >= r ? "star.fill" : "star")
                        .symbolRenderingMode(change ? .multicolor : .monochrome)
                        .contentTransition(.symbolEffect(.replace))
                }
                .disabled(!change)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }
}


#Preview {
    RatingView(rating: 5)
}
