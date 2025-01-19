//
//  Path.swift
//  Pathology
//
//  Created by Kyle Truscott on 3/2/16.
//  Copyright © 2016 keighl. All rights reserved.
//

import Foundation
import QuartzCore

public struct SerializablePath {
    var elements: [Element] = []
    
    public func toArray() -> [[String: Any]] {
        return elements.map({ el in
            return el.toDictionary()
        })
    }
    
    public func toJSON(options: JSONSerialization.WritingOptions) throws -> Data {
        
        let data = try JSONSerialization.data(withJSONObject: toArray(), options: options)
        return data
    }
    
    public func CGPath() -> QuartzCore.CGPath {
        let path = CGMutablePath()
        for el in elements {
            let endPoint = el.endPoint()
            let ctrl1 = el.ctrlPoint1()
            let ctrl2 = el.ctrlPoint2()
            
            switch el.type {
            case .MoveToPoint:
                path.move(to: CGPoint(x: endPoint.x, y: endPoint.y))
            case .AddLineToPoint:
                path.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y))
                break
            case .AddQuadCurveToPoint:
                path.addQuadCurve(to: CGPoint(x: endPoint.x, y: endPoint.y),
                                  control: CGPoint(x: ctrl1.x, y: ctrl1.y))
                break
            case .AddCurveToPoint:
                path.addCurve(to: CGPoint(x: endPoint.x, y: endPoint.y),
                              control1: CGPoint(x: ctrl1.x, y: ctrl1.y),
                              control2: CGPoint(x: ctrl2.x, y: ctrl2.y))
                break
            case .CloseSubpath:
                path.closeSubpath()
                break
            case .Invalid:
                break
            }
        }
        return path
    }
}


extension SerializablePath {
    public init?(JSON: Data) {
        do {
            
            let obj = try JSONSerialization.jsonObject(with: JSON, options: JSONSerialization.ReadingOptions(rawValue: 0))
            if let arr = obj as? [[String: AnyObject]] {
                self.elements = arr.map({ el in
                    return Element(dictionary: el)
                })
            }
        } catch {
            return nil
        }
    }
    
    public init(data: [[String: AnyObject]]) {
        self.elements = data.map({ el in
            return Element(dictionary: el)
        })
    }
}
