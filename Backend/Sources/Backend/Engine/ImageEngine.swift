//
//  ImageEngine.swift
//  
//
//  Created by Kevin Laminto on 26/7/20.
//

import UIKit

public struct ImageEngine {
    private static let imageServiceCache = NSCache<NSString, UIImage>()
    public typealias ImageEngineSuccess = (UIImage) -> Void
    
    public static let shared = ImageEngine()
    private init() { }
    
    /// load an image from the given urlString
    /// Also cache the image for performance
    public func load(withFilmID imageID: String, success: ImageEngineSuccess?) {
        let urlString = FILM_IMAGE[imageID]!
        
        if let imageFromCache = ImageEngine.imageServiceCache.object(forKey: urlString as NSString) {
            success?(imageFromCache)
            return
        }
        
        guard let imageURL = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: imageURL) { (data, _, error) in
            guard let imageData = data else { return }
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let imageToCache = UIImage(data: imageData) {
                DispatchQueue.main.async {
                    ImageEngine.imageServiceCache.setObject(imageToCache, forKey: urlString as NSString)
                    success?(imageToCache)
                }
            }
        }.resume()
    }
    
}
