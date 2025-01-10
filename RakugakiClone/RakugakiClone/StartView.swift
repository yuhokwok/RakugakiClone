//
//  StartView.swift
//  RakugakiClone
//
//  Created by itst on 9/1/2025.
//

import SwiftUI


struct StartView: View {
    @Binding var mode: AppMode
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        VStack {
            Button(action: {
                withAnimation {
                    mode = .playing
                }
            }, label: {
                Text("Play")
            })
            
            Button(action: {
                withAnimation {
                    mode = .instruct
                }
            }, label: {
                Text("Instruction")
            })
            
            Button(action: {
                withAnimation {
                    mode = .idea
                }
            }, label: {
                Text("Give me Idea")
            })
        }
    }
}

#Preview {
    StartView(mode: .constant(.start))
}
