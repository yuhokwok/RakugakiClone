//
//  SceneController.swift
//  RakugakiClone
//
//  Created by Yu Ho Kwok on 1/17/25.
//


import SwiftUI
import SceneKit

class SceneController: ObservableObject {
    /// The sphere’s position in 3D space
    @Published var spherePosition: SCNVector3 = SCNVector3(0, 0, 0)
    
    /// Movement speed factor
    let movementSpeed: Float = 0.1
}
