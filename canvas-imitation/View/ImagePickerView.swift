//
//  ImagePickerView.swift
//  canvas-imitation
//
//  Created by Luis Amorim on 03/02/25.
//

import SwiftUI

struct ImagePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var photos: [Photo] = []
    @State private var isLoading = false
    @State private var categories: [ImageCategory] = [
        ImageCategory(name: "Nature"),
        ImageCategory(name: "Animals"),
        ImageCategory(name: "Technology"),
        ImageCategory(name: "People"),
        ImageCategory(name: "Food")
    ]
    
    let onImageSelected: (UIImage) -> Void
    
    func loadImages() {
        isLoading = true
        PexelsAPI.shared.fetchImages { fetchedPhotos in
            DispatchQueue.main.async {
                self.photos = fetchedPhotos ?? []
                self.isLoading = false
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else if photos.isEmpty {
                    Text("No images found")
                        .font(.title)
                        .foregroundColor(.gray)
                } else {
                    GeometryReader { geometry in
                        let columns = 4
                        let itemWidth = (geometry.size.width - CGFloat(columns + 1) * 10) / CGFloat(columns)
                        
                        VStack {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(categories) { category in
                                        Text(category.name)
                                            .frame(width: itemWidth, height: 20)
                                            .padding()
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                    }
                                }
                                .padding([.horizontal, .top])
                            }
                            
                            ScrollView {
                                LazyVGrid(columns: Array(repeating: GridItem(.fixed(itemWidth)), count: columns), spacing: 10) {
                                    ForEach(photos, id: \.id) { photo in
                                        if let url = URL(string: photo.src.large) {
                                            ImageLoaderView(url: url) { image in
                                                onImageSelected(image)
                                                dismiss()
                                            }
                                            .frame(width: itemWidth, height: itemWidth)
                                            .cornerRadius(10)
                                            .clipped()
                                        }
                                    }
                                }
                                .padding(.top)
                            }
                            .scrollIndicators(.hidden)
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .onAppear {
                loadImages()
            }
            .navigationTitle("Overlays")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.black)
                    }
                }
            }
        }
        .padding(.top, 10)
    }
}

#Preview {
    ContentView()
}
