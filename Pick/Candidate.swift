//
//  Candidate.swift
//  Pick
//
//  Created by Mashrafi Rahman on 2/9/23.
//

import Foundation
import SwiftUI

/// Structure to represent a candidate.
struct Candidate: Codable, Identifiable, Hashable {
    let id: UUID = .init()
    
    /// Name of candidate.
    var name: String
    /// Social media profiles of candidate.
    var social: [Handle]
    /// URL to picture of candidate.
    var pict: URL
    /// Short description of candidate.
    var desc: String
    /// Extract of candidate.
    var about: String
    /// Title of Wikipedia page of candidate (optional).
    var wiki: Page?
    /// Number of votes.
    var votes: Int
    /// User's rating of candidate.
    var rate: UInt
    
    enum CodingKeys: CodingKey { case name, social, pict, about, wiki, votes, desc, rate }
    
    /*
     TODO: make name, about and picture fields optional
     Instead, use the Wikipedia summary API to fetch those.
     */
}

/// Handle to social media profile.
struct Handle: Codable, Hashable, Identifiable {
    let id: UUID = .init()
    
    /// Social media platform.
    var platform: Platform
    /// Username for platform.
    var username: String
    
    enum CodingKeys: CodingKey { case platform, username }
    
    init(platform: Platform, username: String) {
        self.platform = platform
        self.username = username
    }
    
    init(wiki: Page) {
        self.platform = .wikipedia
        self.username = wiki.title
    }
    
    /// Returns URL to profile.
    var url: URL {
        if self.platform == .wikipedia {
            return Page(title: self.username).url
        }
            
        let url: URL = switch self.platform {
        case .twitter: URL(string: "https://x.com")!
        case .instagram: URL(string: "https://instagram.com")!
        case .facebook: URL(string: "https://facebook.com")!
        case .wikipedia: fatalError()
        }
        
        return url.appending(path: self.username)
    }
    
    /// Returns image string for platform.
    var image: String { return self.platform.rawValue }
    
    /// Returns display name for handle.
    var display: String {
        return switch self.platform {
        case .twitter, .instagram: "@" + username
        case _: username
        }
    }
}

/// Social media platforms.
enum Platform: String, Codable, CaseIterable {
    case twitter, instagram, facebook, wikipedia
}
