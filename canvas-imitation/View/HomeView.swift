//
//  HomeView.swift
//  canvas-imitation
//
//  Created by Luis Amorim on 03/02/25.
//

import SwiftUI

struct HomeView: View {
    @State private var isMenuPresented = false
    @StateObject private var viewModel = CanvasViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(viewModel.canvases) { canvas in
                        NavigationLink(destination: CanvasView(viewModel: viewModel, canvas: canvas)) {
                            Text("Canvas \(canvas.id.uuidString.prefix(8))")
                        }
                    }
                }
                .overlay {
                    if viewModel.canvases.isEmpty {
                        VStack{
                            Image(systemName: "rectangle.portrait.slash")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                            
                            Text("No canvases yet")
                                .fontWeight(.bold)
                                .font(.title)
                            
                            Text("To get started, create a new one.")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FloatingActionButton(icon: "plus") {
                            viewModel.addCanvas()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Canvas Imitation")
        }
        .sheet(isPresented: $isMenuPresented) {
            MenuPicker()
                .presentationDetents([.fraction(0.15)])
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    HomeView()
}
