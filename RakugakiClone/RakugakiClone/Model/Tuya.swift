//
//  Tuya.swift
//  RakugakiClone
//
//  Created by Yu Ho Kwok on 19/1/2025.
//

import SwiftData
import Foundation

import SceneKit
import RealityKit
import ARKit
import Vision
import CoreImage

@Model
class Tuya {
    @Attribute(.unique) var name : String
    var pathData : Data
    var textCoord : TextCoord
    @Attribute(.externalStorage) var imageData : Data
    
//    var leftTop     : [Float]
//    var leftBottom  : [Float]
//    var rightTop    : [Float]
//    var rightBottom : [Float]
    
    var timestamp  : Date
    
    init(name : String,
         pathData: Data,
         imageData : Data,
//         leftTop : SCNVector3,
//         leftBottom : SCNVector3,
//         rightTop : SCNVector3,
//         rightBottom : SCNVector3,
         textCoord : TextCoord,
         timestamp : Date = Date()) {
        self.name = name
        self.pathData = pathData
        self.textCoord = textCoord
        self.imageData = imageData
        
//        self.leftTop = [leftTop.simd3f.x, leftTop.simd3f.y, leftTop.simd3f.z]
//        self.leftBottom = [leftBottom.simd3f.x, leftBottom.simd3f.y, leftBottom.simd3f.z]
//        self.rightTop = [rightTop.simd3f.x, rightTop.simd3f.y, rightTop.simd3f.z]
//        self.rightBottom = [rightBottom.simd3f.x, rightBottom.simd3f.y, rightBottom.simd3f.z]
        
        self.timestamp = timestamp
    }
    
    var path : UIBezierPath? {
        guard let pathData = SerializablePath(JSON: pathData) else {
            return nil
        }
        let bezierPath = UIBezierPath(cgPath: pathData.CGPath())
        return bezierPath
    }
    
    
    var texture : UIImage? {
        return UIImage(data: imageData)
    }
    
}

struct TextCoord : Codable {
    private var leftTop     : [Float]
    private var leftBottom  : [Float]
    private var rightTop    : [Float]
    private var rightBottom : [Float]
    
    enum Corner {
        case leftTop
        case leftBottom
        case rightTop
        case rightBottom
    }
    
    init(_ lt : SIMD3<Float>, _ lb : SIMD3<Float>, _ rt : SIMD3<Float>, _ rb : SIMD3<Float>) {
        self.leftTop = [lt.x, lt.y, lt.z]
        self.leftBottom = [lb.x, lb.y, lb.z]
        self.rightTop = [rt.x, rt.y, rt.z]
        self.rightBottom = [rb.x, rb.y, rb.z]
    }
    
    init(_ lt : SCNVector3, _ lb : SCNVector3, _ rt : SCNVector3, _ rb : SCNVector3) {
        self.leftTop = [lt.simd3f.x, lt.simd3f.y, lt.simd3f.z]
        self.leftBottom = [lb.simd3f.x, lb.simd3f.y, lb.simd3f.z]
        self.rightTop = [rt.simd3f.x, rt.simd3f.y, rt.simd3f.z]
        self.rightBottom = [rb.simd3f.x, rb.simd3f.y, rb.simd3f.z]
    }
    
    func ptSIMD3f(at corner : Corner) -> SIMD3<Float> {
        switch corner {
        case .leftTop:
            return SIMD3<Float>(leftTop[0], leftTop[1], leftTop[2])
        case .leftBottom:
            return SIMD3<Float>(leftBottom[0], leftBottom[1], leftBottom[2])
        case .rightTop:
            return SIMD3<Float>(rightTop[0], rightTop[1], rightTop[2])
        case .rightBottom:
            return SIMD3<Float>(rightBottom[0], rightBottom[1], rightBottom[2])
        }
    }
    
    func ptScnVector(at corner : Corner) -> SCNVector3 {
        switch corner {
        case .leftTop:
            return SCNVector3(x: leftTop[0], y: leftTop[1], z: leftTop[2])
        case .leftBottom:
            return SCNVector3(x: leftBottom[0], y: leftBottom[1], z: leftBottom[2])
        case .rightTop:
            return SCNVector3(x: rightTop[0], y: rightTop[1], z: rightTop[2])
        case .rightBottom:
            return SCNVector3(x: rightBottom[0], y: rightBottom[1], z: rightBottom[2])
        }
        
    }
    
}

extension Tuya {
    
