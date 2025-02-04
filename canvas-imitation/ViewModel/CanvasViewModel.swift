//
//  CanvasViewModel.swift
//  canvas-imitation
//
//  Created by Luis Amorim on 03/02/25.
//

import SwiftUI

class CanvasViewModel: ObservableObject {
    @Published var canvases: [Canvas] = []
    @Published var selectedItemId: UUID?
    @Published var showVerticalLine = false
    @Published var showHorizontalLine = false
    @Published var verticalLinePosition: CGFloat? = nil
    @Published var horizontalLinePosition: CGFloat? = nil
    @Published var snapLines: [(CGPoint, CGPoint)] = []

    private let snapThreshold: CGFloat = 20

    func addCanvas() {
        canvases.append(Canvas())
        objectWillChange.send()
    }
    
    func selectItem(_ itemId: UUID?) {
        selectedItemId = itemId
    }

    func clearSelection() {
        selectedItemId = nil
    }
    
    func addItemToCanvas(canvasId: UUID, imageURL: String, position: CGPoint) {
        guard let index = canvases.firstIndex(where: { $0.id == canvasId }) else { return }
        let maxZIndex = canvases[index].items.map { $0.zIndex }.max() ?? 0
        canvases[index].items.append(CanvasItem(imageURL: imageURL, position: position, zIndex: maxZIndex + 1))
        objectWillChange.send()
    }
    
    func addImageToCanvas(canvasId: UUID, image: UIImage, screenSize: CGSize) {
        addItemToCanvas(
            canvasId: canvasId,
            imageURL: saveImage(image),
            position: CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        )
    }
    
    func moveItem(canvasId: UUID, itemId: UUID, newPosition: CGPoint, screenSize: CGSize) {
        guard let (canvasIndex, itemIndex) = findItemIndex(canvasId: canvasId, itemId: itemId) else { return }
        canvases[canvasIndex].items[itemIndex].position = newPosition
        checkAlignment(for: newPosition, canvasId: canvasId, itemId: itemId, screenSize: screenSize)
    }
    
    func snapItem(canvasId: UUID, itemId: UUID, screenSize: CGSize) {
        guard let (canvasIndex, itemIndex) = findItemIndex(canvasId: canvasId, itemId: itemId) else { return }

        var position = canvases[canvasIndex].items[itemIndex].position
        var snapped = false

        for item in canvases[canvasIndex].items where item.id != itemId {
            if abs(position.x - item.position.x) < snapThreshold {
                position.x = item.position.x
                snapped = true
            }
            if abs(position.y - item.position.y) < snapThreshold {
                position.y = item.position.y
                snapped = true
            }
        }

        if !snapped {
            snapped = snapToScreenCenter(&position, screenSize: screenSize)
        }

        if snapped {
            canvases[canvasIndex].items[itemIndex].position = position
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }

        hideAlignmentLines()
    }
    
    func updateItemScale(canvasId: UUID, itemId: UUID, newScale: CGFloat) {
        updateCanvasItem(canvasId: canvasId, itemId: itemId) { $0.scale = newScale }
    }
    
    func updateItemRotation(canvasId: UUID, itemId: UUID, newRotation: Angle) {
        updateCanvasItem(canvasId: canvasId, itemId: itemId) { $0.rotation = newRotation }
    }
    
    func bringItemToFront(canvasId: UUID, itemId: UUID) {
        guard let (canvasIndex, itemIndex) = findItemIndex(canvasId: canvasId, itemId: itemId) else { return }
        let maxZIndex = (canvases[canvasIndex].items.map { $0.zIndex }.max() ?? 0) + 1
        canvases[canvasIndex].items[itemIndex].zIndex = maxZIndex
        objectWillChange.send()
    }
    
    func checkAlignment(for position: CGPoint, canvasId: UUID, itemId: UUID, screenSize: CGSize) {
        guard let canvasIndex = canvases.firstIndex(where: { $0.id == canvasId }) else { return }

        var showVertical = false, showHorizontal = false
        var verticalPos: CGFloat? = nil, horizontalPos: CGFloat? = nil

        for item in canvases[canvasIndex].items where item.id != itemId {
            if abs(position.x - item.position.x) < snapThreshold {
                showVertical = true
                verticalPos = item.position.x
            }
            if abs(position.y - item.position.y) < snapThreshold {
                showHorizontal = true
                horizontalPos = item.position.y
            }
        }

        if !showVertical, abs(position.x - (screenSize.width / 2)) < snapThreshold {
            showVertical = true
            verticalPos = screenSize.width / 2
        }
        if !showHorizontal, abs(position.y - (screenSize.height / 2)) < snapThreshold {
            showHorizontal = true
            horizontalPos = screenSize.height / 2
        }

        showVerticalLine = showVertical
        showHorizontalLine = showHorizontal
        verticalLinePosition = verticalPos
        horizontalLinePosition = horizontalPos

        objectWillChange.send()
    }

