//
//  Canvas.swift
//  canvas-imitation
//
//  Created by Luis Amorim on 03/02/25.
//

import SwiftUI

class Canvas: Identifiable {
    var id = UUID()
    var items: [CanvasItem] = []

    func addItem(imageURL: String, screenSize: CGSize) {
        let centerPosition = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        let newItem = CanvasItem(imageURL: imageURL, position: centerPosition, scale: 1.0, zIndex: items.count)
        items.append(newItem)
    }

    func moveItem(id: UUID, newPosition: CGPoint) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].position = newPosition
        }
    }

    func updateItemScale(id: UUID, newScale: CGFloat) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].scale = newScale
        }
    }

    func updateItemZIndex(id: UUID, newZIndex: Int) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].zIndex = newZIndex
        }
    }

    func checkSnap(for item: CanvasItem) -> Bool {
        return false
    }
}