    func makeNode(_ applyPhysicsBody : Bool = true) -> SCNNode? {
        guard let path = self.path , let texture = self.texture else { return nil }
        
        let node = SCNNode()
        node.position = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
        
        
        let pathShapeNode = makePathShapeNode(geometryPath: path)
        pathShapeNode.position = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
        node.addChildNode(pathShapeNode)
        
          
//        print("textureNode: \(textCoord)")
        let lt = textCoord.ptScnVector(at: .leftTop)
        let lb = textCoord.ptScnVector(at: .leftBottom)
        let rt = textCoord.ptScnVector(at: .rightTop)
        let rb = textCoord.ptScnVector(at: .rightBottom)
        
        let widthTop    = rt.x - lt.x
        let widthBottom = rb.x - lb.x
        //let width       = max(widthTop, widthBottom)
        
//        let minX = (widthTop > widthBottom) ? lt.x : lb.x
//        let maxX = (widthTop > widthBottom) ? rt.x : rb.x
  
        let minX = (lt.x < lb.x) ? lt.x : lb.x
        let maxX = (rt.x > rb.x) ? rt.x : rb.x
        
        let heightLeft = lb.z - lt.z
        let heightRight = rb.z - rt.z
        //let height = max(heightLeft, heightRight)
        
//        let minY = (heightLeft > heightRight) ? lt.z : rt.z
//        let maxY = (heightLeft > heightRight) ? lb.z : rb.z
        
        let minY = (lt.z < rt.z) ? lt.z : rt.z
        let maxY = (lb.z > rb.z) ? lb.z : rb.z
        
//        let minValue = (height > width) ? minY : minX
//        let maxValue = (height > width) ? maxY : maxX

//        print("width: \(width), height: \(height)")
//        print("min coord: \(minX) \(minY)")
//        print("max coord: \(maxX) \(maxY)")
        
        let width = maxX - minX
        let height = maxY - minY
        
        
        let minValue = (height > width) ? minY : minX
        let maxValue = (height > width) ? maxY : maxX
        
        
        let ilt = convertPt(lt, with: minValue, and: maxValue)
        let ilb = convertPt(lb, with: minValue, and: maxValue)
        let irt = convertPt(rt, with: minValue, and: maxValue)
        let irb = convertPt(rb, with: minValue, and: maxValue)
        
        print("ilt \(lt) | \(ilt)")
        print("ilb \(lb) | \(ilb)")
        print("irt \(rt) | \(irt)")
        print("irb \(rb) | \(irb)")
        
        //let geometry = SCNShape(path: path, extrusionDepth: 0.01)
        let boudningBox = pathShapeNode.boundingBox
        let boundingBoxMax = pathShapeNode.boundingBox.max
        let boundingBoxMin = pathShapeNode.boundingBox.min
        print("geometry: \(pathShapeNode.boundingBox)")
        
        let bblt = SCNVector3(boundingBoxMin.x / 10, 0, -boundingBoxMax.y / 10)
        let bblb = SCNVector3(boundingBoxMin.x / 10, 0, -boundingBoxMin.y / 10)
        let bbrt = SCNVector3(boundingBoxMax.x / 10, 0, -boundingBoxMax.y / 10)
        let bbrb = SCNVector3(boundingBoxMax.x / 10, 0, -boundingBoxMin.y / 10)
        
        let tlt = convertPt(bblt, with: minValue, and: maxValue)
        let tlb = convertPt(bblb, with: minValue, and: maxValue)
        let trt = convertPt(bbrt, with: minValue, and: maxValue)
        let trb = convertPt(bbrb, with: minValue, and: maxValue)
        
        let twidth = trt.x - tlt.x
        let theight = trb.z - trt.z

        let t = texture
        let  transformedImage = perspectiveTransformWithExtent(inputImage: CIImage(image: texture)!,
                                                          lt: CGPoint(x: ilt.x.double, y: 600 - ilt.z.double),
                                                          lb: CGPoint(x: ilb.x.double, y: 600 - ilb.z.double),
                                                          rt: CGPoint(x: irt.x.double, y: 600 - irt.z.double),
                                                          rb: CGPoint(x: irb.x.double, y: 600 - irb.z.double))
        
//        let outputImage = transformedImage.cropped(to: CGRect(x: tlt.x.double - transformedImage.extent.origin.x / 2,
//                                                              y:  250,
//                                                              //y:  (tlb.z.double) - transformedImage.extent.origin.y / 2,
//                                                              width: twidth.double,
//                                                              height: theight.double))
        
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent)!
        let theTexture = cgImage.cropping(to: CGRect(x: tlt.x.double - transformedImage.extent.origin.x / 2,
                                                     y: tlt.z.double + transformedImage.extent.origin.y / 2,
                                                     width: twidth.double,
                                                     height: theight.double))!
        
