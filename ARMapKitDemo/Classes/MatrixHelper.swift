//
//  MatrixHelper.swift
//  ARMapKitDemo
//
//  Created by Sandeep on 03/02/24.
//

import Foundation
import CoreLocation
import ARKit

class MatrixHelper {

    /// Generates a translation matrix by applying a translation vector to an existing matrix.
    /// - Parameters:
    ///   - matrix: The original matrix to which the translation will be applied.
    ///   - translation: A vector representing the translation to apply.
    /// - Returns: A new matrix that results from applying the translation to the original matrix.
    static func translationMatrix(with matrix: matrix_float4x4, for translation : vector_float4) -> matrix_float4x4 {
        var matrix = matrix
        // Apply the translation vector to the fourth column of the matrix, affecting position but not rotation or scale.
        matrix.columns.3 = translation
        return matrix
    }

    /// Creates a rotation matrix that rotates around the Y-axis by a specified number of degrees.
    /// - Parameters:
    ///   - matrix: The original matrix to which the rotation will be applied.
    ///   - degrees: The angle in radians to rotate around the Y-axis.
    /// - Returns: The inverse of the new matrix that results from applying the rotation.
    ///   Note: Inverting the matrix is useful for transforming coordinates from one space to another, such as from world space to local space.
    static func rotateAroundY(with matrix: matrix_float4x4, for degrees: Float) -> matrix_float4x4 {
        var matrix : matrix_float4x4 = matrix

        // Cosine and sine of the rotation angle are used to calculate the new values for specific elements in the rotation matrix.
        matrix.columns.0.x = cos(degrees)
        matrix.columns.0.z = -sin(degrees)

        matrix.columns.2.x = sin(degrees)
        matrix.columns.2.z = cos(degrees)

        // The inverse is returned to facilitate reverse transformations.
        return matrix.inverse
    }

    /// Computes a transformation matrix that positions an object in AR space relative to the user's location.
    /// - Parameters:
    ///   - matrix: The base transformation matrix, usually the identity matrix for starting transformations.
    ///   - originLocation: The user's current location.
    ///   - location: The target location where the object should appear in AR.
    /// - Returns: A transformation matrix that can be applied to an AR object to place it accurately in the real world.
    static func transformMatrix(for matrix: simd_float4x4, originLocation: CLLocation, location: CLLocation) -> simd_float4x4 {
        // Calculate the distance and bearing from the origin location to the target location.
        let distance = Float(location.distance(from: originLocation))
        let bearing = originLocation.bearingToLocationRadian(location)

        // Create a position vector that moves the object along the Z-axis by the negative distance (towards the user).
        let position = vector_float4(0.0, 0.0, -distance, 0.0)

        // Generate translation and rotation matrices based on the computed position and bearing.
        let translationMatrix = MatrixHelper.translationMatrix(with: matrix_identity_float4x4, for: position)
        let rotationMatrix = MatrixHelper.rotateAroundY(with: matrix_identity_float4x4, for: Float(bearing))

        // Combine the rotation and translation transformations, then apply them to the base matrix.
        let transformMatrix = simd_mul(rotationMatrix, translationMatrix)
        return simd_mul(matrix, transformMatrix)
    }
}
