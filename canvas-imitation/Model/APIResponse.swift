//
//  APIResponse.swift
//  canvas-imitation
//
//  Created by Luis Amorim on 03/02/25.
//

import Foundation

struct APIResponse: Decodable {
    let photos: [Photo]
    let totalResults: Int?
    let nextPage: String?
    
    enum CodingKeys: String, CodingKey {
        case photos
        case totalResults = "total_results"
        case nextPage = "next_page"
    }
}
