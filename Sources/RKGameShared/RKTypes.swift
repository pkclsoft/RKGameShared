//
//  RKTypes.swift
//  RKGameShared
//
//  Created by Peter Easdown on 24/7/2025.
//
import Foundation
import RealityKit
import SceneKit

public typealias RKVector = SIMD3<Float>

extension RKVector {
    
    /// Transforms self by rotating 90 degrees to the right.
    /// - Returns: an `RKVector` representing self rotated to the right 90 degrees.
    public func toRight() -> RKVector {
        if x == 0.0 {
            return RKVector(x: -1.0 * z, y: y, z: x)
        } else {
            return RKVector(x: z, y: y, z: x)
        }
    }

#if os(macOS)
    /// Converts a SceneKit vector to a RealityKit vector.
    /// - Parameter from: the input SceneKit vector.
    public init(fromSCNVector from: SCNVector3) {
        self.init(Float(from.x), Float(from.y), Float(from.z))
    }
    #else
    /// Converts a SceneKit vector to a RealityKit vector.
    /// - Parameter from: the input SceneKit vector.
    public init(fromSCNVector from: SCNVector3) {
        self.init(from.x, from.y, from.z)
    }
    #endif
}

public extension RKVector {
    
    /// Adds two RKVectors
    /// - Parameters:
    ///   - left: first RKVector
    ///   - right: second RKVector
    /// - Returns: the sum of the two vectors.
    static func + (left: RKVector, right: RKVector) -> RKVector {
        return RKVector(x: left.x + right.x, y: left.y + right.y, z: left.z + right.z)
    }

    /// Multiplies two RKVectors
    /// - Parameters:
    ///   - left: first RKVector
    ///   - right: second RKVector
    /// - Returns: the product of the two vectors.
    static func * (left: RKVector, right: RKVector) -> RKVector {
        return RKVector(x: left.x * right.x, y: left.y * right.y, z: left.z * right.z)
    }

    /// Muliplies a RKVector by a factor
    /// - Parameters:
    ///   - left: the RKVector
    ///   - right: the floating point factor
    /// - Returns: the product
    static func * (left: RKVector, right: Float) -> RKVector {
        return RKVector(x: left.x * right, y: left.y * right, z: left.z * right)
    }
    
    /// Returns the distance from self to the specified RKVector
    /// - Parameter vector: the other vector
    /// - Returns: a distance between the two vectors
    func distance(to vector: RKVector) -> Float {
        return simd_distance(simd_float3(self), simd_float3(vector))
    }
}

extension SCNVector3 {
    #if os(macOS)
    /// Converts a RealityKit vector to a SceneKit vector.
    /// - Parameter from: the input RealityKit vector.
    public init(fromRKVector vector: RKVector) {
        self.init(x: CGFloat(vector.x), y: CGFloat(vector.y), z: CGFloat(vector.z))
    }
    #else
    /// Converts a RealityKit vector to a SceneKit vector.
    /// - Parameter from: the input RealityKit vector.
    public init(fromRKVector vector: RKVector) {
        self.init(x: vector.x, y: vector.y, z: vector.z)
    }
    #endif
}
