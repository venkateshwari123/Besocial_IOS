//
//  StoryHelper.swift
//  CameraModule
//
//  Created by Shivansh on 11/15/18.
//  Copyright © 2018 Shivansh. All rights reserved.
//

import UIKit
//import JGProgressHUD


class StoryHelper: NSObject {
  //  static let hud = JGProgressHUD(style: .dark)
    
    static func showPIOnView(view:UIView,message:String) {
       // hud.textLabel.text = message
       // hud.show(in: view)
        // hud.show(in: view, animated: true)
    }

    
    static func hidePi() {
       // hud.dismiss(afterDelay:0)
    }
    
    static func uploadImageToCloudinary(image:UIImage,view:UIView,message:String,onCompletion: @escaping (_ status: Bool,_ storyDetails:[String:Any]) -> Void) {
        Helper.showPI(_message:message)
        
        CloudinaryManager.sharedInstance.uploadImage(image: image, folder: .story) {(result,error) in
            hidePi()
       var storyDetails:[String:Any] = [:]
            if let url = result?.url {
          let newStory = ["caption":"","urlPath":url,"type":1,"thumbnail":url] as [String : Any]
           storyDetails = newStory
            onCompletion(true,storyDetails)
            }else{
                onCompletion(false, [:])
            }
      }
    }
    
    
    static func uploadImageToCloudinaryForTextStory(image:UIImage,view:UIView,message:String,onCompletion: @escaping (_ status: Bool,_ storyDetails:[String:Any]) -> Void) {
        Helper.showPI(_message:message)
        
        CloudinaryManager.sharedInstance.uploadImage(image: image, folder: .story) {(result,error) in
            hidePi()
            var storyDetails:[String:Any] = [:]
            if let url = result?.url {
                let newStory = ["urlPath":url] as [String : Any]
                storyDetails = newStory
                onCompletion(true,storyDetails)
            }else{
                onCompletion(false,[:])
            }
            
        }
    }
    
    static func uploadVideoToCloudinary(videoURL:URL,view:UIView,message:String,onCompletion: @escaping (_ status: Bool,_ storyDetails:[String:Any]) -> Void) {
        Helper.showPI(_message:message)
        
        CloudinaryManager.sharedInstance.uploadVideo(video: videoURL) {(result,error) in
            hidePi()
            var storyDetails:[String:Any] = [:]
            if let url = result?.url {
                let thumbNailUrl = url.replace(target:".mov", withString:".jpeg")
                /* Bug Name : post video to story not working
                 Fix Date : 9-jul-2021
                 Fixed By : Jayaram G
                 Description Of Fix : Added caption parameter
                 */
                let newStory = ["caption":"","urlPath":url,"type":2,"thumbnail":thumbNailUrl] as [String : Any]
                storyDetails = newStory
                onCompletion(true,storyDetails)
            }else{
                onCompletion(false,[:])
            }
            
        }
    }
    
}
