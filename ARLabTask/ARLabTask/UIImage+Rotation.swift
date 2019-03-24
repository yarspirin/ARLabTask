//
//  UIImage+Rotation.swift
//  ARLabTask
//
//  Created by Yaroslav Spirin on 3/23/19.
//  Copyright © 2019 Mountain Viewer. All rights reserved.
//

import UIKit

extension UIImage {
    func rotated(byDegrees degree: Double) -> UIImage? {
        let radians = CGFloat(degree * .pi) / 180.0 as CGFloat
        let rotatedSize = self.size
        let scale = UIScreen.main.scale
        
        UIGraphicsBeginImageContextWithOptions(rotatedSize, false, scale)
        let bitmap = UIGraphicsGetCurrentContext()
        
        bitmap?.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        bitmap?.rotate(by: radians)
        bitmap?.scaleBy(x: 1.0, y: -1.0)
        bitmap?.draw(self.cgImage!,
                     in: CGRect.init(x: -self.size.width / 2,
                                     y: -self.size.height / 2,
                                     width: self.size.width,
                                     height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
