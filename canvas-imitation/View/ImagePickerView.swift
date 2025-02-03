//
//  ImagePickerView.swift
//  canvas-imitation
//
//  Created by Luis Amorim on 03/02/25.
//

import SwiftUI

struct ImagePickerView: View {
    @Environment(\.dismiss) private var dismiss  // To dismiss the sheet
    @State private var photos: [Photo] = []  // List of images
    @State private var isLoading = false  // Loading state
    @State private var categories: [ImageCategory] = [  // List of categories
    ImageCategory(name: "Nature"),
    ImageCategory(name: "Animals"),
    ImageCategory(name: "Technology"),
    ImageCategory(name: "People"),
    ImageCategory(name: "Food")
]
    
    let onImageSelected: (UIImage) -> Void  // Closure to return the selected image
    
    /// Fetch images from API
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
        NavigationView{
            VStack {
                if isLoading {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else {
                    if photos.isEmpty {
                        Text("No images found")
                            .font(.title)
                            .foregroundColor(.gray)
                    } else {
                        GeometryReader { geometry in
                            let columns = 4
                            let itemWidth = (geometry.size.width - CGFloat(columns + 1) * 10) / CGFloat(columns)
                            
                            VStack{
                                ScrollView(.horizontal, showsIndicators: false) {  // Scrollable horizontally
                                    HStack(spacing: 10) {  // Spacing between items
                                        ForEach(categories) { category in
                                            Text(category.name)
                                                .frame(width: itemWidth, height: 20)  // Adjust width based on the screen size
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
                                                    onImageSelected(image)  // Send the selected image back to ContentView
                                                    dismiss()  // Dismiss the sheet after the image is selected
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
            }
            .onAppear {
                loadImages()  // Load images when the view appears
            }
            .navigationTitle("Overlays")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }
}

/// View responsible for loading images from URL and sending the selected image
struct ImageLoaderView: View {
    let url: URL
    let onImageTap: (UIImage) -> Void
    
    @State private var image: UIImage? = nil
    
    var body: some View {
        ZStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .onTapGesture {
                        onImageTap(image)  // Return the image when tapped
                    }
            } else {
                ProgressView()
                    .onAppear {
                        loadImage()  // Start loading the image when the view appears
                    }
            }
        }
    }
    
    /// Loads the image from the URL asynchronously
    private func loadImage() {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
               let loadedImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = loadedImage  // Set the loaded image
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
