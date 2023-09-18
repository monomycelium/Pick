//
//  PickView.swift
//  Pick
//
//  Created by Mashrafi Rahman on 4/9/23.
//

import SwiftUI

/// View for users to vote for a candidate.
struct PickView: View {
    @EnvironmentObject var election: Election
    let columns: [GridItem] = .init(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    LazyVGrid(columns: columns) {
                        ForEach(election.candidates, id: \.self) { c in
                            Button {
                                withAnimation {
                                    election.pick = election.pick == c.id ? nil : c.id
                                }
                            } label: {
                                CandidateView(candidate: c)
                                    .overlay {
                                        if c.id == election.pick {
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(.gray, lineWidth: 3)
                                        }
                                    }
                                    .contextMenu {
                                        NavigationLink(value: c.id) {
                                            Label("Details", systemImage: "info.circle")
                                        }
                                        
                                        HandlesView(candidate: c, label: true)
                                    } preview: {
                                        AsyncImage(url: c.pict) { img in
                                            img.resizable().scaledToFit()
                                        } placeholder: {
                                            ProgressView()
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
                
                Button {
                    election.candidates[id: election.pick!]!.votes += 1
                    election.pick = nil
                } label: {
                    Label("Submit", systemImage: "return")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .sensoryFeedback(.selection, trigger: election.pick)
                .padding()
                .disabled(election.pick == nil)
            }
            .navigationTitle("Pick")
            .navigationDestination(for: UUID.self) { id in
                if let i = election.candidates.index(id: id) {
                    CandidateDetailView(candidate: $election.candidates[i])
                }
            }
        }
    }
}

struct PickViewPreview: View {
    @StateObject var election: Election = .init(array: Election.demo)
    
    var body: some View {
        PickView()
            .environmentObject(election)
    }
}

#Preview {
    PickViewPreview()
}
