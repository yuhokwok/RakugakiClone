//
//  RakugakiCloneApp.swift
//  RakugakiClone
//
//  Created by Yu Ho Kwok on 11/19/24.
//

import SwiftUI

enum AppMode {
    case start
    case playing
    case instruct
    case idea
}

@main
struct RakugakiCloneApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
