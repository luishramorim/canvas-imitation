//
//  FloatingActionButton.swift
//  canvas-imitation
//
//  Created by Luis Amorim on 03/02/25.
//

import SwiftUI

struct FloatingActionButton: View {
    var icon: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.white)
                .padding()
                .background(Circle().fill(Color.black).shadow(radius: 5))
        }
        .padding()
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()
        
        FloatingActionButton(icon: "slider.horizontal.3") {
            print("FAB pressed!")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
    }
}
