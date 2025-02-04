//
//  PexelsAPI.swift
//  canvas-imitation
//
//  Created by Luis Amorim on 03/02/25.
//

import Foundation

/// A singleton class to handle API requests to Pexels.
class PexelsAPI {
    // Singleton instance of the API class
    static let shared = PexelsAPI()
    
    private var apiKey: String?  // Stores the API key to authenticate requests
    
    // Private initializer to set up the API key from a local property list
    private init() {
        // Attempt to load the API key from Secrets.plist
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
           let xml = FileManager.default.contents(atPath: path),
           let secrets = try? PropertyListDecoder().decode([String: String].self, from: xml),
           let key = secrets["PEXELS_API_KEY"] {
            // If the key is found, store it
            self.apiKey = key
        } else {
            // If no key is found, set apiKey to nil and log an error
            self.apiKey = nil
            print("API Key not found in Secrets.plist")
        }
        
        // Print the API Key for debugging, only if it's available
        if let apiKey = self.apiKey {
            print("API Key found: \(apiKey)")
        }
    }
    
    /// Fetches images from the Pexels API.
    /// - Parameter completion: A closure that is called with an array of photos, or nil in case of failure.
    func fetchImages(completion: @escaping ([Photo]?) -> Void) {
        // Ensure that the API key is available before making the request
        guard let apiKey = self.apiKey else {
            print("API Key is missing!")  // Log an error if the API key is not found
            completion(nil)  // Return nil if API key is missing
            return
        }
        
        // Create the URL for the Pexels API endpoint
        guard let url = URL(string: "https://api.pexels.com/v1/curated?per_page=50&page=1") else {
            completion(nil)  // Return nil if URL creation fails
            return
        }
        
        // Create the URLRequest to include the API key in the request header
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        
        // Start the data task to fetch the data from the Pexels API
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, error == nil {
                do {
                    // Attempt to decode the response data into a model object
                    let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                    completion(apiResponse.photos)  // Return the list of photos
                } catch {
                    // If decoding fails, log the error and return nil
                    print("Error decoding API response: \(error)")
                    completion(nil)
                }
            } else {
                // If an error occurred during the data fetching, log the error message
                if let error = error {
                    print("Error fetching data: \(error.localizedDescription)")
                } else {
                    print("Error: Unknown error")
                }
                completion(nil)  // Return nil in case of an error
            }
        }
        task.resume()  // Start the task asynchronously
    }
}
