//
//  Pathology.swift
//  Pathology
//
//  Created by Kyle Truscott on 3/1/16.
//  Copyright © 2016 keighl. All rights reserved.
//

import Foundation
import QuartzCore

typealias PathApplier = @convention(block) (UnsafePointer<CGPathElement>) -> Void

struct Pathology {
    
    static func pathApply(path: CGPath!, block: @escaping PathApplier) {
        
        let callback: @convention(c) (UnsafeMutableRawPointer, UnsafePointer<CGPathElement>) -> Void = { (info, element) in
            let block = unsafeBitCast(info, to: PathApplier.self)
            block(element)
        }
        
        path.apply(info: unsafeBitCast(block, to: UnsafeMutableRawPointer.self),
                   function: unsafeBitCast(callback, to: CGPathApplierFunction.self))
    }
    
    static func extract(path: CGPath) -> SerializablePath {
        var pathData = SerializablePath(elements: [])
        pathApply(path: path) { element in
            
            switch (element.pointee.type) {
            case CGPathElementType.moveToPoint:
                pathData.elements.append(Element(type: .MoveToPoint, points: [
                    element.pointee.points[0]
                ]))
            case .addLineToPoint:
                pathData.elements.append(Element(type: .AddLineToPoint, points: [
                    element.pointee.points[0],
                ]))
            case .addQuadCurveToPoint:
                pathData.elements.append(Element(type: .AddQuadCurveToPoint, points: [
                    element.pointee.points[1], // end pt
                    element.pointee.points[0], // ctlpr pt
                ]))
            case .addCurveToPoint:
                pathData.elements.append(Element(type: .AddCurveToPoint, points: [
                    element.pointee.points[2], // end pt
                    element.pointee.points[0], // ctlpr 1
                    element.pointee.points[1], // ctlpr 2
                ]))
            case .closeSubpath:
                pathData.elements.append(Element(type: .CloseSubpath, points: []))
            @unknown default:
                print("do nothing")
            }
        }
        return pathData
    }
    
}
