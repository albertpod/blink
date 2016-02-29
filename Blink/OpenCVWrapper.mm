
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

+ (UIImage *)processImageWithOpenCV:(UIImage *)inputImage :(NSString *)faceHaar :(NSString *)eyesHaar {
    cv::Mat mat = [inputImage CVMat];
    std::string *facehaar = new std::string([faceHaar UTF8String]);
    std::string *eyeshaar = new std::string([eyesHaar UTF8String]);
    detectEye(mat, *facehaar, *eyeshaar);
    return [UIImage imageWithCVMat:mat];
}

- (bool)detectBlobs:(cv::Mat)gray
{
    return detectBlobs(gray);
}

- (void)detectIris:(cv::Mat)eyes
{
    return detectIris(eyes);
}

- (int)detectEye:(cv::Mat&)im :(std::string)facehaar :(std::string)eyeshaar
{
    return detectEye(im, facehaar, eyeshaar);
}

@end
