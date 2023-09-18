//
//  HandleView.swift
//  Pick
//
//  Created by Mashrafi Rahman on 3/9/23.
//

import SwiftUI

/// View to display handle.
struct HandleView: View {
    /// Handle to display.
    let handle: Handle
    /// Whether a simple label will be used.
    let label: Bool
    @Environment(\.openURL) private var openURL
    
    init(handle: Handle, label: Bool = false) {
        self.handle = handle
        self.label = label
    }
    
    var body: some View {
        Button {
            openURL.callAsFunction(handle.url)
        } label: {
            if label {
                Label(handle.display, image: handle.image)
            } else {
                HStack {
                    Image(handle.image)
                        .resizable()
                        .scaledToFit()
                    Text(handle.display)
                }
            }
        }
    }
}

struct HandlesView: View {
    let handles: [Handle]
    let label: Bool
    
    init(candidate: Candidate, label: Bool = false) {
        var handles = candidate.social
        if let wiki = candidate.wiki {
            handles.append(.init(wiki: wiki))
        }
        
        self.handles = handles
        self.label = label
    }
    
    var body: some View {
        ForEach(handles) { h in
            HandleView(handle: h, label: label)
        }
    }
}

#Preview {
    VStack {
        HandleView(handle: .init(platform: .twitter, username: "elonmusk"))
            .frame(height: 12)
        HandleView(handle: .init(platform: .instagram, username: "elonmusk"))
            .frame(height: 12)
    }
}
