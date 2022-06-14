//
//  GrabooApp.swift
//  Graboo
//
//  Created by James Shiffer on 6/13/22.
//

import SwiftUI

@main
struct GrabooApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ModelData(searchTerms: ["hatsune_miku", "rating:general"]))
        }
    }
}
