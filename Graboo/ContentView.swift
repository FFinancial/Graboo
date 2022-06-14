//
//  ContentView.swift
//  Graboo
//
//  Created by James Shiffer on 6/13/22.
//

import SwiftUI

final class ModelData: ObservableObject {
    
    @Published private(set) var imgs: [GelbooruImage] = []
    var searchTerms: [String]
    
    init(searchTerms: [String]) {
        self.searchTerms = searchTerms
        GelbooruClient().searchTagImages(tags: searchTerms) { data, error in
            self.imgs = error != nil ? [] : data!
        }
    }

}

struct ContentView: View {
    
    @EnvironmentObject var model: ModelData
    
    let cols = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(model.searchTerms.joined(separator: ", "))
                    .font(.headline)
                LazyVGrid(columns: cols, spacing: 10) {
                    ForEach(model.imgs, id: \.self) { pic in
                        VStack {
                            AsyncImage(url: URL(string: pic.sampleUrl)) { image in
                                image.resizable().aspectRatio(contentMode: .fit)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 100, height: 100 * CGFloat(pic.sampleHeight)/CGFloat(pic.sampleWidth))
                            Text(String(pic.id))
                        }
                    }
                }
            }
            .navigationTitle("Graboo")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView()
            .environmentObject(ModelData(searchTerms: ["hatsune_miku", "rating:general"]))
    }
    
}
