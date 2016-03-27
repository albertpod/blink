//
//  UIImageExtension.swift
//  Blink
//
//  Created by Albert Podusenko on 22.03.16.
//  Copyright © 2016 Albert Podusenko. All rights reserved.
//

import Foundation

extension UIImage {
    public func imageRotatedByDegrees(degrees: CGFloat, flip: Bool) -> UIImage {
        
        let degreesToRadians: (CGFloat) -> CGFloat = {
            return $0 / 180.0 * CGFloat(M_PI)
        }
        
        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPointZero, size: size))
        let t = CGAffineTransformMakeRotation(degreesToRadians(degrees));
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        CGContextTranslateCTM(bitmap, rotatedSize.width / 2.0, rotatedSize.height / 2.0);
        
        //   // Rotate the image context
        CGContextRotateCTM(bitmap, degreesToRadians(degrees));
        
        // Now, draw the rotated/scaled image into the context
        var yFlip: CGFloat
        
        if(flip){
            yFlip = CGFloat(-1.0)
        } else {
            yFlip = CGFloat(1.0)
        }
        
        CGContextScaleCTM(bitmap, yFlip, -1.0)
        CGContextDrawImage(bitmap, CGRectMake(-size.width / 2, -size.height / 2, size.width, size.height), CGImage)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

/*
http://stackoverflow.com/questions/14383932/convert-cmsamplebufferref-to-uiimage
*/
func imageFromSampleBuffer(pixelBuffer: CVImageBuffer) -> UIImage? {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    CVPixelBufferLockBaseAddress(pixelBuffer, 0)
    let address = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0)
    let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
    let width = CVPixelBufferGetWidth(pixelBuffer)
    let height = CVPixelBufferGetHeight(pixelBuffer)
    
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue | CGBitmapInfo.ByteOrder32Little.rawValue)
    
    let context = CGBitmapContextCreate(address, width, height, 8,bytesPerRow, colorSpace, bitmapInfo.rawValue);
    let imageRef = CGBitmapContextCreateImage(context)
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0)
    var resultImage : UIImage?
    if context != nil {
        resultImage = UIImage(CGImage: imageRef!)
    }
    
    return resultImage
}