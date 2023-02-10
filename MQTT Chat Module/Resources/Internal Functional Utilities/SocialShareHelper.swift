//
//  SocialShareHelper.swift
//  dub.ly
//
//  Created by Shivansh on 2/11/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class SocialShareHelper: NSObject {

    static func shareVideo(videoUrl:String,viewContr:UIViewController) {
        let url = URL(string:videoUrl)!

        
        //Show activity indicator
        Helper.showPI(_message: "Exporting".localized + " ..")
        DispatchQueue.global(qos: .background).async {
            
            if let urlData = NSData(contentsOf: url){
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let filePath="\(documentsPath)/tempFile.mov"
                DispatchQueue.main.async {
                    urlData.write(toFile: filePath, atomically: true)
                    
                    //Hide activity indicator
                    Helper.hidePI()
                    let activityVC = UIActivityViewController(activityItems: [NSURL(fileURLWithPath: filePath)], applicationActivities: nil)
                    activityVC.excludedActivityTypes = [.addToReadingList, .assignToContact,.copyToPasteboard,.message,.markupAsPDF,.openInIBooks,.saveToCameraRoll] // restricting some apps
                    viewContr.present(activityVC, animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async {
                    Helper.hidePI()
                }
            }
        }
    }
    
    static func shareImage(image:UIImage,vcContr:UIViewController) {
        // image to share
        // set up activity view controller
        let imageToShare = [image]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = vcContr.view // so that iPads won't crash
        activityViewController.excludedActivityTypes = [.addToReadingList, .assignToContact,.copyToPasteboard,.message,.markupAsPDF,.openInIBooks,.saveToCameraRoll]  // restricting some apps
        
        // present the view controller
        vcContr.present(activityViewController, animated: true, completion: nil)
    }
    
    
}
