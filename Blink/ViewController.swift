import UIKit
import AVFoundation

/*
http://stackoverflow.com/questions/34535452/ios-swift-custom-camera-overlay
*/

var gotImage: UIImageView?
var camFrame : CGRect?
var cameraView : UIView!

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, UIDocumentInteractionControllerDelegate {
    
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var videoCaptureOutput = AVCaptureVideoDataOutput()
    
    var documentController: UIDocumentInteractionController!
    // If we find a device we'll store it here for later use
    var captureDevice : AVCaptureDevice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        camFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)
        cameraView = UIView(frame: camFrame!)
        cameraView!.backgroundColor = UIColor(red: 0.5, green: 0.0, blue: 0.5, alpha: 1.0)
        cameraView!.alpha = 0.5
        cameraView!.center = self.view.center;
        self.view.addSubview(cameraView!)
        
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
    
    func beginSession() {
        
        var bounds : CGRect
        dispatch_async(dispatch_get_main_queue(), {
            // code here
        })
        let cameraQueue = dispatch_queue_create("cameraQueue", DISPATCH_QUEUE_SERIAL)
        
        configureDevice()
        do {
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
        } catch let error as NSError {
            print(error.code)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        bounds = cameraView!.layer.frame
        previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer!.bounds = bounds
        previewLayer!.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))
        self.view.layer.addSublayer(previewLayer!)
        
        videoCaptureOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey:Int(kCVPixelFormatType_32BGRA)]
        
        videoCaptureOutput.setSampleBufferDelegate(self, queue: cameraQueue)
        
        captureSession.addOutput(videoCaptureOutput)
        
        captureSession.startRunning()
        
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didDropSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection:AVCaptureConnection!) {
        //print("frame dropped")
    }
    
    func captureOutput(captureOutput: AVCaptureOutput, didOutputSampleBuffer sampleBuffer: CMSampleBufferRef, fromConnection connection: AVCaptureConnection) {
        
        let faceHaarPath = NSBundle.mainBundle().pathForResource("face", ofType:"xml")
        let eyesHaarPath = NSBundle.mainBundle().pathForResource("eyes", ofType:"xml")
        let openedEyePath = NSBundle.mainBundle().pathForResource("opened_eye", ofType:"xml")
        let pixelBuffer: CVImageBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer)!
        var uiImage = imageFromSampleBuffer(pixelBuffer)
        
        CVPixelBufferLockBaseAddress(pixelBuffer, 0)
        uiImage = uiImage?.imageRotatedByDegrees(90, flip: false)
        
        /*http://stackoverflow.com/questions/27962944/convert-a-cmsamplebuffer-into-a-uiimage */
        //print("frame received")

        if OpenCVWrapper.processImageWithOpenCV(uiImage, faceHaarPath, eyesHaarPath, openedEyePath) {
            print("blinked")
            captureSession.stopRunning()
            /*http://stackoverflow.com/questions/28302019/getting-a-this-application-is-modifying-the-autolayout-engine-error*/
            dispatch_async(dispatch_get_main_queue(), {
                self.shareToInstagram(uiImage!)
            })
            captureSession.startRunning()
        }
        //UIImageWriteToSavedPhotosAlbum(uiImage!, self, "imageSaveMethod:didFinishSavingWithError:contextInfo:", nil);
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