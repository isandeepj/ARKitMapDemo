//
//  SCNVector3.swift
//  ARMapKitDemo
//
//  Created by Sandeep on 03/02/24.
//

import SceneKit


extension SCNVector3 {
    /// Calculates the distance between the current vector and another vector in 3D space, ignoring the y component.
    func distance(to anotherVector: SCNVector3) -> Float {
        // Utilizes Pythagorean theorem in 2D (ignoring height differences).
        return sqrt(pow(anotherVector.x - x, 2) + pow(anotherVector.z - z, 2))
    }

    /// Converts a 4x4 transformation matrix into an SCNVector3 by extracting its translation components.
   static func positionFromTransform(_ transform: matrix_float4x4) -> SCNVector3 {
       // Extracts the translation part of the transform matrix.
        return SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    }

}
