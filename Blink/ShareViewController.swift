//
//  ShareViewcontroller.swift
//  Blink
//
//  Created by Albert Podusenko on 18.04.16.
//  Copyright © 2016 Albert Podusenko. All rights reserved.
//

import UIKit
import Social
import SwiftyVK

class ShareViewController: UIViewController, UIDocumentInteractionControllerDelegate {
    
    var uiImage : UIImage?
    
    @IBAction func shareInstagram(sender: AnyObject) {
        if let shareImage = uiImage {
            shareToInstagram(shareImage)
        }
    }
    
    @IBAction func shareVK(sender: AnyObject) {
        if let shareImage = uiImage {
            APIWorker.uploadPhoto(shareImage)
        }
    }
    
    
    @IBAction func shareFacebook(sender: AnyObject) {
        if let shareImage = uiImage {
            let shareToFacebook : SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            shareToFacebook.setInitialText("#Blink")
            shareToFacebook.addImage(shareImage)
            self.presentViewController(shareToFacebook, animated: true, completion: nil)
        }
    }
    override func viewDidAppear(animated: Bool) {
    }
    
    var documentController: UIDocumentInteractionController!
    
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