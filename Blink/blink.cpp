//
//  blink.cpp
//  Blink
//
//  Created by Albert Podusenko on 19.02.16.
//  Copyright © 2016 Albert Podusenko. All rights reserved.
//

#include "blink.h"
#include <sys/time.h>
#include <time.h>

cv::CascadeClassifier face_cascade;
cv::CascadeClassifier eyes_cascade;
cv::CascadeClassifier one_eye_cascade;

struct timeval
timespec_diff(struct timeval *start, struct timeval *stop)
{
    struct timeval result;
    
    if ((stop->tv_usec - start->tv_usec) < 0)
    {
        result.tv_sec = stop->tv_sec - start->tv_sec - 1;
        result.tv_usec = stop->tv_usec - start->tv_usec + MILLION;
    }
    else
    {
        result.tv_sec = stop->tv_sec - start->tv_sec;
        result.tv_usec = stop->tv_usec - start->tv_usec;
    }
    return result;
}

void clearEyes(eyeStruct *rightEye, eyeStruct *leftEye)
{
    leftEye->blinked = false;
    rightEye->blinked = false;
    leftEye->isClosed = false;
    rightEye->isClosed = false;
    memset(&leftEye->start, '\0', sizeof(leftEye->start));
    memset(&rightEye->start, '\0', sizeof(rightEye->start));
}

void
detectEyeStatus(eyeStruct &detectedEye, vector<cv::Rect> eyeRect, bool isRight)
{
    one_eye_cascade.detectMultiScale(detectedEye.eye, eyeRect, 1.1, 1, 0|CV_HAAR_SCALE_IMAGE, cv::Size(20, 20));
    if (eyeRect.size() == 0)
    {
        detectedEye.isClosed = true;
    }
    else
    {
        detectedEye.isClosed = false;
    }
}

bool
detectBlink(cv::Mat &image, std::string faceHaar, std::string eyesHaar, std::string openHaar)
{
    cv::Mat tpl;
    static eyeStruct rightEye;
    static eyeStruct leftEye;
    cv::Rect rect;
    vector<cv::Rect> faces, eyes, right, left;
    eyes_cascade.load(eyesHaar);
    face_cascade.load(faceHaar);
    one_eye_cascade.load(openHaar);
    
    face_cascade.detectMultiScale(image, faces, 1.1, 1, 0|CV_HAAR_SCALE_IMAGE, cv::Size(30, 30));
    for (int i = 0; i < faces.size(); i++)
    {
        cv::Mat face = image(faces[i]);
        eyes_cascade.detectMultiScale(face, eyes, 1.1, 1, 0|CV_HAAR_SCALE_IMAGE, cv::Size(20, 20));
        for (int j = 0; j < eyes.size(); j++)
        {
            cv::Mat detectedEyes = face(eyes[j]);
            #pragma omp parallel
            {
                rightEye.eye = detectedEyes(cv::Range(0, detectedEyes.rows), cv::Range(0, detectedEyes.cols / 2)).clone();
                detectEyeStatus(rightEye, right, true);
                
                leftEye.eye = detectedEyes(cv::Range(0, detectedEyes.rows), cv::Range(detectedEyes.cols / 2, detectedEyes.cols)).clone();
                detectEyeStatus(leftEye, left, false);
                
            }
            
            if ((leftEye.isClosed != rightEye.isClosed)
                /*&& (rightEye.blinked ^ leftEye.blinked)*/)
            {
                cout << (leftEye.isClosed ? "left" : "right");
                clearEyes(&leftEye, &rightEye);
                return true;
            }
            
        }
        if (eyes.size() == 0)
        {
            clearEyes(&leftEye, &rightEye);
        }
    }
    if (faces.size() == 0)
    {
        clearEyes(&leftEye, &rightEye);
    }
    return false;
}

