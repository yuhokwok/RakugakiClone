//
//  Tuya.swift
//  RakugakiClone
//
//  Created by Yu Ho Kwok on 19/1/2025.
//

import SwiftData
import Foundation

import Metal
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
        
        
////        print("textureNode: \(textCoord)")
//        let lt = textCoord.ptScnVector(at: .leftTop)
//        let lb = textCoord.ptScnVector(at: .leftBottom)
//        let rt = textCoord.ptScnVector(at: .rightTop)
//        let rb = textCoord.ptScnVector(at: .rightBottom)
//        
//        let widthTop    = rt.x - lt.x
//        let widthBottom = rb.x - lb.x
//        let width       = max(widthTop, widthBottom)
//        
//        let minX = (widthTop > widthBottom) ? lt.x : lb.x
//        let maxX = (widthTop > widthBottom) ? rt.x : rb.x
//
//        let heightLeft = lb.z - lt.z
//        let heightRight = rb.z - rt.z
//        let height = max(heightLeft, heightRight)
//        
//        let minY = (heightLeft > heightRight) ? lt.z : rt.z
//        let maxY = (heightLeft > heightRight) ? lb.z : rb.z
//
//        let minValue = minX // (height > width) ? minY : minX
//        let maxValue = maxX // (height > width) ? maxY : maxX
//
//        let ilt = lt * 3000 //convertPt(lt, withMin: minValue, andMax: maxValue)
//        let ilb = lb * 3000 //convertPt(lb, withMin: minValue, andMax: maxValue)
//        let irt = rt * 3000 //convertPt(rt, withMin: minValue, andMax: maxValue)
//        let irb = rb * 3000 //convertPt(rb, withMin: minValue, andMax: maxValue)
//        
//        print("ilt \(lt) | \(ilt)")
//        print("ilb \(lb) | \(ilb)")
//        print("irt \(rt) | \(irt)")
//        print("irb \(rb) | \(irb)")
//        print("min: \(minValue)")
//        print("max: \(maxValue)")
//        
//        //let geometry = SCNShape(path: path, extrusionDepth: 0.01)
//        let boundingBox = pathShapeNode.boundingBox
//        let boundingBoxMax = pathShapeNode.boundingBox.max
//        let boundingBoxMin = pathShapeNode.boundingBox.min
//        print("geometry: \(pathShapeNode.boundingBox)")
//        
//        let bblt = SCNVector3(boundingBoxMin.x / 10, 0, -boundingBoxMax.y / 10)
//        let bblb = SCNVector3(boundingBoxMin.x / 10, 0, -boundingBoxMin.y / 10)
//        let bbrt = SCNVector3(boundingBoxMax.x / 10, 0, -boundingBoxMax.y / 10)
//        let bbrb = SCNVector3(boundingBoxMax.x / 10, 0, -boundingBoxMin.y / 10)
//        
//        let tlt = convertPt(bblt, withMin: minValue, andMax: maxValue)
//        let tlb = convertPt(bblb, withMin: minValue, andMax: maxValue)
//        let trt = convertPt(bbrt, withMin: minValue, andMax: maxValue)
//        let trb = convertPt(bbrb, withMin: minValue, andMax: maxValue)
//        
//        let twidth = trt.x - tlt.x
//        let theight = trb.z - trt.z
//
//        let t = texture
//        let  transformedImage = perspectiveTransformWithExtent(inputImage: CIImage(image: texture)!,
//                                                          lt: CGPoint(x: ilt.x.double, y: 600 - ilt.z.double),
//                                                          lb: CGPoint(x: ilb.x.double, y: 600 - ilb.z.double),
//                                                          rt: CGPoint(x: irt.x.double, y: 600 - irt.z.double),
//                                                          rb: CGPoint(x: irb.x.double, y: 600 - irb.z.double))
//        

