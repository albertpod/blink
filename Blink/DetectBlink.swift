//
//  DetectBlink.swift
//  Blink
//
//  Created by Albert Podusenko on 28.03.16.
//  Copyright © 2016 Albert Podusenko. All rights reserved.
//

import Foundation

func detectEyeBlink(capturedImage : UIImage!) -> Bool {
    
    let ciImage = CIImage(CGImage: capturedImage.CGImage!)
    ciImage.imageByCroppingToRect(CGRectMake(0, 0, 320, 320))
    let ciDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
    let options: [String: AnyObject]? = [CIDetectorSmile: true, CIDetectorEyeBlink: true]
    let features = ciDetector.featuresInImage(ciImage, options: options)
    for f in features as! [CIFaceFeature] {
        
        if (f.leftEyeClosed != f.rightEyeClosed) {
            return true
        }
        else {
            return false
        }

    }
    return false
    
}