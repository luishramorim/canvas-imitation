//
//  CentralLinesView.swift
//  canvas-imitation
//
//  Created by Luis Amorim on 04/02/25.
//

import SwiftUI

struct CentralLinesView: View {
    let showVertical: Bool
    let showHorizontal: Bool
    let verticalPosition: CGFloat?
    let horizontalPosition: CGFloat?
    let screenSize: CGSize
    private let centerThreshold: CGFloat = 20

    var body: some View {
        ZStack {
            if showVertical, let verticalPos = verticalPosition {
                Rectangle()
                    .fill(lineColor(for: verticalPos, centerValue: screenSize.width / 2))
                    .frame(width: 3, height: screenSize.height)
                    .position(x: verticalPos, y: screenSize.height / 2)
            }

            if showHorizontal, let horizontalPos = horizontalPosition {
                Rectangle()
                    .fill(lineColor(for: horizontalPos, centerValue: screenSize.height / 2))
                    .frame(width: screenSize.width, height: 3)
                    .position(x: screenSize.width / 2, y: horizontalPos)
            }
        }
    }

    private func lineColor(for position: CGFloat, centerValue: CGFloat) -> Color {
        return abs(position - centerValue) < centerThreshold ? Color.red.opacity(0.5) : Color.yellow.opacity(0.5)
    }
}
