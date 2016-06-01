//
//  PhotoViewController.swift
//  Blink
//
//  Created by Albert Podusenko on 17.04.16.
//  Copyright © 2016 Albert Podusenko. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyVK

class PhotoViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    @IBOutlet weak var smileButton: UIButton!
    var miniLayer : AVCaptureVideoPreviewLayer?
    @IBOutlet weak var sendedPhoto: UIImageView!
    var postingPhoto : UIImage?
    var fixMe = 0
    var cameraView : UIView!
    var bounds : CGRect!
    @IBOutlet weak var smileSegueActivity: UIActivityIndicatorView!
    var shareCaptureSession = AVCaptureSession()
    var shareCaptureDevice : AVCaptureDevice?
    var shareVideoCaptureOutput = AVCaptureVideoDataOutput()
    
    override func viewDidLoad() {
        dispatch_async(dispatch_get_main_queue(), {
            self.smileButton.setTitle("Wait", forState: UIControlState.Normal)
            self.smileSegueActivity.hidden = true
        })
        sendedPhoto.image = postingPhoto
        cameraView = UIView(frame: CGRectMake(self.view.frame.width / 1.6, self.view.frame.height / 1.25, self.view.frame.size.width / 3, self.view.frame.size.width / 3))
        cameraView!.backgroundColor = UIColor(red: 0.5, green: 0.0, blue: 0.5, alpha: 1.0)
        cameraView!.alpha = 0
        //cameraView!.center = self.view.center;
        self.view.addSubview(cameraView!)
        
        let devices = AVCaptureDevice.devices()
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if(device.position == AVCaptureDevicePosition.Front) {
                    shareCaptureDevice = device as? AVCaptureDevice
                    if shareCaptureDevice != nil {
                        beginCheck()
                    }
                }
            }
        }

    }
    override func viewDidAppear(animated: Bool) {
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func configureDevice() {
        if let device = shareCaptureDevice {
            do {
                try device.lockForConfiguration()
                device.activeVideoMinFrameDuration = CMTimeMake(1, 8)
                device.activeVideoMinFrameDuration = CMTimeMake(1, 8)
            } catch let error as NSError {
                print(error.code)
            }
            device.unlockForConfiguration()
        }
        
    }

    func beginCheck() {
        
        let cameraQueue = dispatch_queue_create("cameraQueue", DISPATCH_QUEUE_SERIAL)
        
        do {
            try shareCaptureSession.addInput(AVCaptureDeviceInput(device: shareCaptureDevice))
        } catch let error as NSError {
            print(error.code)
        }
        
        configureDevice()
        
        miniLayer = AVCaptureVideoPreviewLayer(session: shareCaptureSession)
        
        bounds = cameraView!.layer.frame
        miniLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        miniLayer!.bounds = bounds
        miniLayer!.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))
        
        shareVideoCaptureOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey:Int(kCVPixelFormatType_32BGRA)]
        
        shareVideoCaptureOutput.setSampleBufferDelegate(self, queue: cameraQueue)
        
        shareCaptureSession.addOutput(shareVideoCaptureOutput)
        
        shareCaptureSession.startRunning()
        
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didDropSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection:AVCaptureConnection!) {
        print("dropped")
    }

    func captureOutput(captureOutput: AVCaptureOutput, didOutputSampleBuffer sampleBuffer: CMSampleBufferRef, fromConnection connection: AVCaptureConnection) {
        fixMe += 1
        if fixMe > 2 {
            dispatch_async(dispatch_get_main_queue(), {
                self.view.layer.addSublayer(self.miniLayer!)
                self.smileButton.setTitle("Smile to share", forState: UIControlState.Normal)
            })
        }
        print("frame recieved")
        connection.videoOrientation = AVCaptureVideoOrientation.Portrait
        let pixelBuffer: CVImageBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer)!
        CVPixelBufferLockBaseAddress(pixelBuffer, 0)
        var uiImage = imageFromSampleBuffer(pixelBuffer)
        uiImage = uiImage?.cropsToSquare()
        let faceHaarPath = NSBundle.mainBundle().pathForResource("face", ofType:"xml")
        let smileHaarPath = NSBundle.mainBundle().pathForResource("smile", ofType: "xml")
        if  OpenCVWrapper.processSmileWithOpenCV(uiImage, faceHaarPath, smileHaarPath) {
            print("smile recieved")
            dispatch_async(dispatch_get_main_queue(), {
                self.smileSegueActivity.hidden = false
                self.smileButton.hidden = true
                })
            fixMe = 0
            shareCaptureSession.stopRunning()
            performSegueWithIdentifier("share", sender : nil)
        }
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func imageSaveMethod(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        if error == nil {
            
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
        else {
            let ac = UIAlertController(title: "Save error", message: error?.localizedDescription, preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "share"){
            if let destination = segue.destinationViewController as? ShareViewController {
                destination.uiImage = postingPhoto!
            }
        }
    }
}