        let image = UIImage(cgImage: cgImage)
        let image2 = UIImage(cgImage: theTexture)
        
        guard let shapeFaceNode = makeShapeFaceNode(texture: texture) else { return nil }
        shapeFaceNode.eulerAngles = SCNVector3(x: Float.pi/2, y: 0, z: 0)
        shapeFaceNode.position = SCNVector3(0, 0.0, 0.0052) // 表面の位置になるように座標を調整
        node.addChildNode(shapeFaceNode)
        
        guard let shapeFaceNodeG = makeShapeFaceNodeG(geometryPath: path, texture: theTexture) else { return nil }
        //shapeFaceNode.eulerAngles = SCNVector3(x: Float.pi/2, y: 0, z: 0)
        shapeFaceNodeG.position = SCNVector3(0, 0.0, 0.0051) // 表面の位置になるように座標を調整
        node.addChildNode(shapeFaceNodeG)
        
        
        print("tlt \(bblt) \t | \(tlt)")
        print("tlb \(bblb) \t | \(tlb)")
        print("trt \(bbrt) \t | \(trt)")
        print("trb \(bbrb) \t | \(trb)")
        
        
        
//        if applyPhysicsBody {
//            node.physicsBody = makeShapePhysicsBody(from: pathShapeNode.geometry)
//        }
//        
//        print("\(node.boundingBox)")
        
        
        let max = pathShapeNode.boundingBox.max
        let min = pathShapeNode.boundingBox.min
        
        // Calculate the dimensions of the bounding box
        let widthX = CGFloat(max.x / 10 - min.x  / 10)
        let heightX = CGFloat(max.y / 10 - min.y / 10)
        let depth = CGFloat(max.z / 10 - min.z / 10)

        // Create a cube geometry
        let cubeGeometry = SCNBox(width: widthX, height: heightX, length: depth, chamferRadius: 0.0)

        // Create a material with red color and 0.5 opacity
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red.withAlphaComponent(0.5)
        cubeGeometry.materials = [material]

        // Create a cube node
        let cubeNode = SCNNode(geometry: cubeGeometry)

        // Position the cube at the center of the bounding box
        cubeNode.position = SCNVector3(
            x: (min.x + max.x) / 20,
            y: (min.y + max.y) / 20,
            z: (min.z + max.z) / 20
        )
        //cubeNode.scale = SCNVector3(x: 1/10, y: 1/10, z: 1/10)

        // Add the cube node to the scene
        node.addChildNode(cubeNode)
        
        node.scale = SCNVector3(x: 10, y: 10, z: 10)
        