//        let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent)!
////        let theTexture = cgImage.cropping(to: CGRect(x: tlt.x.double,
////                                                     y: tlt.z.double,
////                                                     width: twidth.double,
////                                                     height: theight.double))!
//        
//        let clipped = transformedImage.clippedToNonTransparent() ?? transformedImage
//        let theTexture = context.createCGImage(clipped, from: clipped.extent)!
//        
//        let image = UIImage(cgImage: cgImage)
//        let image2 = UIImage(cgImage: theTexture)
        
        guard let shapeFaceNode = makeShapeFaceNode(texture: texture) else { return nil }
        shapeFaceNode.eulerAngles = SCNVector3(x: Float.pi/2, y: 0, z: 0)
        shapeFaceNode.position = SCNVector3(0, 0.0, 0.0152) // 表面の位置になるように座標を調整
        shapeFaceNode.scale = SCNVector3(x: 20, y: 1, z: 20)
        //node.addChildNode(shapeFaceNode)
        let extractedImage = shapeFaceNode.snapshot(
            size: CGSize(width: 1024, height: 1024),
            backgroundColor: .clear,
            cameraPosition: SCNVector3(x: 0, y: 0, z: 1.5)
        )

        let context = CIContext(options: nil)
        
        if let extractedImage = extractedImage, let ciExtractedImage = CIImage(image: extractedImage),
            let clipped = ciExtractedImage.clippedToNonTransparent(),
            let theTexture = context.createCGImage(clipped, from: clipped.extent)  {

            guard let shapeFaceNodeG = makeShapeFaceNodeG(geometryPath: path, texture: theTexture) else { return nil }
            //shapeFaceNode.eulerAngles = SCNVector3(x: Float.pi/2, y: 0, z: 0)
            shapeFaceNodeG.position = SCNVector3(0, 0.0, 0.0051) // 表面の位置になるように座標を調整
            node.addChildNode(shapeFaceNodeG)
            
        }
        
//        let ttciimage = CIImage(image: ttimage!)
//        let ttclipped = ttciimage?.clippedToNonTransparent()
//        let tttheTexture = context.createCGImage(ttclipped, from: ttclipped.extent)!
//        
//        guard let shapeFaceNodeG = makeShapeFaceNodeG(geometryPath: path, texture: tttheTexture) else { return nil }
//        //shapeFaceNode.eulerAngles = SCNVector3(x: Float.pi/2, y: 0, z: 0)
//        shapeFaceNodeG.position = SCNVector3(0, 0.0, 0.0051) // 表面の位置になるように座標を調整
//        node.addChildNode(shapeFaceNodeG)
        
        
//        print("tlt \(bblt) \t | \(tlt)")
//        print("tlb \(bblb) \t | \(tlb)")
//        print("trt \(bbrt) \t | \(trt)")
//        print("trb \(bbrb) \t | \(trb)")
//        
//        
        
//        if applyPhysicsBody {
//            node.physicsBody = makeShapePhysicsBody(from: pathShapeNode.geometry)
//        }
//        
//        print("\(node.boundingBox)")
        
        
//        let max = pathShapeNode.boundingBox.max
//        let min = pathShapeNode.boundingBox.min
        
        // Calculate the dimensions of the bounding box
//        let widthX = CGFloat(max.x / 10 - min.x  / 10)
//        let heightX = CGFloat(max.y / 10 - min.y / 10)
//        let depth = CGFloat(max.z / 10 - min.z / 10)
//
//        // Create a cube geometry
//        let cubeGeometry = SCNBox(width: widthX, height: heightX, length: depth, chamferRadius: 0.0)
//
//        // Create a material with red color and 0.5 opacity
//        let material = SCNMaterial()
//        material.diffuse.contents = UIColor.red.withAlphaComponent(0.5)
//        cubeGeometry.materials = [material]
//
//        // Create a cube node
//        let cubeNode = SCNNode(geometry: cubeGeometry)
//
//        // Position the cube at the center of the bounding box
//        cubeNode.position = SCNVector3(
//            x: (min.x + max.x) / 20,
//            y: (min.y + max.y) / 20,
//            z: (min.z + max.z) / 20
//        )
        //cubeNode.scale = SCNVector3(x: 1/10, y: 1/10, z: 1/10)

        // Add the cube node to the scene
//        node.addChildNode(cubeNode)
        
        //node.scale = SCNVector3(x: 10, y: 10, z: 10)
        
        return node
    }
    
    func convertPt(_ pt : SCNVector3,
                   withMin minValue : Float, andMax maxValue : Float
                   //, withMinY minYValue : Float, andMaxY maxYValue : Float
                ) -> SCNVector3 {
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
        
        let perspectiveTransformFilter = CIFilter.perspectiveTransform()
        perspectiveTransformFilter.inputImage = inputImage
        perspectiveTransformFilter.topLeft = lt
        perspectiveTransformFilter.topRight = rt
        perspectiveTransformFilter.bottomLeft = lb
        perspectiveTransformFilter.bottomRight = rb
        //perspectiveTransformFilter.extent = CGRect(x: 0, y: 0, width: 480, height: 480)
        return perspectiveTransformFilter.outputImage!
    }
}

extension Float {
    var double : Double {
        return Double(self)
    }
}

import CoreImage
import UIKit

extension CIImage {
    
