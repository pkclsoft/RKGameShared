//
//  Elements.swift
//  SKGameShared
//
//  Created by Peter Easdown on 4/9/2025.
//

import RealityKit
import SpriteKit
import SceneKit
import CGExtKit
import UXKit

/// A simple class within which the vertices and indices desribing an SCNGeometry or MeshDescriptor
/// can be built.
///
open class Elements {
    public var vertices : [RKVector]
    public var indices : [UInt32]
    
    public var vectors : [SCNVector3] {
        get {
            var result : [SCNVector3] = []
            
            vertices.forEach { vertex in
                result.append(SCNVector3(vertex))
            }
            
            return result
        }
    }
    
    /// Iniitialises an empty Elements object.
    public init() {
        self.vertices = []
        self.indices = []
    }
    
    /// Initialises a new Element object with the supplied vertices and indices.
    public init(vertices: [RKVector], indices: [UInt32]) {
        self.vertices = vertices
        self.indices = indices
    }
    
    /// Renumbers the indices so that rather than start at zero, they start at the specified value.  This is useful
    /// when merging two Element objects together.
    /// - Parameter startingAt: the new smallest indice number.
    public func renumberIndices(startingAt: UInt32) {
        for index in 0 ..< indices.count {
            indices[index] = indices[index] + startingAt
        }
    }
    
    /// Appends the specified Elements object into self.
    /// - Parameters:
    ///   - elements: the Elements object to append.
    ///   - verticesOnly: when `true`, only the vertices are appended.
    public func append(elements: Elements, verticesOnly: Bool = false) {
        let firstNewVertex : UInt32 = UInt32(self.vertices.count)
        
        self.vertices.append(contentsOf: elements.vertices)

        if !verticesOnly {
            elements.indices.forEach { indice in
                self.indices.append(firstNewVertex + indice)
            }
        }
    }
    
    /// Reposition the elements by moving each of the vertices by the specified offset.
    /// - Parameter offset: the offset to adjust the vertices by.
    public func reposition(withOffset offset: RKVector) {
        var newVertices : [RKVector] = []
        
        self.vertices.forEach { old in
            newVertices.append(old + offset)
        }
        
        self.vertices = newVertices
    }
    
    /// Appends a single vertex.
    /// - Parameter vertex: the vertex to append
    public func append(vertex: RKVector) {
        self.vertices.append(vertex)
    }
    
    /// Appends an array of vertices.
    /// - Parameter vertices: the array to append
    public func append(vertices: [RKVector]) {
        self.vertices.append(contentsOf: vertices)
    }
    
    /// Appends an array of indices.
    /// - Parameter indices: the array to append
    public func append(indices: [UInt32]) {
        self.indices.append(contentsOf: indices)
    }

    /// Computes a new position that is an offset from the input position in a direction at a distance.
    /// - Parameters:
    ///   - position: the starting position
    ///   - direction: the direction of movement; this must be simple X or Z directions on the 90 degree axes.
    ///   - distance: the distance to travel.
    /// - Returns: The resulting position.
    public static func next(fromPosition position: RKVector, inDirection direction: RKVector, byDistance distance: Float) -> RKVector {
        return position + direction * distance
    }
    
    /// Computes the next position, appending it as a vertex, and retutrns it.
    /// - Parameters:
    ///   - position: the starting position
    ///   - direction: the direction of movement; this must be simple X or Z directions on the 90 degree axes.
    ///   - distance: the distance to travel.
    /// - Returns: the resulting position.
    public func append(nextAfter position: RKVector, inDirection direction: RKVector, byDistance distance: Float) -> RKVector {
        let result = Elements.next(fromPosition: position, inDirection: direction, byDistance: distance)
        
        self.append(vertex: result)
        
        return result
    }
    
