
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

@implementation OpenCVWrapper : NSObject

+ (NSString*)processBlinkWithOpenCV:(UIImage *)inputImage :(NSString *)faceHaar :(NSString *)eyesHaar :(NSString*)openedEyeHaar {
    cv::Mat mat = [inputImage CVMat];
    std::string *facehaar = new std::string([faceHaar UTF8String]);
    std::string *eyeshaar = new std::string([eyesHaar UTF8String]);
    std::string *openhaar = new std::string([openedEyeHaar UTF8String]);
    return [NSString stringWithUTF8String:detectBlink(mat, *facehaar, *eyeshaar, *openhaar).c_str()];;
}

+ (bool)processSmileWithOpenCV:(UIImage*)inputImage :(NSString*)faceHaar :(NSString*)smileHaar {
    cv::Mat mat = [inputImage CVMat];
    std::string *facehaar = new std::string([faceHaar UTF8String]);
    std::string *smilehaar = new std::string([smileHaar UTF8String]);
    return detectSmile(mat, *facehaar, *smilehaar);
}

@end
