//
//  PhotoViewController.swift
//  Blink
//
//  Created by Albert Podusenko on 17.04.16.
//  Copyright © 2016 Albert Podusenko. All rights reserved.
//

import UIKit
import AVFoundation

class PhotoViewController: UIViewController, UIDocumentInteractionControllerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    @IBOutlet weak var sendedPhoto: UIImageView!
    var documentController: UIDocumentInteractionController!
    var postingPhoto : UIImage?
    var captureSession = AVCaptureSession()
    var captureDevice : AVCaptureDevice?
    var videoCaptureOutput = AVCaptureVideoDataOutput()
    
    override func viewDidLoad() {
        sendedPhoto.image = postingPhoto
        let devices = AVCaptureDevice.devices()
        
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if(device.position == AVCaptureDevicePosition.Front) {
                    captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        print("Capture device found")
                        beginCheckingSmile()
                    }
                }
            }
        }

    }
    
    func configureDevice() {
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
                
            } catch let error as NSError {
                print(error.code)
            }
            device.unlockForConfiguration()
        }
        
    }

    func beginCheckingSmile() {
        
        configureDevice()
        do {
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
        } catch let error as NSError {
            print(error.code)
        }
        
        let cameraQueue = dispatch_queue_create("cameraQueue", DISPATCH_QUEUE_SERIAL)
        
        videoCaptureOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey:Int(kCVPixelFormatType_32BGRA)]
        
        videoCaptureOutput.setSampleBufferDelegate(self, queue: cameraQueue)
        
        captureSession.addOutput(videoCaptureOutput)
        
        captureSession.startRunning()
    }

    func captureOutput(captureOutput: AVCaptureOutput, didOutputSampleBuffer sampleBuffer: CMSampleBufferRef, fromConnection connection: AVCaptureConnection) {
        print("smile recieved")
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
    
    func shareToInstagram(image: UIImage) {
        
        let instagramURL = NSURL(string: "instagram://app")
        
        if (UIApplication.sharedApplication().canOpenURL(instagramURL!)) {
            
            let imageData = UIImageJPEGRepresentation(image, 100)
            let captionString = "caption"
            let writePath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("instagram.igo")
            
            if imageData?.writeToFile(writePath, atomically: true) == false {
                
                return
                
            } else {
                
                let fileURL = NSURL(fileURLWithPath: writePath)
                
                self.documentController = UIDocumentInteractionController(URL: fileURL)
                
                self.documentController.delegate = self
                
                self.documentController.UTI = "com.instagram.exlusivegram"
                
                self.documentController.annotation = NSDictionary(object: captionString, forKey: "InstagramCaption")
                self.documentController.presentOpenInMenuFromRect(self.view.frame, inView: self.view, animated: true)
                
            }
            
        } else {
            print(" Instagram isn't installed ")
        }
    }
}
