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

extension SCNVector3 {
    var simd3f : SIMD3<Float> {
        return SIMD3(x: self.x, y: self.y, z: self.z)
    }
}
