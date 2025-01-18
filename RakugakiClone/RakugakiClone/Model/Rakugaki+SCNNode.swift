//
//  Rakugaki+SCNNode.swift
//  RakugakiClone
//
//  Created by Yu Ho Kwok on 1/18/25.
//

import UIKit
import SceneKit
import RealityKit
import ARKit
import Vision

extension Rakugaki {
    
    func makeNode() -> SCNNode? {
        
        guard let path = self.path , let texture = self.texture else { return nil }
        
        let node = SCNNode()
        node.position = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
        
        
        let pathShapeNode = makePathShapeNode(geometryPath: path)
        pathShapeNode.position = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
        node.addChildNode(pathShapeNode)
        
        guard let shapeFaceNode = makeShapeFaceNode(texture: texture) else { return nil }
        shapeFaceNode.eulerAngles = SCNVector3(x: Float.pi/2, y: 0, z: 0)
        shapeFaceNode.position = SCNVector3(0, 0.0, 0.0051) // 表面の位置になるように座標を調整
        node.addChildNode(shapeFaceNode)
        
        node.physicsBody = makeShapePhysicsBody(from: pathShapeNode.geometry)
        
        return node
    }
    
    private func makePathShapeNode(geometryPath: UIBezierPath) -> SCNNode {
        let tempGeometryScale = 10.0
        let geometry = SCNShape(path: geometryPath, extrusionDepth: 0.01 * tempGeometryScale)
        let node = SCNNode(geometry: geometry)
        // ベジェパスの座標計算時にいったん、拡大していたので縮小する
        node.scale = SCNVector3(1/tempGeometryScale, 1/tempGeometryScale, 1/tempGeometryScale)
        node.castsShadow = true // ノードの影をつける
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.lightGray
        geometry.materials = [material]
        node.geometry = geometry
        
        return node
    }
    
    private func makeShapeFaceNode(texture: UIImage) -> SCNNode? {
        // テクスチャを貼るだけのノードを作る
        let textureNode = SCNNode()
        textureNode.geometry = makeShapeFaceGeometory(texture: texture)
        return textureNode
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
        let lt = leftTop
        let rt = rightTop
        let lb = leftBottom
        let rb = rightBottom
        let vertices = [ lt, rt, lb, rb ]
        
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
    
}
