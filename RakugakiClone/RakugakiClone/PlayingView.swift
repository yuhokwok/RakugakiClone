//
//  ContentView.swift
//  RakugakiClone
//
//  Created by Yu Ho Kwok on 11/19/24.
//

import SwiftUI

struct PlayingView: View {
    @Binding var mode: AppMode
    @State var showTip  = true
    var body: some View {
        ZStack {
            VStack {
                
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            self.showTip.toggle()                        }
                    }, label: { Text(showTip ? "Hide Tips" : "Show Tips") } )
                    .buttonStyle(.borderedProminent)
                    Button(action: {
                        withAnimation {
                            mode = .start
                        }
                    }, label: { Text("Close") } )
                    .buttonStyle(.bordered)
                } .padding(.horizontal)
                
                if showTip {
                    HStack {
                        Spacer()
                        Image(systemName: "globe")
                            .imageScale(.large)
                            .foregroundStyle(.tint)
                        Text("Hello, world!")
                        Spacer()
                    }
                }
                
                ZStack {
#if targetEnvironment(simulator)
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("simulated view")
                                .foregroundStyle(.white)
                            Spacer()
                        }
                        Spacer()
                    }
                    
#else
                    VCContainer()
#endif
                }
                .background(.black)
                .animation(.default, value: showTip)
                .clipShape(RoundedRectangle(cornerRadius: showTip ? 12 : 24))
                .padding(showTip ? 20 : 5)
            }
            

        }
    }
}

#Preview {
    PlayingView(mode: .constant(.playing))
}
