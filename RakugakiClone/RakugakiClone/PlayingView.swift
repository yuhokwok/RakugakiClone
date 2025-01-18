//
//  ContentView.swift
//  RakugakiClone
//
//  Created by Yu Ho Kwok on 11/19/24.
//

import SwiftUI
import SceneKit

struct PlayingView: View {
    @Binding var mode: AppMode
    @State var showTip  = true
    
    @State var rakugakiArr : [Rakugaki] = []
    
    @StateObject private var sceneController = SceneController()
    
    
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
                } .padding()
                
                if showTip {
                    HStack {
                        Spacer()
                        Text("This is the tips")
                        Spacer()
                    }
                }
                
                ZStack (alignment: .bottomTrailing) {
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
                    VCContainer(sceneController: sceneController)
#endif
                    
                    
                    VStack {

                        HStack {
                            
                            JoystickView(onChange: {
                                x, y in
                                
                                let currentPos = sceneController.spherePosition
                                let newX = Float(x) * sceneController.movementSpeed //+ currentPos.x
                                let newY : Float = 0
                                //let newZ : Float = 0
                                let newZ = Float(-y) * sceneController.movementSpeed
                                sceneController.spherePosition = SCNVector3(newX, newY, newZ)
                            })
                            .frame(width: 100, height: 100)
                            .padding()
                            
                            ScrollView (.horizontal) {
                                HStack {
                                    ForEach(rakugakiArr){
                                        rakugaki in
                                        
                                        
                                        if let image = rakugaki.texture {
                                            
                                            Button(action: {
                                                if let node = rakugaki.makeNode() {
                                                    ViewController.shared?.addNode(node)
                                                }
                                            }, label: {
                                                
                                                ZStack {
                                                    Image(uiImage: image)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 100, height: 100)
                                                }.frame(width: 100, height: 100)
                                                    .background(.white)
                                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                                    .shadow(radius: 10)
                                                
                                            })
                                            

                                        } else {
                                            Rectangle().frame(width: 100, height: 100)
                                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                                .shadow(radius: 10)
                                        }
                                        
                                        
                                    }
                                }
                            }.contentMargins(20)
                                .scrollIndicators(.hidden)
                            
                            
                            
                            Spacer()
                            

                            Button(action: {
                                ViewController.shared?.scan(callback: {
                                    r in
                                    
                                    rakugakiArr.append(r)
                                })
                                
                                //ViewController.shared?.pressButton(nil)
                            }, label: {
                                Image(systemName: "viewfinder.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundStyle(.white)
                                    .frame(width: 100, height: 100)
                                    .background {
                                        Circle()
                                    }
                            })
                            
                            Button(action: {
                                //ViewController.shared?.pressButton(nil)
                            }, label: {
                                Image(systemName: "viewfinder.circle.fill")
                                    .font(.system(size: 25))
                                    .foregroundStyle(.white)
                                    .frame(width: 50, height: 50)
                                    .background {
                                        Circle()
                                    }
                            }).padding()
                        }
                        .padding()
                        
                    }
                }
                .background(.black)
                .animation(.default, value: showTip)
                .clipShape(RoundedRectangle(cornerRadius: showTip ? 12 : 24))
                .padding(showTip ? 20 : 5)
            }

        }
            .ignoresSafeArea()
    }
}

#Preview {
    PlayingView(mode: .constant(.playing))
}
