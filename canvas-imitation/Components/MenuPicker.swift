//
//  MenuPicker.swift
//  canvas-imitation
//
//  Created by Luis Amorim on 03/02/25.
//

import SwiftUI

struct MenuPicker: View {
    @State private var isImagePickerPresented = false
    @State private var showAlert = false

    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack(spacing: 20) {
                    CircularButton(iconName: "photo", title: "Image") {
                        isImagePickerPresented.toggle()
                    }
                    .frame(width: (geometry.size.width - 60) / 4)
                    
                    CircularButton(iconName: "play.circle.fill", title: "Video") {
                        showAlert.toggle()
                    }
                    .frame(width: (geometry.size.width - 60) / 4)
                    
                    CircularButton(iconName: "theatermasks", title: "GIF") {
                        showAlert.toggle()
                    }
                    .frame(width: (geometry.size.width - 60) / 4)
                    
                    CircularButton(iconName: "scribble", title: "Draw") {
                        showAlert.toggle()
                    }
                    .frame(width: (geometry.size.width - 60) / 4)
                }
            }
        }
        .padding()
        .padding(.top, 20)
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePickerView(onImageSelected: { _ in })
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Coming soon"))
        }
    }
}

#Preview {
    MenuPicker()
}
