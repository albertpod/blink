import UIKit
import AVFoundation
import CoreMotion

var motionManager: CMMotionManager!

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    @IBOutlet weak var blinkLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    var bug = false
    var fixMe = 0
    var counter = 5
    var cameraView : UIView!
    var bounds : CGRect!
    var uiImage : UIImage?
    var blinked = "None"
    var timer = NSTimer()
    var detectedBlink = false
    var detectedSmile = false
    var detectedTime : NSDate?
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var videoCaptureOutput = AVCaptureVideoDataOutput()
    var captureDevice : AVCaptureDevice?
    var orientations:UIInterfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
    
    func timerAction() {
        counter -= 1
        if counter == 0 {
            timerLabel.text = "\(counter)"
            return
        }
        timerLabel.text = "\(counter)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        blinkLabel.text = "Wait"
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
        
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
                // Finally check the position and confirm we've got the front camera
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
    
    override func  prefersStatusBarHidden() -> Bool {
        return false
    }
    
    func configureDevice() {
        if let device = captureDevice {
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
    
    func beginSession() {
        
        let cameraQueue = dispatch_queue_create("cameraQueue", DISPATCH_QUEUE_SERIAL)
        
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
        
        videoCaptureOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey:Int(kCVPixelFormatType_32BGRA)]
        
        videoCaptureOutput.setSampleBufferDelegate(self, queue: cameraQueue)
        
        captureSession.addOutput(videoCaptureOutput)
        
        captureSession.startRunning()
        
        configureDevice()
        
        self.view.layer.addSublayer(previewLayer!)
        
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didDropSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection:AVCaptureConnection!) {
        print("dropped")
    }
    
    func captureOutput(captureOutput: AVCaptureOutput, didOutputSampleBuffer sampleBuffer:CMSampleBufferRef, fromConnection connection: AVCaptureConnection) {
        dispatch_async(dispatch_get_main_queue(), {
                self.blinkLabel.text = "Blink me"
            })
        print("frame recieved")
        let pixelBuffer: CVImageBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer)!
        CVPixelBufferLockBaseAddress(pixelBuffer, 0)
        uiImage = imageFromSampleBuffer(pixelBuffer)
        if let accelerometerData = motionManager.accelerometerData {
            let angle = atan2(accelerometerData.acceleration.y, accelerometerData.acceleration.x)*180/M_PI
            print(angle)
            if (fabs(angle) <= 45){
                self.timerLabel.transform = CGAffineTransformMakeRotation(CGFloat(3*M_PI_2))
                print("landscape left")
            } else if ((fabs(angle) > 45) && (fabs(angle) < 135)) {
                if (angle > 0) {
                    uiImage = uiImage?.imageRotatedByDegrees(270, flip: false)
                    self.timerLabel.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
                    print("portrait upside down")
                    
                } else {
                    uiImage = uiImage?.imageRotatedByDegrees(90, flip: false)
                    self.timerLabel.transform = CGAffineTransformMakeRotation(CGFloat(0))
                    print("portrait")
                    
                }
            } else {
                uiImage = uiImage?.imageRotatedByDegrees(180, flip: false)
                self.timerLabel.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
                print("landscape right")
                
            }
        }
        uiImage = uiImage?.cropsToSquare()
        if counter == 0 {
            timer.invalidate()
            counter = 5
            fixMe = 0
            performSegueWithIdentifier("showPhoto", sender : nil)
        }
        let faceHaarPath = NSBundle.mainBundle().pathForResource("face", ofType:"xml")
        let eyesHaarPath = NSBundle.mainBundle().pathForResource("eyes", ofType:"xml")
        let openedEyePath = NSBundle.mainBundle().pathForResource("opened_eye", ofType:"xml")
        blinked = OpenCVWrapper.processBlinkWithOpenCV(uiImage, faceHaarPath, eyesHaarPath, openedEyePath)
        if blinked != "None" && counter == 5 {
            print("blinked")
            dispatch_async(dispatch_get_main_queue(), {
                self.blinkLabel.text = self.blinked
            })
            timer = NSTimer(fireDate: NSDate().dateByAddingTimeInterval(0), interval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
            NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        }
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showPhoto"){
            captureSession.stopRunning()
            captureSession.removeOutput(videoCaptureOutput)
            do {
                try captureSession.removeInput(AVCaptureDeviceInput(device: captureDevice))
            } catch let error as NSError {
                print(error.code)
            }
            if let destination = segue.destinationViewController as? PhotoViewController {
                destination.postingPhoto = uiImage
            }
        }
    }
}