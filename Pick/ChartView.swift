//
//  ChartView.swift
//  Pick
//
//  Created by Mashrafi Rahman on 4/9/23.
//

import SwiftUI
import Charts

struct ChartView: View {
    @EnvironmentObject var election: Election
    
    var body: some View {
        Chart {
            ForEach(election.candidates, id: \.self) { c in
                BarMark(
                    x: .value("Candidate", c.name),
                    y: .value("Votes", c.votes)
                )
            }
        }
        .padding()
        .navigationTitle("Standings")
    }
}

struct ChartViewPreview: View {
    @StateObject var election: Election = .init(array: Election.demo)
    
    var body: some View {
        ChartView()
            .environmentObject(election)
    }
}

#Preview {
    ChartViewPreview()
}
