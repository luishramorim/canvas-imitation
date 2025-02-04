//
//  CanvasItem.swift
//  canvas-imitation
//
//  Created by Luis Amorim on 03/02/25.
//

import Foundation
import SwiftUI

struct CanvasItem: Identifiable {
    var id = UUID()
    var imageURL: String
    var position: CGPoint = .zero
    var scale: CGFloat = 1.0
    var zIndex: Int = 0
    var rotation: Angle = .zero 
}
