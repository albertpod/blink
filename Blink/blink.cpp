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
cv::CascadeClassifier smile_cascade;

void clearEyes(eyeStruct *rightEye, eyeStruct *leftEye)
{
    leftEye->blinked = false;
    rightEye->blinked = false;
    leftEye->isClosed = false;
    rightEye->isClosed = false;
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
    if (faces.size() == 1)
    {
        faces[0] = cv::Rect(faces[0].x, faces[0].y, faces[0].width, faces[0].height / 2);
        cv::Mat face = image(faces[0]);
        eyes_cascade.detectMultiScale(face, eyes, 1.1, 1, 0|CV_HAAR_SCALE_IMAGE, cv::Size(20, 20));
        if (eyes.size() == 1)
        {
            cv::Mat detectedEyes = face(eyes[0]);
            rightEye.eye = detectedEyes(cv::Range(0, detectedEyes.rows), cv::Range(0, detectedEyes.cols / 2)).clone();
            detectEyeStatus(rightEye, right, true);
                
            leftEye.eye = detectedEyes(cv::Range(0, detectedEyes.rows), cv::Range(detectedEyes.cols / 2, detectedEyes.cols)).clone();
            detectEyeStatus(leftEye, left, false);
            
            if (leftEye.isClosed != rightEye.isClosed)
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

bool
detectSmile(cv::Mat &image, std::string faceHaar, std::string smileHaar)
{
    cv::Mat tpl;
    cv::Rect rect;
    vector<cv::Rect> faces, smile;
    face_cascade.load(faceHaar);
    smile_cascade.load(smileHaar);
    face_cascade.detectMultiScale(image, faces, 1.1, 1, 0|CV_HAAR_SCALE_IMAGE, cv::Size(30, 30));
    if (faces.size() == 1)
    {
        faces[0] = cv::Rect(faces[0].x, faces[0].y + faces[0].height / 2, faces[0].width, faces[0].height / 2);
        cv::Mat face = image(faces[0]);
        smile_cascade.detectMultiScale(face, smile, 1.1, 1, 0|CV_HAAR_SCALE_IMAGE, cv::Size(20, 20));
        if (smile.size() != 0)
        {
            return true;
        }
        
    }
    return false;
}

