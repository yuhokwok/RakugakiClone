//
//  IdeaView.swift
//  RakugakiClone
//
//  Created by itst on 9/1/2025.
//

import SwiftUI

struct IdeaView: View {
    @Binding var mode : AppMode
    var body: some View {
        VStack {
            
            Spacer()
            HStack {
                Spacer()
                VStack {
                    Text("Idea View")
                    Button(action:  {
                        withAnimation{
                            mode = .start
                        }
                    }, label:   {
                        Text("Back")
                    })
                }
                Spacer()
            }
            Spacer()
        }
        
    }
}

#Preview {
    IdeaView(mode:.constant(.idea))
}
