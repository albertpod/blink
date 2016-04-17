
//
//  OpenCVWrapper.mm
//  Blink
//
//  Created by Albert Podusenko on 19.02.16.
//  Copyright © 2016 Albert Podusenko. All rights reserved.
//

#include "OpenCVWrapper.h"
#include "UIImage+OpenCV.h"
#include "blink.h"

#include <opencv2/opencv.hpp>

/* http://stackoverflow.com/questions/30908593/using-opencv-in-swift-ios */

@implementation OpenCVWrapper : NSObject

+ (bool)processImageWithOpenCV:(UIImage *)inputImage :(NSString *)faceHaar :(NSString *)eyesHaar :(NSString*)openedEyeHaar {
    cv::Mat mat = [inputImage CVMat];
    std::string *facehaar = new std::string([faceHaar UTF8String]);
    std::string *eyeshaar = new std::string([eyesHaar UTF8String]);
    std::string *openhaar = new std::string([openedEyeHaar UTF8String]);
    //detectEye(mat, *facehaar, *eyeshaar);
    
    return detectBlink(mat, *facehaar, *eyeshaar, *openhaar);
}

-(bool)detectBlink:(cv::Mat&)im :(std::string)facehaar :(std::string)eyeshaar :(std::string)openhaar
{
    return detectBlink(im, facehaar, eyeshaar, openhaar);
}

@end
