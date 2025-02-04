//
//  PhotoSource.swift
//  canvas-imitation
//
//  Created by Luis Amorim on 03/02/25.
//

import Foundation

struct PhotoSource: Decodable {
    let original: String
    let large2x: String
    let large: String
    let medium: String
    let small: String
    let portrait: String
    let landscape: String
    let tiny: String
}
