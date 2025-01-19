//
//  RakugakiCloneApp.swift
//  RakugakiClone
//
//  Created by Yu Ho Kwok on 11/19/24.
//

import SwiftUI
import SwiftData
enum AppMode {
    case start
    case playing
    case instruct
    case idea
}

@main
struct RakugakiCloneApp: App {

    var sharedModelContainer : ModelContainer = {
        let schema = Schema( [
            Tuya.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
