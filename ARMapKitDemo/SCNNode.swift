//
//  SCNNode+Extensions.swift
//  ARMapKitDemo
//
//  Created by Sandeep on 03/02/24.
//

import SceneKit

extension SCNNode {
    /// Applies a rendering order to the node and its geometry materials to prevent flickering.
    /// This is useful when multiple nodes overlap in the scene.
    /// - Parameter renderingOrder: An optional integer to specify rendering order. Random by default.
    func removeFlicker (withRenderingOrder renderingOrder: Int = Int.random(in: 1..<Int.max)) {
        self.renderingOrder = renderingOrder
        // Disables reading from the depth buffer to prevent flickering, but may affect depth-based rendering effects.
        geometry?.materials.forEach { $0.readsFromDepthBuffer = false }
    }
}
