//
//  File.swift
//  canvas-imitation
//
//  Created by Luis Amorim on 03/02/25.
//

import Foundation

class PexelsAPI {
    static let shared = PexelsAPI()
    if let apiKey = Bundle.main.object(forInfoDictionaryKey: "PEXELS_API_KEY") as? String {
        print(apiKey)
    }
    
    func fetchImages(completion: @escaping ([Photo]?) -> Void) {
        guard let url = URL(string: "https://api.pexels.com/v1/curated?per_page=5") else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Authorization", forHTTPHeaderField: apiKey)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, error == nil {
                do {
                    let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                    completion(apiResponse.photos)
                } catch {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
}
