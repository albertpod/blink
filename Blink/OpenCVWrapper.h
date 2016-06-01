//
//  OpenCVWrapper.h
//  Blink
//
//  Created by Albert Podusenko on 19.02.16.
//  Copyright © 2016 Albert Podusenko. All rights reserved.
//

#ifndef OpenCVWrapper_h
#define OpenCVWrapper_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface OpenCVWrapper : NSObject

+ (NSString*)processBlinkWithOpenCV:(UIImage*)inputImage :(NSString*)faceHaar :(NSString*)eyesHaar :(NSString*)openedEyeHaar;

+ (bool)processSmileWithOpenCV:(UIImage*)inputImage :(NSString*)faceHaar :(NSString*)smileHaar;

@end

#endif /* OpenCVWrapper_h */
