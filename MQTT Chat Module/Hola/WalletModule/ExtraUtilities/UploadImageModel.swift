//
//  UploadImageModel.swift
//  DayRunner
//
//  Created by Vasant Hugar on 27/06/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit

struct UploadImage {
    var image = UIImage()
    var path = ""
    
    init(image: UIImage, path: String) {
        self.image = image
        self.path = path
  }
}

protocol UploadImageModelDelegate : class{
    
    /// its a call back method , execute when image upload successfully on cloud storage
    /// - Parameter isSuccess: contains a bool value if image successfully uploaded on server , it will contains true otherwise false
    /// - Parameter url: url of uploaded image
    func callBackWithURL(isSuccess : Bool , url : String )
}

class UploadImageModel: NSObject {
    
    weak var delegate : UploadImageModelDelegate?
    private static var manager: UploadImageModel? = nil
    static var shared: UploadImageModel {
        if manager == nil {
            manager = UploadImageModel()
        }
        return manager!
    }
    
    override init() {
        super.init()
        
    }
    
    var uploadImages: [UploadImage] = []
    var imagesKey : [String] = []
    
//    private var amazon = AmazonWrapper.sharedInstance()
    private var cloudinary = CloudinaryManager.sharedInstance
    private var imageIndexa = 0
    private var deleteIndex = 0
    /// start delete image
    func startDelete(){
        if deleteIndex < imagesKey.count{
        
        }
    }
    
    /// Start Uploading Image
    func start() {
        
        if imageIndexa < uploadImages.count {
            /*
             Bug Name :- Set path for cloudinary for every upload module
             Fix Date :- 25/03/2021
             Fixed By :- Jayaram G
             Description Of Fix :- Added path for every upload module
             */
            uploadImage(uploadImg: uploadImages[imageIndexa])
            imageIndexa += 1
        }
        else {
            uploadImages.removeAll()
            imageIndexa = 0
            print("\n*****************************\nImage Uploading Completed\n*****************************\n")
        }
    }
    
    /// delete Images in Background
    ///
    // for amazon (AWS3)
//    private func deleteImage(keyName : String){
//        amazon.deleteImageFrom(keyName: keyName) { (success) in
//            print("\n*****************************\n Deleted Image: \n*****************************\n")
//        }
//    }
    
    
    /// Uplad Images in Background
    ///
    /// - Parameter uploadImg: Upload Image Object
    private func uploadImage(uploadImg: UploadImage) {
        
        CloudinaryManager.sharedInstance.uploadImage(image: uploadImg.image, folder: .other) { (result, error) in
                if let url = result?.url {
                    self.delegate?.callBackWithURL(isSuccess: true, url: url)
                    print("\n*****************************\nUploaded Image: \(url)\n*****************************\n")
                    self.start()
                }
            else{
                Helper.hidePI()
                Helper.showAlert(head: "Error", message: (error?.localizedDescription)!)
            }
        }
 
    }
}
