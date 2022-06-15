//
//  ContentView.swift
//  Graboo
//
//  Created by James Shiffer on 6/13/22.
//

import SwiftUI

struct ContentView<C: BooruClient>: View {
    
    var booru: C
    @State var searchTerm: String
    @State private var pics: [C.T] = []
    
    let cols = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    func reloadSearchResults(_ tags: String) {
        self.booru.searchTagImages(tags: tags) { (data: [C.T]?, error) in
            self.pics = error != nil ? [] : data!
        }
    }
    
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(self.searchTerm)
                    .font(.headline)
                LazyVGrid(columns: cols, spacing: 2) {
                    ForEach(self.pics, id: \.self) { pic in
                        AsyncImage(url: URL(string: pic.displayUrl())) { image in
                            image.resizable().aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 100, height: 150)
                    }
                }
            }
        }
        .navigationTitle("Graboo")
        .searchable(
            text: self.$searchTerm,
            placement: .sidebar
        )
        .onSubmit(of: .search) {
            reloadSearchResults(self.searchTerm)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView(booru: SafebooruClient(), searchTerm: "doki_doki_literature_club")
    }
    
}
