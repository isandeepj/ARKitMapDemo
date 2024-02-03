//
//  Double.swift
//  ARMapKitDemo
//
//  Created by Sandeep on 03/02/24.
//

import Foundation

extension Double {
    /// Conversion utilities for geographic calculations.
    func toRadians() -> Double {
        return self * .pi / 180.0
    }

    func toDegrees() -> Double {
        return self * 180.0 / .pi
    }
}
