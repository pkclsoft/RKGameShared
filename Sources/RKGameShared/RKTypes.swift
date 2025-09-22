//
//  RKTypes.swift
//  SKGameShared
//
//  Created by Peter Easdown on 24/7/2025.
//
import Foundation
import RealityKit
import SceneKit

public typealias RKVector = SIMD3<Float>

extension RKVector {

    public func toRight() -> RKVector {
        if x == 0.0 {
            return RKVector(x: -1.0 * z, y: y, z: x)
        } else {
            return RKVector(x: z, y: y, z: x)
        }
    }

    #if os(macOS)
    public init(fromSCNVector from: SCNVector3) {
        self.init(Float(from.x), Float(from.y), Float(from.z))
    }
    #else
    public init(fromSCNVector from: SCNVector3) {
        self.init(from.x, from.y, from.z)
    }
    #endif
}

public extension RKVector {
    
    static func + (left: RKVector, right: RKVector) -> RKVector {
        return RKVector(x: left.x + right.x, y: left.y + right.y, z: left.z + right.z)
    }

    static func * (left: RKVector, right: RKVector) -> RKVector {
        return RKVector(x: left.x * right.x, y: left.y * right.y, z: left.z * right.z)
    }

    static func * (left: RKVector, right: Float) -> RKVector {
        return RKVector(x: left.x * right, y: left.y * right, z: left.z * right)
    }
    
    func distance(to vector: RKVector) -> Float {
        return simd_distance(simd_float3(self), simd_float3(vector))
    }
}

extension SCNVector3 {
    #if os(macOS)
    public init(fromRKVector vector: RKVector) {
        self.init(x: CGFloat(vector.x), y: CGFloat(vector.y), z: CGFloat(vector.z))
    }
    #else
    public init(fromRKVector vector: RKVector) {
        self.init(x: vector.x, y: vector.y, z: vector.z)
    }
    #endif
}
