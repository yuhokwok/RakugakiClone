//
//  ContentView.swift
//  RakugakiClone
//
//  Created by itst on 9/1/2025.
//

import SwiftUI

struct ContentView: View {
    @State var mode : AppMode = .start
    var body: some View {
        if mode == .start || mode == .instruct {
            StartView(mode: $mode)
                .sheet(isPresented: Binding(get: {
                    return mode == .instruct
                }, set: {
                    if $0 == false { mode = .start } else { mode = .instruct}
                }), content: {
                    InstructionView()
                })
        } else if mode == .playing {
            PlaygroundView(mode: $mode)
                .transition(.scale(0.5).combined(with: .opacity))
        } else if mode == .idea {
            IdeaView(mode: $mode)
                .transition(.move(edge: .bottom))
        }
    }
}

#Preview {
    ContentView()
}