        return node
    }
    
    func convertPt(_ pt : SCNVector3, with minValue : Float, and maxValue : Float) -> SCNVector3 {
        let x = mapToRange(value: pt.x, min: minValue, max: maxValue, targetMin: 0, targetMax: 600)
        let z = mapToRange(value: pt.z, min: minValue, max: maxValue, targetMin: 0, targetMax: 600)
        return SCNVector3(x: x, y: 0, z: z)
    }
    
    func mapToRange(value: Float, min: Float, max: Float, targetMin: Float, targetMax: Float) -> Float {
        // Calculate the scale factor
        let scale = (targetMax - targetMin) / (max - min)
        // Map the value to the target range
        return targetMin + (value - min) * scale
    }

    
    private func makePathShapeNode(geometryPath: UIBezierPath, texture : UIImage? = nil) -> SCNNode {
        let tempGeometryScale = 10.0
        let geometry = SCNShape(path: geometryPath, extrusionDepth: 0.01 * tempGeometryScale)
        let node = SCNNode(geometry: geometry)
        // ベジェパスの座標計算時にいったん、拡大していたので縮小する
        node.scale = SCNVector3(1/tempGeometryScale, 1/tempGeometryScale, 1/tempGeometryScale)
        node.castsShadow = true // ノードの影をつける
        
        if let texture = texture {
            let cgImage = texture.cgImage
            let matrial = SCNMaterial()
            matrial.diffuse.contents = cgImage
            geometry.materials = [matrial]
        } else {
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.lightGray
            geometry.materials = [material]
            node.geometry = geometry
        }
        
        return node
    }
    
    private func makeShapeFaceNode(texture: UIImage) -> SCNNode? {
        // テクスチャを貼るだけのノードを作る
        let textureNode = SCNNode()
        textureNode.geometry = makeShapeFaceGeometory(texture: texture)
        return textureNode
    }
    
    private func makeShapeFaceNodeG(geometryPath: UIBezierPath, texture: CGImage) -> SCNNode? {

        let tempGeometryScale = 10.0
        let geometry = SCNShape(path: geometryPath, extrusionDepth: 0.00 * tempGeometryScale)
        let node = SCNNode(geometry: geometry)
        // ベジェパスの座標計算時にいったん、拡大していたので縮小する
        node.scale = SCNVector3(1/tempGeometryScale, 1/tempGeometryScale, 1/tempGeometryScale)
        node.castsShadow = true // ノードの影をつける
        
        let material = SCNMaterial()
        material.diffuse.contents = texture
        geometry.materials = [material]

        
        return node
    }
    
    private func makeShapeFaceGeometory(texture: UIImage) -> SCNGeometry? {
        
        // テクスチャを貼るノードのポリンゴンのインデックス
        let indices: [Int32] = [
            0, 2, 1,    // 左上、左下、右上の三角形
            1, 2, 3,    // 右上、左下、右下の三角形
        ]
        // テクスチャ座標
        let texcoords: [CGPoint] = [
            CGPoint(x: 0.0, y: 0.0),    // 左上
            CGPoint(x: 1.0, y: 0.0),    // 右上
            CGPoint(x: 0.0, y: 1.0),    // 左下
            CGPoint(x: 1.0, y: 1.0),    // 右下
        ]
        
        // パス検出範囲が四隅となる平面ジオメトリ を作成
       // print("textCoord: \(textCoord)")
        let lt = textCoord.ptScnVector(at: .leftTop)
        let rt = textCoord.ptScnVector(at: .rightTop)
        let lb = textCoord.ptScnVector(at: .leftBottom)
        let rb = textCoord.ptScnVector(at: .rightBottom)
        let vertices = [ lt, rt, lb, rb ]
        
        //print("vertices \(vertices)")
        let verticeSource = SCNGeometrySource(vertices: vertices)
        let texcoordSource = SCNGeometrySource(textureCoordinates: texcoords)
        let geometryElement = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        let geometry = SCNGeometry(sources: [verticeSource, texcoordSource], elements: [geometryElement])
        
        // マテリアルにテクスチャを設定
        let cgImage = texture.cgImage
        let matrial = SCNMaterial()
        matrial.diffuse.contents = cgImage
        geometry.materials = [matrial]
        
        return geometry
    }
    
    private func makeShapePhysicsBody(from: SCNGeometry?) -> SCNPhysicsBody? {
        
        let tempGeometryScale = 10.0
        
        guard let geometry = from else { return nil }
        let bodyMax = geometry.boundingBox.max
        let bodyMin = geometry.boundingBox.min
        let bodyGeometry = SCNBox(width: (bodyMax.x - bodyMin.x).cg * 1 / tempGeometryScale,
                                  height: (bodyMax.y - bodyMin.y).cg * 1 / tempGeometryScale,
                                  length: (bodyMax.z - bodyMin.z).cg * 1 / tempGeometryScale,
                                  chamferRadius: 0.0)
        let bodyShape = SCNPhysicsShape(geometry: bodyGeometry, options: nil)
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: bodyShape)
        physicsBody.friction = 1.0
        physicsBody.restitution = 0.0
        physicsBody.rollingFriction = 1.0
        physicsBody.angularDamping = 1.0
        physicsBody.linearRestingThreshold = 1.0
        physicsBody.angularRestingThreshold = 1.0
        
        return physicsBody
    }
    
    
    
    func perspectiveTransformWithExtent(inputImage: CIImage,
                                        lt : CGPoint,
                                        lb : CGPoint,
                                        rt : CGPoint,
                                        rb : CGPoint) -> CIImage {
        print("original \(inputImage.extent)")
        let lt = lt
        let rt = rt
        let lb = lb
        let rb = rb
        
        print("lt: \(lt)")
        print("rt: \(rt)")
        print("lb: \(lb)")
        print("rb: \(rb)")
        
        let perspectiveTransformFilter = CIFilter.perspectiveTransformWithExtent()
        perspectiveTransformFilter.inputImage = inputImage
        perspectiveTransformFilter.topLeft = lt
        perspectiveTransformFilter.topRight = rt
        perspectiveTransformFilter.bottomLeft = lb
        perspectiveTransformFilter.bottomRight = rb
        perspectiveTransformFilter.extent = CGRect(x: 0, y: 0, width: 480, height: 480)
        return perspectiveTransformFilter.outputImage!
    }
}

extension Float {
    var double : Double {
        return Double(self)
    }
}
