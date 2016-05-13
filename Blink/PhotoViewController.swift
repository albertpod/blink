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
    @IBOutlet weak var sendedPhoto: UIImageView!
    
    var postingPhoto : UIImage?
    var shareCaptureSession = AVCaptureSession()
    var shareCaptureDevice : AVCaptureDevice?
    var shareVideoCaptureOutput = AVCaptureVideoDataOutput()
    
    override func viewDidLoad() {
        sendedPhoto.image = postingPhoto
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
                
            } catch let error as NSError {
                print(error.code)
            }
            device.unlockForConfiguration()
        }
        
    }

    func beginCheck() {
        
        configureDevice()
        do {
            try shareCaptureSession.addInput(AVCaptureDeviceInput(device: shareCaptureDevice))
        } catch let error as NSError {
            print(error.code)
        }
        
        let cameraQueue = dispatch_queue_create("cameraQueue", DISPATCH_QUEUE_SERIAL)
        
        shareVideoCaptureOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey:Int(kCVPixelFormatType_32BGRA)]
        
        shareVideoCaptureOutput.setSampleBufferDelegate(self, queue: cameraQueue)
        
        shareCaptureSession.addOutput(shareVideoCaptureOutput)
        
        shareCaptureSession.startRunning()
    }

    func captureOutput(captureOutput: AVCaptureOutput, didOutputSampleBuffer sampleBuffer: CMSampleBufferRef, fromConnection connection: AVCaptureConnection) {
        let pixelBuffer: CVImageBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer)!
        CVPixelBufferLockBaseAddress(pixelBuffer, 0)
        var uiImage = imageFromSampleBuffer(pixelBuffer)
        uiImage = uiImage?.imageRotatedByDegrees(90, flip: false)
        uiImage = uiImage?.cropsToSquare()
        let faceHaarPath = NSBundle.mainBundle().pathForResource("face", ofType:"xml")
        let smileHaarPath = NSBundle.mainBundle().pathForResource("smile", ofType: "xml")
        if  OpenCVWrapper.processSmileWithOpenCV(uiImage, faceHaarPath, smileHaarPath) {
            print("smile recieved")
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