    private func snapToScreenCenter(_ position: inout CGPoint, screenSize: CGSize) -> Bool {
        let centerX = screenSize.width / 2
        let centerY = screenSize.height / 2
        var snapped = false

        if abs(position.x - centerX) < snapThreshold {
            position.x = centerX
            snapped = true
        }
        if abs(position.y - centerY) < snapThreshold {
            position.y = centerY
            snapped = true
        }

        return snapped
    }

    private func hideAlignmentLines() {
        showVerticalLine = false
        showHorizontalLine = false
        verticalLinePosition = nil
        horizontalLinePosition = nil
        objectWillChange.send()
    }
    
    private func findItemIndex(canvasId: UUID, itemId: UUID) -> (Int, Int)? {
        guard let canvasIndex = canvases.firstIndex(where: { $0.id == canvasId }),
              let itemIndex = canvases[canvasIndex].items.firstIndex(where: { $0.id == itemId })
        else { return nil }
        return (canvasIndex, itemIndex)
    }

    private func updateCanvasItem(canvasId: UUID, itemId: UUID, update: (inout CanvasItem) -> Void) {
        guard let (canvasIndex, itemIndex) = findItemIndex(canvasId: canvasId, itemId: itemId) else { return }
        update(&canvases[canvasIndex].items[itemIndex])
        objectWillChange.send()
    }
    
    private func snapToItemEdges(_ position: inout CGPoint, canvasId: UUID, itemId: UUID, screenSize: CGSize) -> Bool {
        guard let canvasIndex = canvases.firstIndex(where: { $0.id == canvasId }) else { return false }
        guard let currentItem = canvases[canvasIndex].items.first(where: { $0.id == itemId }) else { return false }
        
        var snapped = false
        snapLines.removeAll()

        let itemHalfSize = 50 * currentItem.scale
        let currentBounds = CGRect(
            x: position.x - itemHalfSize,
            y: position.y - itemHalfSize,
            width: itemHalfSize * 2,
            height: itemHalfSize * 2
        )

        for item in canvases[canvasIndex].items where item.id != itemId {
            let otherHalfSize = 50 * item.scale
            let otherBounds = CGRect(
                x: item.position.x - otherHalfSize,
                y: item.position.y - otherHalfSize,
                width: otherHalfSize * 2,
                height: otherHalfSize * 2
            )

            if abs(currentBounds.minX - otherBounds.maxX) < snapThreshold {
                position.x = otherBounds.maxX + itemHalfSize
                snapLines.append((CGPoint(x: otherBounds.maxX, y: 0), CGPoint(x: otherBounds.maxX, y: screenSize.height)))
                snapped = true
            } else if abs(currentBounds.maxX - otherBounds.minX) < snapThreshold {
                position.x = otherBounds.minX - itemHalfSize
                snapLines.append((CGPoint(x: otherBounds.minX, y: 0), CGPoint(x: otherBounds.minX, y: screenSize.height)))
                snapped = true
            }

            if abs(currentBounds.minY - otherBounds.maxY) < snapThreshold {
                position.y = otherBounds.maxY + itemHalfSize
                snapLines.append((CGPoint(x: 0, y: otherBounds.maxY), CGPoint(x: screenSize.width, y: otherBounds.maxY)))
                snapped = true
            } else if abs(currentBounds.maxY - otherBounds.minY) < snapThreshold {
                position.y = otherBounds.minY - itemHalfSize
                snapLines.append((CGPoint(x: 0, y: otherBounds.minY), CGPoint(x: screenSize.width, y: otherBounds.minY)))
                snapped = true
            }
        }

        return snapped
    }
    
    private func saveImage(_ image: UIImage) -> String {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return "" }
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".jpg")
        do {
            try imageData.write(to: fileURL)
            return fileURL.absoluteString
        } catch {
            print("Error saving image: \(error)")
            return ""
        }
    }
}
