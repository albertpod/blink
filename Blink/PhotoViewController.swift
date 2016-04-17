//
//  PhotoViewController.swift
//  Blink
//
//  Created by Albert Podusenko on 17.04.16.
//  Copyright © 2016 Albert Podusenko. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController, UIDocumentInteractionControllerDelegate {
    @IBOutlet weak var sendedPhoto: UIImageView!
    var documentController: UIDocumentInteractionController!
    var postingPhoto : UIImage?
    
    override func viewDidLoad() {
        sendedPhoto.image = postingPhoto
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
