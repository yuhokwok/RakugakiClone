//
//  ContentView.swift
//  RakugakiClone
//
//  Created by Yu Ho Kwok on 11/19/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            VCContainer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
