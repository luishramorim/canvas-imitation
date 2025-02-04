//
//  SnapGuidesView.swift
//  canvas-imitation
//
//  Created by Luis Amorim on 04/02/25.
//

import SwiftUI

struct SnapGuidesView: View {
    let snapLines: [(CGPoint, CGPoint)]
    let screenSize: CGSize

    var body: some View {
        ZStack {
            ForEach(0..<snapLines.count, id: \.self) { index in
                let (start, end) = snapLines[index]

                Path { path in
                    path.move(to: start)
                    path.addLine(to: end)
                }
                .stroke(
                    Color.blue.opacity(0.8),
                    style: StrokeStyle(lineWidth: 2, dash: [5, 3])
                )
            }
        }
        .frame(width: screenSize.width, height: screenSize.height)
    }
}
