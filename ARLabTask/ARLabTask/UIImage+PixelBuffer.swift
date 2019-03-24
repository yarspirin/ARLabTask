//
//  UIImage+PixelBuffer.swift
//  ARLabTask
//
//  Created by Yaroslav Spirin on 3/23/19.
//  Copyright © 2019 Mountain Viewer. All rights reserved.
//

import UIKit
import VideoToolbox

extension UIImage {
    public convenience init?(pixelBuffer: CVPixelBuffer) {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
        
        if let cgImage = cgImage {
            self.init(cgImage: cgImage)
        } else {
            return nil
        }
    }
}
