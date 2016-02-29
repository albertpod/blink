import UIKit
import AVFoundation

/*
http://stackoverflow.com/questions/34535452/ios-swift-custom-camera-overlay
*/

var gotImage: UIImageView?

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var videoCaptureOutput = AVCaptureVideoDataOutput()
    
    // If we find a device we'll store it here for later use
    var captureDevice : AVCaptureDevice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
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
                        beginSession()
                    }
                }
            }
        }
        
    }
    
    /*func focusTo(value : Float) {
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
                device.setFocusModeLockedWithLensPosition(value, completionHandler: {
                    (time) -> Void in
                    //
                })
                device.unlockForConfiguration()
            } catch let error as NSError {
                print(error.code)
            }
        }
    }*/
    
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    
    /*override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let anyTouch = touches.first as UITouch!
        _ = anyTouch.locationInView(self.view).x / screenWidth
        focusTo(Float(touchPercent))
    }*/
    
    /*override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let anyTouch = touches.first as UITouch!
        let touchPercent = anyTouch.locationInView(self.view).x / screenWidth
        focusTo(Float(touchPercent))
    }*/
    
    func configureDevice() {
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
                
            } catch let error as NSError {
                print(error.code)
            }
            //device.focusMode = .Locked
            device.unlockForConfiguration()
        }
        
    }
    
    func beginSession() {
        
        configureDevice()
        do {
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
        } catch let error as NSError {
            print(error.code)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.view.layer.addSublayer(previewLayer!)
        previewLayer?.frame = self.view.layer.frame
        
        let cameraQueue = dispatch_queue_create("cameraQueue", DISPATCH_QUEUE_SERIAL)
        
        videoCaptureOutput.setSampleBufferDelegate(self, queue: cameraQueue)
        
        captureSession.addOutput(videoCaptureOutput)
        
        captureSession.startRunning()
        
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didDropSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection:AVCaptureConnection!) {
        
        //let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
        //let image = UIImage(data: imageData)
        //_ = OpenCVWrapper.processImageWithOpenCV(image)
        print("frame dropped")
    }
    /* deprecated */
    
    func imageFromSampleBufferDep(sampleBuffer: CMSampleBuffer) -> UIImage {
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let cameraImage = CIImage(CVPixelBuffer: pixelBuffer!)
        return UIImage(CIImage: cameraImage)
    }
    
    func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> CGImageRef {
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let bytesPerRow = 5120;
        let width = CVPixelBufferGetWidth(imageBuffer!);
        let height = CVPixelBufferGetHeight(imageBuffer!);
        let colorSpace = CGColorSpaceCreateDeviceRGB();
        let baseAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer!, 0)
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue | CGBitmapInfo.ByteOrder32Little.rawValue)
        let newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, bitmapInfo.rawValue)
        let newImage = CGBitmapContextCreateImage(newContext);
        return newImage!
    }
    
    func captureOutput(captureOutput: AVCaptureOutput, didOutputSampleBuffer sampleBuffer: CMSampleBufferRef, fromConnection connection: AVCaptureConnection) {
        
        /*http://stackoverflow.com/questions/27962944/convert-a-cmsamplebuffer-into-a-uiimage */
        print("frame received")
        let cgImage = imageFromSampleBuffer(sampleBuffer)
        let theImage = UIImage(CGImage: cgImage)

        let faceHaarPath = NSBundle.mainBundle().pathForResource("face", ofType:"xml")
        let eyesHaarPath = NSBundle.mainBundle().pathForResource("eyes", ofType:"xml")
        UIImageWriteToSavedPhotosAlbum(theImage, self, "image:didFinishSavingWithError:contextInfo:", nil);
        //print(faceHaarPath, eyesHaarPath)
        //OpenCVWrapper.processImageWithOpenCV(theImage, faceHaarPath, eyesHaarPath)
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        if error == nil {
            
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "Save error", message: error?.localizedDescription, preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
    }
    
}