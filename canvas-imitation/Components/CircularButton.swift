//
//  CircularButton.swift
//  canvas-imitation
//
//  Created by Luis Amorim on 03/02/25.
//

import SwiftUI

struct CircularButton: View {
    var iconName: String
    var title: String
    var action: () -> Void
    
    var body: some View {
        VStack {
            Button(action: {
                action()
            }) {
                VStack {
                    Image(systemName: iconName)
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 60, height: 60)
                        .background(Color.black)
                        .clipShape(Circle())
                    
                    Text(title)
                        .padding(.top, 2)
                        .fontWeight(.bold)
                        .foregroundStyle(.gray)
                }
            }
        }
    }
}

#Preview {
    CircularButton(iconName: "star.fill", title: "Favorite") {
        print("Favorite!")
    }
}
