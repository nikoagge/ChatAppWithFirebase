//
//  UIImageViewCacheExtension.swift
//  ChatAppWithFirebase
//
//  Created by Nikolas on 22/05/2019.
//  Copyright © 2019 Nikolas Aggelidis. All rights reserved.
//


import Foundation
import UIKit


let imageCache = NSCache<AnyObject, AnyObject>()


extension UIImageView {
    
    
    func loadImageUsingCache(withURLString urlString: String) {
        
        //Check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            
            self.image = cachedImage
            
            return
        }
        
        //Otherwise download image from Firebase Storage
        let url = URL(string: urlString)
        
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            if error != nil {
                
                print(error)
                
                return
            }
            
            DispatchQueue.main.async {
                
                guard let downloadedImage = UIImage(data: data!) else { return }
                
                imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                
                self.image = downloadedImage
            }
        }.resume()
    }
}
