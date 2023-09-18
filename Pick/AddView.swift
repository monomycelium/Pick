//
//  AddView.swift
//  Pick
//
//  Created by Mashrafi Rahman on 7/9/23.
//

import SwiftUI

struct AddView: View {
    let callback: (Candidate) -> Void
    @State private var pict: String = .init()
    @State private var wiki: String = .init()
    @State private var page: Page? = nil
    @State private var query: Query? = nil
    @State private var loader: QueryLoader = .init()
    @FocusState private var focus: Bool
    @State private var retrieving: Bool = .init()
    @State private var position: CGFloat = 0
    @State private var c: Candidate = .init(
        name: .init(),
        social: [ .init(platform: .twitter, username: .init()) ],
        pict: .init(string: "(null)")!,
        desc: .init(),
        about: .init(),
        wiki: nil,
        votes: .init(),
        rate: 5
    )
    
    init(callback: @escaping (Candidate) -> Void) {
        self.callback = callback
        UITextField.appearance().clearButtonMode = .whileEditing
    }
    
    var ready: Bool {
        let mirror: Mirror = .init(reflecting: c)
        return URL(string: pict) != nil && mirror.children.allSatisfy { child in
            if let c = child.value as? any Collection {
                return !c.isEmpty
            }
            
            return true
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Wikipedia") {
                    TextField("Title", text: $wiki)
                        .focused($focus)
                        .onChange(of: wiki) { _, new in
                            Task {
                                do {
                                    query = try await loader.load(from: new, limit: 5)
                                    
                                    if let e = query!.pages.first(where: { $0.title == new }) {
                                        page = e
                                    } else {
                                        page = nil
                                    }
                                } catch {
                                    print(String(describing: error))
                                }
                            }
                        }
                    
                    if focus && !wiki.isEmpty {
                        if let pages = query?.pages {
                            ForEach(pages, id: \.self) { page in
                                HStack {
                                    Button {
                                        self.page = page
                                        self.wiki = page.title
                                        focus.toggle()
                                    } label: {
                                        HStack {
                                            Image("wikipedia")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 18)
                                            Text(page.title)
                                            
                                            Spacer()
                                        }
                                        .contentShape(Rectangle())
                                    }

                                    Image(systemName: "arrow.up.backward.circle")
                                        .onTapGesture {
                                            self.wiki = page.title
                                        }
                                }
                                .foregroundStyle(.secondary)
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    Button {
                        Task {
                            do {
                                retrieving = true
                                focus = false
                                
                                let summary: Summary = try await QueryLoader().retrieve(from: page!)
                                c.about = summary.extract
                                c.desc = summary.description ?? c.desc
                                c.pict = summary.image?.source ?? c.pict
                                c.wiki = Page(title: summary.titles.normalized)
                                c.name = summary.titles.normalized
                                
                                pict = summary.image?.source.absoluteString ?? pict
                                retrieving = false
                            } catch {
                                print(String(describing: error))
                                retrieving = false
                            }
                        }
                    } label: {
                        HStack {
                            Text("AutoFill details")
                            
                            if retrieving {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(page == nil)
                }
                
                Section("Details") {
                    TextField("Name", text: $c.name)
                    TextField("Description", text: $c.desc, axis: .vertical)
                    TextField("About", text: $c.about, axis: .vertical)
                }
                
                Section {
                    TextField("Image URL", text: $pict)
                        .keyboardType(.URL)
                        .textContentType(.URL)
                        .onChange(of: pict) { _, new in
                            if let url = URL(string: new) {
                                c.pict = url
                            }
                        }
                    
                    ForEach($c.social) { $h in
                        VStack {
                            Picker("Platform", selection: $h.platform) {
                                ForEach(Platform.allCases, id: \.self) { p in
                                    Text(p.rawValue.capitalized)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.bottom)
                            
                            TextField("Username", text: $h.username)
                        }
                    }
                    
                    Button("Add handle") {
                        c.social.append(.init(platform: .twitter, username: .init()))
                    }
                    .disabled(c.social.last?.username.isEmpty == true)
                } header: {
                    Text("Social")
                } footer: {
                    if !pict.isEmpty && URL(string: pict) == nil {
                        Label("Invalid URL", systemImage: "exclamationmark.circle.fill")
                            .foregroundStyle(.red)
                    }
                }
                
                Section("Campaign") {
                    Stepper(value: $c.votes, in: 0...Int.max) {
                        HStack {
                            Text("Votes")
                            Spacer()
                            Text(c.votes.formatted())
                                .foregroundStyle(.secondary)
                                .padding(.trailing)
                        }
                    }
                    
                    HStack {
                        Text("Rating")
                        Spacer()
                        RatingView(rating: $c.rate)
                    }
                }
            }
            .navigationTitle("Add Candidate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        c.pict = URL(string: pict)!
                        c.social = c.social.filter { !$0.username.isEmpty }
                        callback(c)
                    }
                    .font(.headline)
                    .disabled(!self.ready)
                }
            }
        }
    }
}

#Preview {
    AddView { c in
        
    }
}
