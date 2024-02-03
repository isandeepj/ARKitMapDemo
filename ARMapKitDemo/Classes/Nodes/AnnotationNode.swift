//
//  AnnotationNode.swift
//  ARMapKitDemo
//
//  Created by Sandeep on 03/02/24.
//

import Foundation
import SceneKit

class AnnotationNode: SCNNode {
    var view: UIView?
    var image: UIImage?

    /// Initializes an annotation node with either a UIView or UIImage.
    /// - Parameters:
    ///   - view: An optional UIView to convert to a texture.
    ///   - image: An optional UIImage to use directly as a texture.
    init(view: UIView?, image: UIImage?) {
        super.init()
        self.view = view
        self.image = image
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
