//
//  blink.hpp
//  Blink
//
//  Created by Albert Podusenko on 19.02.16.
//  Copyright © 2016 Albert Podusenko. All rights reserved.
//

#ifndef blink_hpp
#define blink_hpp

#include <stdio.h>
#include <iostream>
#include <opencv2/features2d.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/objdetect/objdetect.hpp>

using namespace std;


bool detectBlobs(cv::Mat gray);
int detectEye(cv::Mat &im, std::string faceHaar, std::string eyesHaar);
void detectIris(cv::Mat eyes);

#endif /* blink_hpp */
