//
//  CloudinaryHelper.swift
//  Sync1to1
//
//  Created by dinesh on 14/11/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import Foundation


class CloudinaryHelper: NSObject {
    
    static let sharedInstance = CloudinaryHelper()
    
    let cloudinary = CLDCloudinary(configuration: CLDConfiguration(cloudName:AppConstants.CloudinaryConstant.CLOUD_NAME, secure: true))
    
    func uploadImage(image: UIImage,folder:String, onCompletion: @escaping (_ status: Bool, _ url: String?) -> Void) {
        
        let params = CLDUploadRequestParams()
        params.setResourceType(CLDUrlResourceType.image)
        let data = image.jpegData(compressionQuality: 0.75)
        let timestamp = self.getCurrentTimeStamp()
        params.setPublicId("\(timestamp)")
        cloudinary.createUploader().upload(data: data!, uploadPreset: AppConstants.CloudinaryConstant.Preset, params: params, folder: folder, progress: nil, completionHandler: { (result, error) in
            if error != nil {
                onCompletion(false,"")
            } else {
                if let result = result{
                    onCompletion(true,result.resultJson["url"] as? String ?? "")
                }
            }
        })
    }
    
    func uploadVideo(video: URL, onCompletion: @escaping (_ status: Bool, _ url: String?) -> Void) {
        let params = CLDUploadRequestParams()
        params.setResourceType(CLDUrlResourceType.video)
        let timestamp = self.getCurrentTimeStamp()
        params.setPublicId("\(timestamp)")
        do {
            cloudinary.createUploader().uploadLarge(url:video , uploadPreset: AppConstants.CloudinaryConstant.Preset, params: params, chunkSize:  6 * 1024 * 1024, progress:{ (progress) in
              
            }, completionHandler: { (result, error) in
                 if error != nil {
                    onCompletion(false,"")
                } else {
                    if let result = result{
                        onCompletion(true,result.resultJson["url"] as? String ?? "")
                    }
                }
            })
            
        }
    }
    
    
    func getCurrentTimeStamp() -> String {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddhhmmssa"
        formatter.locale = Locale.current
        let result = formatter.string(from: date)
        return result
    }
}
