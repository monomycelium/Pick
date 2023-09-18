//
//  ContentView.swift
//  Pick
//
//  Created by Mashrafi Rahman on 2/9/23.
//

import SwiftUI

struct ContentView: View {
    @State private var reload: Bool = .init()
    @EnvironmentObject private var election: Election
    @Environment(\.scenePhase) private var scenePhase
    let saveAction: () -> Void
    
    var body: some View {
        ElectionView()
            .environmentObject(election)
            .onChange(of: scenePhase) { _, phase in
                if phase == .inactive {
                    saveAction()
                }
            }
    }
}
