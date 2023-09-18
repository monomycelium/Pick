//
//  Page.swift
//  Pick
//
//  Created by Mashrafi Rahman on 7/9/23.
//

import Foundation

struct Response: Decodable {
    let query: Query
}

struct Query: Decodable {
    let pages: [Page]
    
    enum CodingKeys: String, CodingKey {
        case pages = "allpages"
    }
}

struct Summary: Decodable, Identifiable {
    let titles: Titles
    let id: Int?
    let extract: String
    let image: Thumbnail?
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "pageid"
        case titles
        case image = "originalimage"
        case description
        case extract
    }
}

struct Titles: Decodable {
    let canonical: String
    let normalized: String
    let display: String
}

struct Thumbnail: Decodable {
    let source: URL
    let width: CGFloat
    let height: CGFloat
}

struct Page: Codable, Equatable, Hashable {
    let title: String
    
    var proper: String {
        return title.replacingOccurrences(of: " ", with: "_")
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
    }
    
    var url: URL {
        return URL(string: "https://en.wikipedia.org/wiki/")!
            .appending(path: self.proper)
    }
    
    enum CodingKeys: String, CodingKey {
        case title
    }
}

struct QueryLoader {
    var session: URLSession = .shared
    
    static let getAllURL: URL = .init(
        string: "https://en.wikipedia.org/w/api.php"
    )!
    
    static let summaryURL: URL = .init(
        string: "https://en.wikipedia.org/api/rest_v1/page/summary/"
    )!
    
    enum QueryError: Error {
        case badURL
        case invalidParams
        case invalidResponse
    }
    
    /// Returns a query of pages that has a title containing the text `from`.
    func load(from: String, limit: Int? = nil) async throws -> Query {
        let url: URL = Self.getAllURL
            .appending(queryItems: [
                .init(name: "action", value: "query"),
                .init(name: "format", value: "json"),
                .init(name: "list", value: "allpages"),
                .init(name: "aplimit", value: limit?.formatted() ?? "max"),
                .init(name: "apfrom", value: from),
            ])
        let (data, r) = try await self.session.data(from: url)
        
        guard let resp = r as? HTTPURLResponse,
              resp.statusCode == 200 else {
            throw QueryError.invalidResponse
        }
        
        let decoder: JSONDecoder = .init()
        let response: Response = try decoder.decode(Response.self, from: data)
        let query: Query = response.query
        return query
    }
    
    /// Retrieves details with Wikipedia summary API.
    func retrieve(from page: Page) async throws -> Summary {
        let title = page.proper
        let url: URL = Self.summaryURL
            .appending(path: title)
            .appending(queryItems: [
                .init(name: "redirect", value: "true"),
            ])
        
        var request: URLRequest = .init(url: url)
        request.allHTTPHeaderFields = [
            "accept": "application/json",
        ]
        
        let (data, r) = try await self.session.data(from: url)
        
        guard let resp = r as? HTTPURLResponse,
              resp.statusCode == 200 else {
            throw QueryError.invalidResponse
        }
        
        let decoder: JSONDecoder = .init()
        let summary: Summary = try decoder.decode(Summary.self, from: data)
        return summary
    }
}
