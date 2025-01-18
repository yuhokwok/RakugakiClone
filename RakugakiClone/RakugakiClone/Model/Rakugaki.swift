
//
//  Rakugaki.swift
//  RakugakiClone
//
//  Created by Yu Ho Kwok on 1/14/25.
//
import UIKit
import SceneKit
import RealityKit
import ARKit
import Vision

struct Rakugaki : Identifiable, Codable {
    
    
    var id : String = UUID().uuidString
    //var path : UIBezierPath
    var codableBezierPath : CodableBezierPath
    var imageData : Data
    
    var _leftTop : SIMD3<Float>
    var _leftBottom : SIMD3<Float>
    var _rightTop : SIMD3<Float>
    var _rightBottom : SIMD3<Float>
    
    var path : UIBezierPath? {
        return try? codableBezierPath.toBezierPath()
    }
    
    var texture : UIImage? {
        return UIImage(data: imageData)
    }
    
    var leftTop : SCNVector3 {
        set { _leftTop = SIMD3<Float>(newValue)  }
        get { _leftTop.scnVector3 }
    }
    
    var leftBottom : SCNVector3 {
        set { _leftBottom = SIMD3<Float>(newValue)  }
        get { _leftBottom.scnVector3 }
    }
    
    var rightTop : SCNVector3 {
        set { _rightTop = SIMD3<Float>(newValue)  }
        get { _rightTop.scnVector3 }
    }
    
    var rightBottom : SCNVector3 {
        set { _rightBottom = SIMD3<Float>(newValue)  }
        get { _rightBottom.scnVector3 }
    }

    
}

extension Rakugaki {
    
}
