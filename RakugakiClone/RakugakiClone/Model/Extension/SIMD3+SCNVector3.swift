//
//  SIMD3+SCNVector3.swift
//  RakugakiClone
//
//  Created by Yu Ho Kwok on 1/18/25.
//

import SceneKit
import RealityKit

extension SIMD3<Float> {
    var scnVector3 : SCNVector3 {
        return SCNVector3(self.x, self.y, self.z)
    }
    init(_ scnVector3 : SCNVector3) {
        self.init(x: scnVector3.x, y: scnVector3.y, z: scnVector3.z)
    }
}

