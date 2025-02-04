//
//  CanvasView.swift
//  canvas-imitation
//
//  Created by Luis Amorim on 03/02/25.
//

import SwiftUI

struct CanvasView: View {
    @ObservedObject var viewModel: CanvasViewModel
    var canvas: Canvas
    @State private var isImagePickerPresented = false
    @State private var screenSize: CGSize = .zero
    @State private var hasScrolledToCenter = false

    let scrollAreaMultiplier: CGFloat = 2.0

    var body: some View {
        GeometryReader { geometry in
            let scrollHeight = geometry.size.height * scrollAreaMultiplier

            ScrollView(.vertical, showsIndicators: true) {
                ScrollViewReader { proxy in
                    ZStack {
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.clearSelection()
                            }
                        
                        CanvasItemsView(viewModel: viewModel, canvas: canvas, screenSize: CGSize(width: geometry.size.width, height: scrollHeight))

                        CentralLinesView(
                            showVertical: viewModel.showVerticalLine,
                            showHorizontal: viewModel.showHorizontalLine,
                            verticalPosition: viewModel.verticalLinePosition,
                            horizontalPosition: viewModel.horizontalLinePosition,
                            screenSize: CGSize(width: geometry.size.width, height: scrollHeight)
                        )
                        .zIndex(10000)
                    }
                    .frame(height: scrollHeight)
                    .background(GeometryReader { innerGeometry in
                        Color.clear
                            .onAppear {
                                if !hasScrolledToCenter {
                                    let centerY = scrollHeight / 2 - geometry.size.height / 2

                                    DispatchQueue.main.async {
                                        withAnimation {
                                            proxy.scrollTo(centerY, anchor: .center)
                                        }
                                        hasScrolledToCenter = true
                                    }
                                }
                            }
                    })
                }
            }
            .onAppear {
                screenSize = CGSize(width: geometry.size.width, height: geometry.size.height)
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePickerView(onImageSelected: { image in
                    viewModel.addImageToCanvas(
                        canvasId: canvas.id,
                        image: image,
                        screenSize: screenSize
                    )
                })
                .presentationDetents([.medium, .large])
            }
        }
        .navigationTitle("Canvas")
        .overlay(
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingActionButton(icon: "photo.badge.plus") {
                        isImagePickerPresented.toggle()
                    }
                }
                .padding()
            }
            .zIndex(10001)
        )
    }
}
