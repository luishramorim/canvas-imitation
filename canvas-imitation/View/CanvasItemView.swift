//
//  CanvasItemView.swift
//  canvas-imitation
//
//  Created by Luis Amorim on 04/02/25.
//

import SwiftUI

struct CanvasItemView: View {
    @ObservedObject var viewModel: CanvasViewModel
    var canvas: Canvas
    var item: CanvasItem
    var screenSize: CGSize
    
    @State private var currentScale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            ImageLoaderView(url: URL(string: item.imageURL)!,
                            onImageTap: { image in
                                viewModel.selectItem(item.id)
                            },
                            isSelected: viewModel.selectedItemId == item.id)
                .frame(width: CGFloat(item.scale) * 100 * currentScale, height: CGFloat(item.scale) * 100 * currentScale)
                .position(item.position)
                .zIndex(Double(item.zIndex))
                .gesture(
                    SimultaneousGesture(
                        DragGesture()
                            .onChanged { value in
                                if viewModel.selectedItemId == item.id {
                                    let newPosition = CGPoint(
                                        x: min(max(value.location.x, 0), screenSize.width),
                                        y: min(max(value.location.y, 100), screenSize.height - 100)
                                    )
                                    
                                    viewModel.moveItem(
                                        canvasId: canvas.id,
                                        itemId: item.id,
                                        newPosition: newPosition,
                                        screenSize: screenSize
                                    )
                                    
                                    viewModel.checkAlignment(
                                        for: newPosition,
                                        canvasId: canvas.id,
                                        itemId: item.id,
                                        screenSize: screenSize
                                    )
                                }
                            }
                            .onEnded { _ in
                                if viewModel.selectedItemId == item.id {
                                    viewModel.snapItem(
                                        canvasId: canvas.id,
                                        itemId: item.id,
                                        screenSize: screenSize
                                    )
                                    viewModel.bringItemToFront(
                                        canvasId: canvas.id,
                                        itemId: item.id
                                    )
                                }
                            },
                        
                        MagnificationGesture()
                            .onChanged { value in
                                if viewModel.selectedItemId == item.id {
                                    let newScale = max(0.5, min(3.0, lastScale * value))
                                    currentScale = newScale

                                    viewModel.updateItemScale(
                                        canvasId: canvas.id,
                                        itemId: item.id,
                                        newScale: newScale
                                    )
                                }
                            }
                            .onEnded { _ in
                                if viewModel.selectedItemId == item.id {
                                    lastScale = currentScale
                                    viewModel.bringItemToFront(
                                        canvasId: canvas.id,
                                        itemId: item.id
                                    )
                                }
                            }
                    )
                )
        }
    }
}
