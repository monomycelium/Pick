//
//  PickApp.swift
//  Pick
//
//  Created by Mashrafi Rahman on 2/9/23.
//

import SwiftUI

@main
struct PickApp: App {
    @StateObject private var election: Election = .init()
    
    var body: some Scene {
        WindowGroup {
            ContentView {
                do {
                    try election.save()
                } catch {
                    print(String(describing: error))
                }
            }
            .environmentObject(election)
            .task {
                do {
                    let election: Election = try election.load()
                    self.election.candidates = election.candidates
                    self.election.pick = election.pick
                } catch {
                    print(String(describing: error))
                }
            }
        }
    }
}