    /// Returns a simple SceneKit SCNNode representing self.
    /// - Parameters:
    ///   - named: the name of the node being returned
    ///   - withColor: the color of the node
    /// - Returns: An SCNNode representing self.
    public func node(named: String, withColor: UXColor) -> SCNNode {
        let source = SCNGeometrySource(vertices: self.vectors)
        let element = SCNGeometryElement(indices: self.indices, primitiveType: .triangles)
        
        let geometry = SCNGeometry(sources: [source], elements: [element])
        geometry.firstMaterial?.diffuse.contents = withColor
        geometry.firstMaterial?.specular.contents = UXColor.white
        geometry.firstMaterial?.shininess = 1.0

        let result = SCNNode(geometry: geometry)
        result.name = named
        return result
    }
    
    /// Returns a RealityKit MeshDescriptor representing self.
    /// - Parameters:
    ///   - named: the name of the mesh
    ///   - usingMaterial: the index of the material that will be will be mapped to the returned MeshDescriptor when it is added to a ModelEntity.
    /// - Returns: A MeshDescriptor representing self.
    public func meshDescriptor(named: String, usingMaterial: UInt32 = 0) -> MeshDescriptor {
        return meshDescriptor(named: named, usingMaterial: usingMaterial, andIndicesInRange: 0 ..< self.indices.count)
    }
    
    /// Returns a RealityKit MeshDescriptor representing self.
    /// - Parameters:
    ///   - named: the name of the mesh
    ///   - usingMaterial: the index of the material that will be will be mapped to the returned MeshDescriptor when it is added to a ModelEntity.
    ///   - range: the range of indices to use for this mesh.
    /// - Returns: A MeshDescriptor representing self.
    public func meshDescriptor(named: String, usingMaterial: UInt32 = 0, andIndicesInRange range: Range<Int>) -> MeshDescriptor {
        var mesh = MeshDescriptor(name: named)
        mesh.positions = MeshBuffers.Positions(self.vertices)
        mesh.primitives = .triangles(Array(self.indices[range]))
        mesh.materials = .allFaces(usingMaterial)
        
        return mesh
    }
    
    /// Returns a simple RealityKit ModelComponent representation of self.
    /// - Parameters:
    ///   - named: the name of the mesh inside the model
    ///   - withMaterial: A Material object used to render the model.
    /// - Returns: A ModelComponent representation of self.
    @MainActor public func modelComponent(named: String, withMaterial: Material) throws -> ModelComponent {
        return ModelComponent(mesh: try MeshResource.generate(from: [self.meshDescriptor(named: named, usingMaterial: 0)]), materials: [
            withMaterial
        ])
    }
    
    /// Returns a RealityKit ModelEntity representation of self.
    /// - Parameters:
    ///   - named: the name of the entity (and the mesh inside it)
    ///   - withMaterial: A Material object used to render the entity.
    /// - Returns: A ModelEntity representation of self, or if an error occurs in the creation, a simple red sphere.
    @MainActor public func entity(named: String, withMaterial: Material) -> ModelEntity {
        let mesh = self.meshDescriptor(named: named, usingMaterial: 0)
        
        do {
            let meshes : MeshResource = try MeshResource.generate(from: [mesh])
            
            let result = ModelEntity(mesh: meshes, materials: [
                withMaterial
            ])
            
            result.name = named
            
            return result
        } catch {
            print("Unable to create entity for \(named)")
            
            return ModelEntity(components: [ModelComponent(mesh: MeshResource.generateSphere(radius: 0.01), materials: [SimpleMaterial(color: .red, isMetallic: true)])])
        }
    }
    
    /// A utility function for outputting the contents of the vertices for debugging.
    /// - Parameter heading: A heading string for each vertex.
    public func printVertices(withHeading heading: String) {
        var index : Int = 0
        
        self.vertices.forEach { vertex in
            let xStr = String(format: "%.3f", vertex.x)
            let yStr = String(format: "%.3f", vertex.y)
            let zStr = String(format: "%.3f", vertex.z)
            print("[\(heading)][\(index)] - \(xStr), \(yStr), \(zStr)")
            
            index += 1
        }
    }
}
