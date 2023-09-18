//
//  ElectionView.swift
//  Pick
//
//  Created by Mashrafi Rahman on 4/9/23.
//

import SwiftUI

struct ElectionView: View {
    @EnvironmentObject var election: Election
    
    var body: some View {
        TabView {
            CandidatesView()
                .environmentObject(election)
                .tabItem {
                    Label("Candidates", systemImage: "person.3.fill")
                }
            
            PickView()
                .environmentObject(election)
                .tabItem {
                    Label("Pick", systemImage: "person.fill.questionmark")
                }
            
            ChartView()
                .environmentObject(election)
                .tabItem {
                    Label("Standings", systemImage: "chart.bar.fill")
                }
        }
    }
}
