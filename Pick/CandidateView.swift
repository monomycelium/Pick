//
//  CandidateView.swift
//  Pick
//
//  Created by Mashrafi Rahman on 2/9/23.
//

import SwiftUI
import WrappingHStack

/// Brief view of Candidate.
struct CandidateView: View {
    /// Candidate to display.
    let candidate: Candidate
    /// Whether it will have an arrow.
    let showArrow: Bool
    /// Line limit for description.
    let lineLimit: Int?
    /// Whether it will show social media links.
    let socialLnk: Bool
    /// Whether it will show the extract.
    let showAbout: Bool
    
    init(candidate: Candidate,
         showArrow: Bool = .init(),
         lineLimit: Int? = nil,
         socialLnk: Bool = .init(),
         showAbout: Bool = .init()) {
        self.candidate = candidate
        self.showArrow = showArrow
        self.lineLimit = lineLimit
        self.socialLnk = socialLnk
        self.showAbout = showAbout
        
        URLCache.shared.memoryCapacity = 10_000_000
        URLCache.shared.diskCapacity = 1_000_000_000
    }
    
    var body: some View {
        VStack {
            AsyncImage(url: candidate.pict) { img in
                img
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
            }
            
            HStack {
                Text(candidate.name)
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                if showArrow {
                    Image(systemName: "arrow.right")
                }
            }
            .padding(.horizontal)
            
            Text(candidate.desc)
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.bottom)
            
            if showAbout {
                Text(candidate.about)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.horizontal, .bottom])
                    .lineLimit(lineLimit)
            }
            
            if socialLnk {
                WrappingHStack(alignment: .leading) {
                    ForEach(candidate.social, id: \.self) { handle in
                        HandleView(handle: handle)
                            .buttonStyle(.borderless)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: 12)
                            .padding(.bottom, 5)
                    }
                }
                .padding([.horizontal, .bottom])
            }
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

#Preview {
    CandidateView(candidate: Election.demo.first!,
                  showArrow: false,
                  lineLimit: 4,
                  socialLnk: false,
                  showAbout: false)
    .frame(width: 200)
    .padding()
}