    /// Returns a new CIImage cropped to remove all pixels whose alpha <= alphaThreshold.
    /// - Parameter alphaThreshold: A value between 0.0 and 1.0.
    ///   Defaults to 0.0 (meaning *any* alpha above 0 is kept).
    /// - Returns: A cropped CIImage, or nil if the image was fully transparent.
    func clippedToNonTransparent(alphaThreshold: CGFloat = 0.0) -> CIImage? {
        // 1) Create a CIContext + CGImage for pixel inspection
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(self, from: extent) else {
            return nil
        }
        
        // 2) Inspect pixels to find the bounding box of non-transparent pixels
        let width = cgImage.width
        let height = cgImage.height
        
        // Allocate a buffer for RGBA
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        
        // Draw cgImage into our pixelData buffer
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let contextBitmap = CGContext(data: &pixelData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        contextBitmap.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // We'll scan for alpha > alphaThreshold (in [0…1])
        // Track the min/max of (x, y) where alpha is above threshold
        let thresholdInt = UInt8(alphaThreshold * 255.0)
        
        var minX = Int.max
        var minY = Int.max
        var maxX = Int.min
        var maxY = Int.min
        
        // Pixel format is RGBA premultiplied, so alpha is at index 3
        for y in 0 ..< height {
            for x in 0 ..< width {
                let i = (y * width + x) * bytesPerPixel
                let alpha = pixelData[i + 3]
                
                if alpha > thresholdInt {
                    // This pixel has alpha above threshold, update bounding box
                    if x < minX { minX = x }
                    if x > maxX { maxX = x }
                    if y < minY { minY = y }
                    if y > maxY { maxY = y }
                }
            }
        }
        
        // If we never updated min/max, the entire image was transparent
        guard minX <= maxX, minY <= maxY else {
            return nil
        }
        
        // 3) Convert from bottom-left Y-based to Core Image coordinate system
        // Note: In Core Image, (0,0) is bottom-left if not otherwise transformed.
        // Our (y=0) started at the top in the drawn context, so we need to invert.
        // However, by default, the CGImage data is top-left origin, so we can handle
        // that by flipping the Y coordinate range:
        let croppedRect = CGRect(x: CGFloat(minX) + self.extent.origin.x,
                                 y: CGFloat(height - 1 - maxY) + self.extent.origin.y ,
                                 width: CGFloat(maxX - minX + 1),
                                 height: CGFloat(maxY - minY + 1))
        
        // 4) Crop the original CIImage
        
        let croppedImage = self.cropped(to: croppedRect)
        
        return croppedImage
    }
    
    
    /// Convenience method to also resize after clipping.
    /// - Parameters:
    ///   - alphaThreshold: threshold for transparency clipping.
    ///   - targetSize: desired pixel size. (Width/height in points or pixels, depending on the context.)
    /// - Returns: A resized CIImage or nil if fully transparent.
    func clippedAndResized(
        alphaThreshold: CGFloat = 0.0,
        to targetSize: CGSize
    ) -> CIImage? {
        // First, clip to remove transparent pixels
        guard let clipped = self.clippedToNonTransparent(alphaThreshold: alphaThreshold) else {
            return nil
        }
        
        // Then apply an affine transform to scale to `targetSize`.
        // We'll do a scale in both directions. We'll assume `clipped.extent.size` is the original size.
        let currentSize = clipped.extent.size
        
        let scaleX = targetSize.width / currentSize.width
        let scaleY = targetSize.height / currentSize.height
        
        let scaleTransform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        
        // CIAffineTransform filter
        return clipped.transformed(by: scaleTransform)
    }
}

extension SCNNode {
    func snapshot(size: CGSize = CGSize(width: 512, height: 512),
                 backgroundColor: UIColor = .clear,
                 cameraPosition: SCNVector3 = SCNVector3(x: 0, y: 0, z: 1)) -> UIImage? {
        
        let scene = SCNScene()
        scene.rootNode.addChildNode(self)
        
        let scnView = SCNView(frame: CGRect(origin: .zero, size: size))
        scnView.scene = scene
        scnView.backgroundColor = backgroundColor
        scnView.antialiasingMode = .multisampling4X
        
        // Setup camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = cameraPosition
        cameraNode.camera?.usesOrthographicProjection = true
        cameraNode.camera?.orthographicScale = 2.0
        scene.rootNode.addChildNode(cameraNode)
        
        // Add lighting
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.intensity = 100
        scene.rootNode.addChildNode(ambientLightNode)
        
        // Point camera at the node
        let constraint = SCNLookAtConstraint(target: self)
        cameraNode.constraints = [constraint]
        
        // Render
        //scnView.rendersToCameraColorBuffer = true
        //scnView.render
        
        let renderer = SCNRenderer(device: MTLCreateSystemDefaultDevice(), options: nil)
        renderer.scene = scene
        
        let renderTime = TimeInterval(0)
        let image = renderer.snapshot(atTime: renderTime, with: size, antialiasingMode: .multisampling2X)
        
        return image
    }
}
