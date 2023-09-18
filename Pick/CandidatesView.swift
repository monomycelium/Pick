//
//  CandidatesView.swift
//  Pick
//
//  Created by Mashrafi Rahman on 3/9/23.
//

import SwiftUI

struct CandidatesView: View {
    @EnvironmentObject var election: Election
    @State private var sheet: Bool = .init()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    ForEach(election.candidates) { candidate in
                        NavigationLink(value: candidate.id) {
                            CandidateView(candidate: candidate,
                                          showArrow: true,
                                          socialLnk: false,
                                          showAbout: true)
                            .contextMenu {
                                NavigationLink(value: candidate.id) {
                                    Label("Details", systemImage: "info.circle")
                                }
                                
                                HandlesView(candidate: candidate, label: true)
                                
                                Button(role: .destructive) {
                                    election.candidates.remove(id: candidate.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            } preview: {
                                AsyncImage(url: candidate.pict) { img in
                                    img.resizable().scaledToFit()
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                        }
                        .padding()
                        .buttonStyle(.plain)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .sheet(isPresented: $sheet) {
                AddView { c in
                    election.candidates.append(c)
                    sheet = false
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        sheet.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationTitle("Candidates")
            .navigationDestination(for: UUID.self) { id in
                if let i = election.candidates.index(id: id) {
                    CandidateDetailView(candidate: $election.candidates[i])
                }
            }
        }
    }
}
