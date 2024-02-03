//
//  LocationAnnotationNode.swift
//  ARMapKitDemo
//
//  Created by Sandeep on 03/02/24.
//

import Foundation
import SceneKit
import CoreLocation
import ARKit

class LocationAnnotationNode: SCNNode {
    let annotationNode: AnnotationNode
    var businessPOI: BusinessPOI!
    var location: CLLocation? { businessPOI?.location}
    var anchor: ARAnchor?
    
    /// Initializes a location annotation node with a business POI and its visual representation.
    /// - Parameters:
    ///   - businessPOI: The point of interest the node represents.
    ///   - view: A UIView to use as the visual representation.
    convenience init(businessPOI: BusinessPOI!, view: UIView) {
        self.init(businessPOI: businessPOI, image: view.image)
    }

    /// Primary initializer using an image.
    /// - Parameters:/Users/sandeep/Documents/Learning/ARMapKitDemo/ARMapKitDemo.xcodeproj
    ///   - businessPOI: The point of interest the node represents.
    ///   - image: An image to use for the annotation.
    init(businessPOI: BusinessPOI!, image: UIImage) {
        let plane = SCNPlane(width: image.size.width / 100, height: image.size.height / 100)
        plane.firstMaterial?.diffuse.contents = image
        plane.firstMaterial?.lightingModel = .constant

        annotationNode = AnnotationNode(view: nil, image: image)
        annotationNode.geometry = plane
        annotationNode.removeFlicker()
        super.init()
        self.businessPOI = businessPOI

        // Ensures the annotation always faces the camera.
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = .Y
        self.constraints = [billboardConstraint]

        self.addChildNode(annotationNode)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIView {
    /// Creates a styled UIView with a UILabel centered inside.
    /// - Parameters:
    ///   - text: The text to display within the label.
    ///   - backgroundColor: The background color of the view.
    ///   - borderColor: The border color of the view.
    /// - Returns: A UIView containing a UILabel with the specified text and styles.
    class func prettyLabeledView(text: String, backgroundColor: UIColor = .systemBackground, borderColor: UIColor = .black) -> UIView {
        let font = UIFont.preferredFont(forTextStyle: .title2)
        let size = text.size(withAttributes: [.font: font])
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))

        label.attributedText = NSAttributedString(string: text, attributes: [.font: font])
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true

        let containerFrame = CGRect(x: 0, y: 0, width: label.frame.width + 20, height: label.frame.height + 10)
        let containerView = UIView(frame: containerFrame)
        containerView.layer.cornerRadius = 10
        containerView.layer.backgroundColor = backgroundColor.cgColor
        containerView.layer.borderColor = borderColor.cgColor
        containerView.layer.borderWidth = 1
        containerView.addSubview(label)
        label.center = CGPoint(x: containerView.bounds.midX, y: containerView.bounds.midY)

        return containerView
    }

    /// Converts the UIView into a UIImage.
    var image: UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
