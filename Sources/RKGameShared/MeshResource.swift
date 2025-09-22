//
//  MeshResource.swift
//  SKGameShared
//
//  Created by Peter Easdown on 25/7/2025.
//


import RealityKit
import SwiftUI

public extension MeshResource {
    
    /// Generates a tube mesh, where the orientation is looking down the centre of the tube.
    ///
    /// This code has been gratefully borrowed from:
    /// https://github.com/maxxfrazer/RealityGeometries
    ///
    /// - Parameters:
    ///   - radius: The outer radius of the tube
    ///   - thick: The thickness of the tube wall.  This needs to be less than `radius`.
    ///   - height: The height, or length of the tube.
    /// - Returns: A mesh describing a tube meeting the specification provided in the parameters.
    static func generateTube(
        radius: Float,
        thick: Float,
        height: Float,
    ) throws -> some MeshResource {
        let diameter = CGFloat(radius * 2.0)
        let internalDiameter = diameter - CGFloat(thick * 2.0)
        let innerShape = Circle().size(width: internalDiameter, height: internalDiameter)
        let roundShape = Circle().size(width: diameter, height: diameter)
        
        if #available(macOS 15.0, visionOS 2.0, iOS 18.0, *) {
            let hollowCircle = roundShape
                .symmetricDifference(innerShape.offset(x: CGFloat(thick), y: CGFloat(thick)))
            
            var options = MeshResource.ShapeExtrusionOptions()
            options.extrusionMethod = .linear(depth: height)
            
            return try MeshResource(
                extruding: hollowCircle.path(
                    in:CGRect(x: 0.0, y: 0.0, width: diameter, height: diameter)
                ),
                extrusionOptions: options
            )
        } else {
            // Fallback on earlier versions
            return MeshResource.generateBox(size: RKVector(radius * 2.0, height, radius * 2.0), cornerRadius: radius)
        }
        
    }
    
    /// Generates a pyramid mesh, noting that there are no rounded edges.
    /// - Parameters:
    ///   - width: the width (X axis) of the base of the pyramid.
    ///   - height: The height (Y axis) of the pyramid.
    ///   - depth: the depth (Z axis) of the base of the pyramid.
    /// - Returns: A mesh in the shape of a pyramid meeting the specification provided in the parameters.
    static func generatePyramid(
        width: Float,
        height: Float,
        depth: Float,
    ) throws -> some MeshResource {
        let vertices = MeshBuffers.Positions([
            RKVector(width / -2.0, height / -2.0, depth / -2.0),
            RKVector(width / -2.0, height / -2.0, depth /  2.0),
            RKVector(width /  2.0, height / -2.0, depth /  2.0),
            RKVector(width /  2.0, height / -2.0, depth / -2.0),

            RKVector(0.0,          height /  2.0, 0.0),
        ])
        
        let indices : [UInt32] = [
            0, 1, 4,
            1, 2, 4,
            2, 3, 4,
            3, 0, 4,

            0, 4, 1,
            1, 4, 2,
            2, 4, 3,
            3, 4, 0,
            
            0, 1, 2,
            1, 2, 3,
            0, 2, 1,
            1, 3, 2,
        ]
        
        var pyramid = MeshDescriptor(name: "pyramid")
        pyramid.positions = vertices
        pyramid.primitives = .triangles(indices)
        pyramid.materials = .allFaces(0)
        
        return try MeshResource.generate(from: [pyramid])
    }
    
    static func boxElements(ofSize: RKVector) -> Elements {
        let result : Elements = Elements()
        
        result.append(vertices: [
            RKVector(-ofSize.x / 2.0,  -ofSize.y / 2.0,  -ofSize.z / 2.0),
            RKVector( ofSize.x / 2.0,  -ofSize.y / 2.0,  -ofSize.z / 2.0),
            RKVector(-ofSize.x / 2.0,   ofSize.y / 2.0,  -ofSize.z / 2.0),
            RKVector( ofSize.x / 2.0,   ofSize.y / 2.0,  -ofSize.z / 2.0),
            
            RKVector(-ofSize.x / 2.0,  -ofSize.y / 2.0,   ofSize.z / 2.0),
            RKVector( ofSize.x / 2.0,  -ofSize.y / 2.0,   ofSize.z / 2.0),
            RKVector(-ofSize.x / 2.0,   ofSize.y / 2.0,   ofSize.z / 2.0),
            RKVector( ofSize.x / 2.0,   ofSize.y / 2.0,   ofSize.z / 2.0),
        ])
        
        result.append(indices: [
            0, 2, 1,
            1, 2, 3,
            
            5, 4, 0,
            1, 5, 0,
            
            6, 2, 0,
            4, 6, 0,
            
            2, 6, 7,
            2, 7, 3,
            
            1, 3, 7,
            1, 7, 5,

            7, 6, 4,
            5, 7, 4,
        ])

        return result
    }
    
    /// Generates a mesh describing a box.  When the `chamferRadius` is zero, then the mesh is generated without any rounded edges or
    /// corners at all, providing a far more efficient implementation.
    /// - Parameters:
    ///   - ofSize: the size of the box
    ///   - chamferRadius: the radius of the corner/chamfer on all edges.
    /// - Returns: A mesh in the shape of a box meeting the specification provided in the parameters.
    static func generateBox(ofSize: RKVector, chamferRadius: Float = 0.0) -> MeshResource {
        // if the chamfer radius is > 0 then use the RealityKit primitive, otherwise create a much more
        // efficient box.
        //
        if chamferRadius > 0.0 {
            return .generateBox(size: ofSize, cornerRadius: chamferRadius)
        } else {
            return try! MeshResource.generate(from: [boxElements(ofSize: ofSize).meshDescriptor(named: "box")])
        }
    }

    private static func addSide(startingAt: RKVector, inDirection: RKVector, withCornerRadius: Float, toRoundedRectangle roundedRectangle: Elements) {
        var pos = startingAt
        
        // add the starting point
        roundedRectangle.append(vertex: pos)
        
        pos = pos + inDirection

        // add the end of the side
        roundedRectangle.append(vertex: pos)
        
        // now add points curving to the left from pos to create a corner.
        let numberOfCornerPoints = 3
        
        var startAngle : Float
        
        if inDirection.x > 0.0 {
            pos.z -= withCornerRadius
            startAngle = .pi / 2.0
        } else if inDirection.x < 0.0 {
            pos.z += withCornerRadius
            startAngle = .pi * 1.5
        } else {
            if inDirection.z > 0.0 {
                pos.x += withCornerRadius
                startAngle = .pi
            } else {
                pos.x -= withCornerRadius
                startAngle = .pi * 2.0
            }
        }
        
        // for debugging purposes, add the arc centre
//        roundedRectangle.append(vertex: pos)

        let arcCentre : CGPoint = CGPoint(x: CGFloat(pos.x), y: CGFloat(pos.z))

        let cornerPointAngleDelta = (.pi / -2.0) / Float(numberOfCornerPoints + 1)
        
        for pointIndex in 1 ... numberOfCornerPoints {
            let angle = CGFloat(cornerPointAngleDelta * Float(pointIndex) + startAngle)
            let curvePos = arcCentre.pointOnCircle(withRadius: CGFloat(withCornerRadius), atRadians: angle)
            roundedRectangle.append(vertex: RKVector(x: Float(curvePos.x), y: startingAt.y, z: Float(curvePos.y)))
        }
    }
    
    static func generateRoundedBox(ofSize: RKVector, withXandZCornerRadius: Float) throws -> MeshResource {
        return try generateRoundedBox(ofSize: ofSize, lowerScale: 1.0, withXandZCornerRadius: withXandZCornerRadius)
    }
    
    static func generateRoundedBox(ofSize: RKVector,
                                   lowerScale: Float,
                                   withLowerFace: Bool = true,
                                   withTopFace: Bool = true,
                                   adjustLowerBy: RKVector = .zero,
                                   withXandZCornerRadius: Float) throws -> MeshResource {
        let xLeft = ofSize.x / -2.0
        let xRight = ofSize.x / 2.0
        let zFar = ofSize.z / -2.0
        let zNear = ofSize.z / 2.0
        let twoCorners = withXandZCornerRadius * 2.0
        
        
        let elements: Elements = Elements()
        
        elements.append(vertex: RKVector(0.0, ofSize.y, 0.0))
        elements.append(vertex: RKVector(0.0, 0.0, 0.0))

        addSide(startingAt: RKVector(xLeft + withXandZCornerRadius, ofSize.y, zNear),
                inDirection: RKVector(ofSize.x - twoCorners, 0.0, 0.0),
                withCornerRadius: withXandZCornerRadius,
                toRoundedRectangle: elements)
        
        addSide(startingAt: RKVector(xRight, ofSize.y, zNear - withXandZCornerRadius),
                inDirection: RKVector(0.0, 0.0, -(ofSize.z - twoCorners)),
                withCornerRadius: withXandZCornerRadius,
                toRoundedRectangle: elements)
        
        addSide(startingAt: RKVector(xRight - withXandZCornerRadius, ofSize.y, zFar),
                inDirection: RKVector(-(ofSize.x - twoCorners), 0.0, 0.0),
                withCornerRadius: withXandZCornerRadius,
                toRoundedRectangle: elements)
        
        addSide(startingAt: RKVector(xLeft, ofSize.y, zFar + withXandZCornerRadius),
                inDirection: RKVector(0.0, 0.0, ofSize.z - twoCorners),
                withCornerRadius: withXandZCornerRadius,
                toRoundedRectangle: elements)
        
        let firstPointOnRectangle = UInt32(2)
        let pointsPerLayer = UInt32(elements.vertices.count) - firstPointOnRectangle
        
        addSide(startingAt: RKVector((xLeft + withXandZCornerRadius) * lowerScale, 0.0, zNear * lowerScale) + adjustLowerBy,
                inDirection: RKVector((ofSize.x - twoCorners) * lowerScale, 0.0, 0.0),
                withCornerRadius: withXandZCornerRadius * lowerScale,
                toRoundedRectangle: elements)
        
        addSide(startingAt: RKVector(xRight * lowerScale, 0.0, (zNear - withXandZCornerRadius) * lowerScale) + adjustLowerBy,
                inDirection: RKVector(0.0, 0.0, -(ofSize.z - twoCorners) * lowerScale),
                withCornerRadius: withXandZCornerRadius * lowerScale,
                toRoundedRectangle: elements)
        
        addSide(startingAt: RKVector((xRight - withXandZCornerRadius) * lowerScale, 0.0, zFar * lowerScale) + adjustLowerBy,
                inDirection: RKVector(-(ofSize.x - twoCorners) * lowerScale, 0.0, 0.0),
                withCornerRadius: withXandZCornerRadius * lowerScale,
                toRoundedRectangle: elements)
        
        addSide(startingAt: RKVector(xLeft * lowerScale, 0.0, (zFar + withXandZCornerRadius) * lowerScale) + adjustLowerBy,
                inDirection: RKVector(0.0, 0.0, (ofSize.z - twoCorners) * lowerScale),
                withCornerRadius: withXandZCornerRadius * lowerScale,
                toRoundedRectangle: elements)

//        elements.printVertices(withHeading: "mat")
        for index in firstPointOnRectangle ..< firstPointOnRectangle + pointsPerLayer - 1 {
            elements.append(indices: [
                index, index + pointsPerLayer, index + 1,
                index + pointsPerLayer, index + pointsPerLayer + 1, index + 1,
            ])
            
            if withLowerFace {
                elements.append(indices: [
                    firstPointOnRectangle - 1, index + 1 + pointsPerLayer, index + pointsPerLayer,
                ])
            }
            
            if withTopFace {
                elements.append(indices: [
                    firstPointOnRectangle - 2, index, index + 1,
                ])
            }
        }
        
        elements.append(indices: [
            firstPointOnRectangle + pointsPerLayer - 1, firstPointOnRectangle + (pointsPerLayer * 2) - 1, firstPointOnRectangle + pointsPerLayer,
            firstPointOnRectangle + pointsPerLayer - 1, firstPointOnRectangle + pointsPerLayer, firstPointOnRectangle,
        ])
        
        if withLowerFace {
            elements.append(indices: [
                firstPointOnRectangle - 1, firstPointOnRectangle + pointsPerLayer, firstPointOnRectangle + (pointsPerLayer * 2) - 1,
            ])
        }
        
        if withTopFace {
            elements.append(indices: [
                firstPointOnRectangle - 2, firstPointOnRectangle + pointsPerLayer - 1, firstPointOnRectangle,
            ])
        }

        return try! MeshResource.generate(from: [elements.meshDescriptor(named: "box", usingMaterial: 0)])
    }

}
