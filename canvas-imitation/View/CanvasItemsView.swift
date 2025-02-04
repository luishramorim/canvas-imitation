//
//  CanvasItemsView.swift
//  canvas-imitation
//
//  Created by Luis Amorim on 04/02/25.
//

import SwiftUI

struct CanvasItemsView: View {
    @ObservedObject var viewModel: CanvasViewModel
    var canvas: Canvas
    var screenSize: CGSize

    var body: some View {
        ForEach(canvas.items) { item in
            CanvasItemView(
                viewModel: viewModel,
                canvas: canvas,
                item: item,
                screenSize: screenSize
            )
        }
    }
}
