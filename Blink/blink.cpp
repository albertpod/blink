//
//  blink.cpp
//  Blink
//
//  Created by Albert Podusenko on 19.02.16.
//  Copyright © 2016 Albert Podusenko. All rights reserved.
//

#include "blink.h"

cv::CascadeClassifier face_cascade;
cv::CascadeClassifier eyes_cascade;
cv::CascadeClassifier left_eye_cascade;
cv::CascadeClassifier right_eye_cascade;

bool
detectBlobs(cv::Mat gray)
{
    vector<cv::Vec3f> circles;
    
    /// Apply the Hough Transform to find the circles
    HoughCircles(gray, circles, CV_HOUGH_GRADIENT, 2, gray.rows);
    if (circles.size())
        cout << "boo" << endl;
    std::vector<std::vector<cv::Point> > contours;
    findContours(gray.clone(), contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE);
    if (contours.size() == 2)
    {
        cout << "see you" << endl;
    }
    else if (contours.size() > 2)
    {
        cout << "fuck" << endl;
    }
    else if (contours.size() == 1)
    {
        cout << "one eye" << endl;
    }
    return false;
}

void
detectIris(cv::Mat eyes)
{
    
    cv::Mat gray;
    //bitwise_not(eyes, gray);
    cvtColor(~eyes, gray, CV_BGR2GRAY);
    //bitwise_not(gray, gray);
    //dilate(gray, gray, Mat(), Point(-1, -1), 2, 2, 2);
    threshold(gray, gray, 220, 250, cv::THRESH_BINARY);
    
    //morphologyEx(gray, gray, 4,cv::getStructuringElement(cv::MORPH_RECT,cv::Size(2,2)));
    GaussianBlur( gray, gray, cv::Size(9, 9), 2, 2 );
    //threshold(gray, gray, 100, 255, THRESH_OTSU);
    dilate(gray, gray, cv::Mat(), cv::Point(-1, -1), 1, 2, 2);
    dilate(gray, gray, cv::Mat(), cv::Point(-1, -1), 1, 2, 2);
    //Canny( gray, gray, 50, 200, 3 );
    detectBlobs(gray);
    cv::namedWindow( "circles", 1 );
    cvMoveWindow("circles", 600, 40);
    imshow( "circles", gray );
}

/**
 * Function to detect human face and the eyes from an image.
 *
 * @param  im    The source image
 *
 * @return zero = failed, nonzero = success
 */
int
detectEye(cv::Mat &im, std::string faceHaar, std::string eyesHaar)
{
    cv::Mat tpl;
    cv::Rect rect;
    vector<cv::Rect> faces, eyes, right, left;
    eyes_cascade.load(eyesHaar);
    face_cascade.load(faceHaar);
    //handle error
    if (face_cascade.empty() || eyes_cascade.empty())
        return 1;
    face_cascade.detectMultiScale(im, faces, 1.1, 1, 0|CV_HAAR_SCALE_IMAGE, cv::Size(30, 30));
    for (int i = 0; i < faces.size(); i++)
    {
        
        cv::Mat face = im(faces[i]);
        namedWindow( "face", cv::WINDOW_AUTOSIZE );
        imshow( "face", face);
        eyes_cascade.detectMultiScale(face, eyes, 1.1, 1, 0|CV_HAAR_SCALE_IMAGE, cv::Size(20, 20));
        if (eyes.size())
        {
            for (int j = 0; j < eyes.size(); j++)
            {
                cv::Mat one = face(eyes[j]);
                cv::Mat tile;
                tile = one(cv::Range(0, one.rows), cv::Range(10, one.cols - 10)).clone();
                namedWindow( "eyes", cv::WINDOW_AUTOSIZE );
                imshow( "eyes", one);
                detectIris(one);
            }
            
        }
    }
    return (int) eyes.size();
}

