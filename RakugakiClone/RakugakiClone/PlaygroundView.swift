//
//  ContentView.swift
//  RakugakiClone
//
//  Created by Yu Ho Kwok on 11/19/24.
//

import SwiftUI
import SceneKit
import SwiftData

class SceneWrapper {
    var scene : SCNScene? = nil
}

struct PlaygroundView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var tayuResults : [Tuya]
    
    @Binding var mode: AppMode
    @State var showTip  = true
    
    @State var rakugakiArr : [Rakugaki] = []
    
    @StateObject private var sceneController = SceneController()
    
    @State var tuya : Tuya?
    
    var sceneWrapper : SceneWrapper = SceneWrapper()
    @State var usdzURL : URL?
    
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
                                    ForEach(tayuResults){
                                        result in
                                        
                                        VStack {
                                            ZStack(alignment: .bottomTrailing) {
                                                if let image = result.texture {
                                                    
                                                    Button(action: {
                                                        if let node = result.makeNode() {
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
                                                
                                                Button(action: {
                                                    self.tuya = result
                                                }, label: {
                                                    Text("More")
                                                })
                                            }
                                            Text("\(result.name)")
                                        }
                                        
                                    }
                                }
                            }.contentMargins(20)
                                .scrollIndicators(.hidden)
                            
                            
                            
                            Spacer()
                            

                            Button(action: {
                                ViewController.shared?.scan(callback: {
                                    r, t in
                                    
                                    //rakugakiArr.append(r)
                                    var notOk = true
                                    var index = 0
                                    while notOk {

                                        let fetchDescriptor = FetchDescriptor<Tuya>(predicate: #Predicate {
                                            tuya in
                                            if index == 0 {
                                                return tuya.name.contains("Drawing")
                                            } else {
                                                return tuya.name.contains("Drawing \(index)")
                                            }
                                        })
                                        
                                        if let count = try? modelContext.fetchCount(fetchDescriptor) {
                                            notOk = count > 0
                                        } else {
                                            notOk = false
                                        }
                                        
                                        index += 1
                                    }
                                    
                                    if index == 0 {
                                        t.name = "Drawing"
                                    } else {
                                        t.name = "Drawing \(index)"
                                    }
                                    
                                    modelContext.insert(t)
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
        .sheet(item: $tuya, content: {
            tuya in
            
            VStack {
                HStack {
                    Text("\(tuya.name)")
                    Spacer()
                    Button(action: {
                        sceneWrapper.scene?.exportUSDZ(name: tuya.name, completion: {
                            urls in
                            
                            if let urls = urls {
                                
                                DispatchQueue.main.async {
                                    usdzURL = urls[0]
                                }
                            }
                            
                        })
                    }, label: { Text("To USDZ") })
                }.padding()
                
                SceneView(
                    scene: makeScene(with: tuya),
                    // If you’d like to control the camera by touch, include .allowsCameraControl.
                    options: [.allowsCameraControl, .autoenablesDefaultLighting]
                )
            }
        })
        .sheet(isPresented: Binding(get: { usdzURL != nil }, set: { if $0 == false {usdzURL = nil} }), content: {
            if let usdzURL = self.usdzURL {
                ShareSheet(activityItems: [usdzURL])
            } else {
                Text("Error")
            }
        })
            .ignoresSafeArea()
    }

    func makeScene(with tuya : Tuya) -> SCNScene {
        let scene = SCNScene()

        var tuyaNode : SCNNode? = nil
        if let node = tuya.makeNode(false) {
            scene.rootNode.addChildNode(node)
            tuyaNode = node
        }

        // Optionally, create a camera node so you have a known viewpoint
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(-0.3, -0.3, 2.0) // Position the camera in front of the cube
        if tuyaNode != nil {
            cameraNode.look(at: tuyaNode!.position)
        }
        scene.rootNode.addChildNode(cameraNode)
        
        // Add a light source for basic lighting
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(0, 5, 5)
        scene.rootNode.addChildNode(lightNode)

        
        sceneWrapper.scene = scene
        
        return scene
    }
}

extension SCNScene {
    func exportUSDZ(name : String, completion: @escaping (([URL]?) -> (Void))) {
        
        print("export usdz")
        let documentsUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        guard !documentsUrl.isEmpty,
              let url = documentsUrl.first else {
            completion(nil)
            return
        }
        
        let finalUrl = url.appendingPathComponent("\(name).usdz")
        
        self.write(to: finalUrl, delegate: nil, progressHandler: {
            totalProgress, error, stop in
            if error != nil {
                print("error")
                completion(nil)
            }
            completion([finalUrl])
        })
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [URL]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    PlaygroundView(mode: .constant(.playing))
}
