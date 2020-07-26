//
//  ImageEngine.swift
//  
//
//  Created by Kevin Laminto on 26/7/20.
//

import UIKit

public struct ImageEngine {
    private static let imageServiceCache = NSCache<NSString, UIImage>()
    
    public static let shared = ImageEngine()
    private init() { }
    
    /// load an image from the given urlString
    /// Also cache the image for performance
    public func load(withFilmID imageID: String, to imageView: UIImageView) {
        let urlString = FILM_IMAGE[imageID]!
        
        if let imageFromCache = ImageEngine.imageServiceCache.object(forKey: urlString as NSString) {
            setImage(imageView, imageFromCache)
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
                    setImage(imageView, imageToCache)
                }
            }
        }.resume()
    }
    
    private func setImage(_ imageView: UIImageView, _ imageFromCache: UIImage) {
        imageView.backgroundColor = .clear
        imageView.image = imageFromCache.resizeImageWith(newSize: imageView.frame.size)
    }
    
}
