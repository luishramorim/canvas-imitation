//
//  ImageLoaderView.swift
//  canvas-imitation
//
//  Created by Luis Amorim on 03/02/25.
//

import SwiftUI

struct ImageLoaderView: View {
    let url: URL
    var onImageTap: ((UIImage) -> Void)? = nil
    var isSelected: Bool = false
    
    @State private var image: UIImage? = nil
    @State private var isLoading = false

    var body: some View {
        ZStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .onTapGesture {
                        onImageTap?(image)
                    }
                    .border(isSelected ? Color.blue : Color.clear, width: 5)
                    .cornerRadius(isSelected ? 10 : 0)
                    .padding(3)
            } else if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                Text("Failed to load image")
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        guard !isLoading else { return }
        isLoading = true
        
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: url)
                if let loadedImage = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.image = loadedImage
                        self.isLoading = false
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    print("Failed to load image from URL: \(error)")
                }
            }
        }
    }
}

#Preview {
    ImageLoaderView(url: URL(string: "https://picsum.photos/300")!, onImageTap: {_ in print("Pressed")}, isSelected: true)
    .frame(width: 300, height: 300)
}
