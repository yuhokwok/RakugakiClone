//
//  CodableBezierPath.swift
//  RakugakiClone
//
//  Created by Yu Ho Kwok on 1/18/25.
//

import UIKit

/// A simple wrapper around `UIBezierPath` that makes it Codable.
/// Internally, it archives/unarchives a `UIBezierPath` via NSKeyedArchiver.
struct CodableBezierPath: Codable {
    private let archivedData: Data
    
    /// Initialize from an existing `UIBezierPath`.
    init(path: UIBezierPath) throws {
        // Archive the path.
        // `requiringSecureCoding: false` is often used for older OS versions or non-secure archives.
        // Adjust to `true` if you need secure coding throughout your app.
        self.archivedData = try NSKeyedArchiver.archivedData(withRootObject: path,
                                                             requiringSecureCoding: false)
    }
    
    /// Reconstruct the `UIBezierPath` from archived data.
    func toBezierPath() throws -> UIBezierPath {
        guard let path = try NSKeyedUnarchiver
                .unarchivedObject(ofClass: UIBezierPath.self, from: archivedData)
        else {
            throw NSError(domain: "CodableBezierPath", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to unarchive UIBezierPath"])
        }
        return path
    }
    
    // MARK: - Codable conformance
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.archivedData = try container.decode(Data.self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(archivedData)
    }
}
