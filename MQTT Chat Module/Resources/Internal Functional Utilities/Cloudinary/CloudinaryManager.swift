//
//  CloudinaryManager.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 17/08/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import Foundation
import Cloudinary
import Locksmith
import Alamofire

enum CloudinaryFolder: String{
    case profileImage = "profile_images"
    case coverImage = "cover_images"
    case businessProfileImage = "business_profile_images"
    case businessCoverImage = "business_cover_images"
    case post = "posts"
    case kyc = "kyc"
    case liveStream = "livestream"
    case story = "stories"
    case other = "others"
}

final class CloudinaryManager {
    
    static let sharedInstance = CloudinaryManager()
    var config : CLDConfiguration?
    var cloudinary : CLDCloudinary?

    private init() {
        
    }
    
    
    var cloudName = ""
    var APIKey = ""
    var timeStamp: NSNumber = 0
    var signature = ""
    var timeStampForCover: NSNumber = 0
    var signatureForCover = ""
    var preset = ""
    var appName = AppConstants.AppName
   
    
    /// To upload image in cloudinary
    ///
    /// - Parameter image: image to upoload
    func uploadImage(image: UIImage,folder:CloudinaryFolder,publicId:String = Helper.currentTimeStamp,isForCover:Bool? = false,compressionQuality:Double = 1.0,progress: ((Progress) -> Void)? = nil, complication:@escaping(CLDUploadResult?, NSError?)->Void){
        
        self.getCloudinarySignature(folder: folder,publicID: publicId, isForCover: isForCover) { (success) in
            
            if success{
                let params = CLDUploadRequestParams()
                params.setResourceType(.image)
                params.setUploadPreset(self.preset)
                params.setPublicId(publicId)
                params.setFolder(self.appName + "/" + folder.rawValue)
                
                guard let imageData = image.jpegData(compressionQuality: compressionQuality) else{
                    Helper.showAlertViewOnWindow(Strings.error, message: "Something went wrong".localized)
                    return
                }
                
                    if isForCover ?? false{
                        params.setSignature(CLDSignature(signature: self.signatureForCover, timestamp: self.timeStampForCover))
                    }else{
                        params.setSignature(CLDSignature(signature: self.signature, timestamp: self.timeStamp))
                    }
                    
                self.cloudinary?.createUploader().signedUpload(data: imageData, params: params, progress: { (p) in
                        
                        if progress != nil{
                            progress!(p)
                        }
                        
                        
                    }, completionHandler: { (result, error) in
                        if error != nil{
                            Helper.showAlertViewOnWindow(Strings.error, message: (error?.localizedDescription)!)
                            complication(nil, error)
                        }else{
                            
                            complication(result, error)
                            
                        }
                    })
            }
            
        }
    }
    
    
    func uploadVideo(video: URL, progress: ((Progress) -> Void)? = nil, onCompletion: @escaping (CLDUploadResult?, NSError?) -> Void) {
        
        let timestamp = "\(Helper.getCurrentTimeStamp)"
        self.getCloudinarySignature(folder: CloudinaryFolder.post, publicID: timestamp) { (success) in
            
            if success{
                let params = CLDUploadRequestParams()
                params.setResourceType(.video)
                params.setUploadPreset(self.preset)
                params.setFolder(self.appName + "/" + CloudinaryFolder.post.rawValue)
                params.setPublicId("\(timestamp)")
                
                
                params.setSignature(CLDSignature(signature: self.signature, timestamp: self.timeStamp))
                
                self.cloudinary?.createUploader().signedUploadLarge(url: video, params: params, chunkSize:  6 * 1024 * 1024, progress: { (p) in
                    progress?(p)
                    
                }, completionHandler: { (result, error) in
                    if error != nil{
                        Helper.showAlertViewOnWindow(Strings.error, message: (error?.localizedDescription)!)
                        onCompletion(nil,error)
                    }else{
                        onCompletion(result, nil)
                    }
                })
            }
        }
    }
    
    
    func getCloudinarySignature(folder:CloudinaryFolder,publicID:String,isForCover:Bool? = false, complition: @escaping(Bool)->()){
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token, "lang":Utility.getSelectedLanguegeCode()]
        let params = ["folder": self.appName + "/" + folder.rawValue,
                      "public_id": publicID]
        let strURL = AppConstants.signature
        let apiCall = RxAlmofireClass()
        
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .post, parameters: params, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.profileResponse.rawValue)
        apiCall.subject_response
            .subscribe(onNext: {dict in
                if let dataArray = dict["data"] as? [String:Any]{
                    if let couldName = dataArray["cloudName"] as? String {
                        self.cloudName = couldName
                    }
                    
                    if let apiKey = dataArray["apiKey"] as? String{
                        self.APIKey = apiKey
                    }
                    
                    if let timeStamp = dataArray["timestamp"] as? Int{
                        if isForCover ?? false{
                            self.timeStampForCover = NSNumber(value: timeStamp)
                        }else{
                            self.timeStamp = NSNumber(value: timeStamp)
                        }
                        
                    }
                    
                    if let signature = dataArray["signature"] as? String {
                        if isForCover ?? false{
                            self.signatureForCover = signature
                        }else{
                            self.signature = signature
                        }
                        
                    }
                    
                    if let preset =  dataArray["preset"] as? String{
                        self.preset = preset
                    }
                    
                    self.config = CLDConfiguration(cloudName: self.cloudName, apiKey: self.APIKey)
                    self.cloudinary = CLDCloudinary(configuration: self.config!)
                    complition(true)
                }
            }, onError: {error in
                print("------CloudinarySignatureApi Error------",error)
                Helper.showAlertViewOnWindow(Strings.error, message: error.localizedDescription)
                complition(false)
                Helper.hidePI()
            })
    }
}
