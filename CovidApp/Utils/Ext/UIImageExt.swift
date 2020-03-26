//
//  UIImageExt.swift
//  FindABox
//
//  Created by jerome on 16/09/2019.
//  Copyright © 2019 Jerome TONNELIER. All rights reserved.
//

import UIKit
extension UIImage {
    
    /// Returns a image that fills in newSize
    func resizedImage(newSize: CGSize) -> UIImage? {
        // Guard newSize is different
        guard size != newSize else { return self }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
