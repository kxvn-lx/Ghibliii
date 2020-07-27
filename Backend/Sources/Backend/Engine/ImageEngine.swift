//
//  ImageEngine.swift
//  
//
//  Created by Kevin Laminto on 26/7/20.
//

import UIKit

public class ImageEngine {
    private let cachedImages = NSCache<NSURL, UIImage>()
    public typealias ImageEngineSuccess = (UIImage?) -> Swift.Void
    
    public static let shared = ImageEngine()
    private init() { }
    
    /// load an image from the given urlString
    /// Also cache the image for performance
    public func load(withFilmID imageID: String, success: @escaping ImageEngineSuccess) {
        let urlString = FILM_IMAGE[imageID]!
        guard let imageURL = NSURL(string: urlString) else { return }
        
        // Check for cache
        if let imageFromCache = cachedImages.object(forKey: imageURL) {
            DispatchQueue.main.async {
                success(imageFromCache)
            }
            return
        }
        
        // Go fetch the image.
        URLSession.shared.dataTask(with: imageURL as URL) { (data, response, error) in
            guard let imageData = data, error == nil, let imageToCache = UIImage(data: imageData) else {
                print(error!.localizedDescription)
                success(nil)
                return
            }
            
            DispatchQueue.main.async {
                self.cachedImages.setObject(imageToCache, forKey: imageURL, cost: imageData.count)
                success(imageToCache)
            }
        }.resume()
    }
    
}
