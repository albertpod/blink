import UIKit
import AVFoundation

var cameraView : UIView!

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var timerLabel: UILabel!
    var counter = 5
    var uiImage : UIImage?
    var timer = NSTimer()
    var detectedBlink = false
    var detectedSmile = false
    var detectedTime : NSDate?
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var videoCaptureOutput = AVCaptureVideoDataOutput()
    // If we find a device we'll store it here for later use
    var captureDevice : AVCaptureDevice?
    
    func timerAction() {
            counter -= 1
            timerLabel.text = "\(counter)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = self.view.bounds
        self.view.addSubview(blurView)*/
        print(self.view.bounds)
        
        cameraView = UIView(frame: CGRectMake(0, self.view.frame.width / 4, self.view.frame.size.width, self.view.frame.size.width))
        cameraView!.backgroundColor = UIColor(red: 0.5, green: 0.0, blue: 0.5, alpha: 1.0)
        cameraView!.alpha = 0
        //cameraView!.center = self.view.center;
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
    
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
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
        //previewLayer!.cornerRadius = 10
        
        //previewLayer!.borderColor = UIColor.whiteColor().colorWithAlphaComponent(0.5).CGColor
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
        print("frame recieved")
        let pixelBuffer: CVImageBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer)!
        CVPixelBufferLockBaseAddress(pixelBuffer, 0)
        uiImage = imageFromSampleBuffer(pixelBuffer)
        uiImage = uiImage?.imageRotatedByDegrees(90, flip: false)
        uiImage = uiImage?.cropsToSquare()
        if counter <= 0 {
            captureSession.stopRunning()
            detectedBlink = false
            performSegueWithIdentifier("showPhoto", sender : nil)
            timer.invalidate()
            counter = 5
        }
        let faceHaarPath = NSBundle.mainBundle().pathForResource("face", ofType:"xml")
        let eyesHaarPath = NSBundle.mainBundle().pathForResource("eyes", ofType:"xml")
        let openedEyePath = NSBundle.mainBundle().pathForResource("opened_eye", ofType:"xml")
        detectedBlink = detectEyeBlink(uiImage)
        if detectedBlink && counter == 5
        /*OpenCVWrapper.processImageWithOpenCV(uiImage, faceHaarPath, eyesHaarPath, openedEyePath)*/ {
            /*dispatch_async(dispatch_get_main_queue(), {
                self.shareToInstagram(uiImage!)
            })*/
            print("hho")
            timer = NSTimer(fireDate: NSDate().dateByAddingTimeInterval(0), interval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
            NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        }

        detectedSmile = detectSmile(uiImage)
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0)
        
        //UIImageWriteToSavedPhotosAlbum(uiImage!, self, "imageSaveMethod:didFinishSavingWithError:contextInfo:", nil);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showPhoto"){
            if let destination = segue.destinationViewController as? PhotoViewController {
                destination.postingPhoto = uiImage
            }
        }
    }
}
extension UIViewController {
    func canPerformSegue(id: String) -> Bool {
        let segues = self.valueForKey("storyboardSegueTemplates") as? [NSObject]
        let filtered = segues?.filter({ $0.valueForKey("identifier") as? String == id })
        return (filtered?.count > 0) ?? false
    }
}
/*https://www.hackingwithswift.com/example-code/system/how-to-run-code-at-a-specific-time*/