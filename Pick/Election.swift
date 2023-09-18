//
//  Election.swift
//  Pick
//
//  Created by Mashrafi Rahman on 3/9/23.
//

import Foundation
import IdentifiedCollections

class Election: ObservableObject, Codable {
    @Published var candidates: IdentifiedArrayOf<Candidate>
    @Published var pick: UUID?
    
    init(candidates: IdentifiedArrayOf<Candidate> = .init()) {
        self.candidates = candidates
        self.pick = nil
    }
    
    init(array: [Candidate]) {
        self.candidates = .init(uniqueElements: array)
        self.pick = nil
    }
    
    enum CodingKeys: CodingKey { case candidates, pick }
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appending(path: "election.json")
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.candidates, forKey: .candidates)
        try container.encode(self.pick, forKey: .pick)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.candidates = try values.decode(IdentifiedArrayOf<Candidate>.self, forKey: .candidates)
        self.pick = try values.decodeIfPresent(UUID.self, forKey: .pick) ?? nil
    }
    
    func load() throws -> Election {
        let url: URL = try Self.fileURL()
        let data: Data = try Data(contentsOf: url)
        let decoder: JSONDecoder = .init()
        let election: Election = try decoder.decode(Election.self, from: data)
        return election
    }
    
    func save() throws {
        let encoder: JSONEncoder = .init()
        let data: Data = try encoder.encode(self)
        let url: URL = try Self.fileURL()
        try data.write(to: url)
    }
    
    static let demo: [Candidate] = [
        .init(
            name: "Conan Gray",
            social: [
                .init(platform: .instagram, username: "conangray"),
                .init(platform: .twitter, username: "conangray"),
                .init(platform: .facebook, username: "conangrayofficial"),
            ],
            pict: .init(string: "https://upload.wikimedia.org/wikipedia/commons/5/54/Conan_Gray_U_Street_Music_Hall_March_2019_2.jpg")!,
            desc: "American singer-songwriter (born 1998)",
            about: "Born in Lemon Grove, California, and raised in Georgetown, Texas, he began uploading vlogs, covers and original songs to YouTube as a teenager. In 2018, Gray signed a record deal with Republic Records, which released his debut EP, Sunset Season (2018).",
            wiki: .init(title: "Conan Gray"),
            votes: 23_200_000,
            rate: 5
        ),
        .init(
            name: "Hayd",
            social: [
                .init(platform: .instagram, username: "haydmusic"),
                .init(platform: .twitter, username: "hayd_music"),
            ],
            pict: URL(string: "https://marsh.digitya.com/media/hayd.jpg")!,
            desc: "Singer",
            about: "Look into my eyes; see all the pain inside…",
            wiki: nil,
            votes: 1_400_000,
            rate: 5
        ),
        .init(
            name: "Cecil Baldwin",
            social: [
                .init(platform: .twitter, username: "CecilBaldwinIII"),
                .init(platform: .instagram, username: "cecilbaldwiniii"),
            ],
            pict: URL(string: "https://pbs.twimg.com/profile_images/1471018399358672896/OjQGOApA_400x400.jpg")!,
            desc: "Voice actor",
            about: "Amazing.",
            wiki: nil,
            votes: 14_400_000,
            rate: 5
        ),
    ]
}
