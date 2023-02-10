//
//  ShareToSocialViewController.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 27/07/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import UIKit
import FBSDKShareKit

class ShareToSocialViewController: UIViewController{
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var moreOptionsView: UIView!
    @IBOutlet weak var instagramView: UIView!
    @IBOutlet weak var faceBookView: UIView!
    @IBOutlet weak var faceBookBtn: UIButton!
    @IBOutlet weak var instagramBtn: UIButton!
    @IBOutlet weak var twitterBtn: UIButton!
    @IBOutlet weak var deeplinkBtn: UIButton!
    @IBOutlet weak var shareToLbl: UILabel!
    @IBOutlet weak var facebookLbl: UILabel!
    @IBOutlet weak var deeplinkLbl: UILabel!
    @IBOutlet weak var instagramLbl: UILabel!
    @IBOutlet weak var moreLbl: UILabel!
    
    var postData:SocialModel!
    var imageArrayToVideoURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        instagramView.isHidden = !checkIfInstagramAppInstalled()
        self.faceBookView.isHidden = !checkIfFacebookAppInstalled()
        if postData.isPurchased == 0 {
            self.faceBookView.isHidden = true
            self.instagramView.isHidden = true
            self.moreOptionsView.isHidden = true
        }
        shareToLbl.text = "Share to".localized
        facebookLbl.text = "Facebook".localized
        instagramLbl.text = "Instagram".localized
        deeplinkLbl.text = "Deeplink".localized
        moreLbl.text = "More".localized
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func shareToFaceBook(_ sender: Any) {
        shareToFaceBook()
    }
    
   
    
    @IBAction func shareToTwitter(_ sender: Any) {
        if postData.mediaType == 1 {
            self.downloadPostVideoImage { status in
                DispatchQueue.main.async {
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                    let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
                    if let lastAsset = fetchResult.firstObject {
                        print("identifier__ \(lastAsset.localIdentifier)")
                        self.getURL(ofPhotoWith: lastAsset) { url in
                            guard let assetUrl = url else {return}
                            SocialShareHelper.shareVideo(videoUrl: assetUrl.absoluteString, viewContr: self)
                        }
                    }
                }
            }
        }else{
            self.downloadPostVideoImage { status in
                DispatchQueue.main.async {
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                    let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                    if let lastAsset = fetchResult.firstObject {
                        guard let image = self.getUIImage(asset: lastAsset) else {
                            return
                        }
                        SocialShareHelper.shareImage(image: image, vcContr:self)
                    }
                }
            }
        }
    }
    
    @IBAction func shareToInstagram(_ sender: Any) {
        self.postImageToInstagram()
    }
    

    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    func checkIfFacebookAppInstalled() -> Bool {
        let facebookAppUrl = URL(string: "fb://")!
        return UIApplication.shared.canOpenURL(facebookAppUrl)
      }
    
    
    
        
    func checkIfInstagramAppInstalled() -> Bool {
        let instaAppUrl = URL(string: "instagram://")!
        return UIApplication.shared.canOpenURL(instaAppUrl)
      }
    
    func downloadPostVideoImage(complition: @escaping(Bool)->Void) {
        guard var mediaUrl = postData.imageUrl, let name = postData.title else{
            return
        }
        Helper.showPI(string: "Processing...")
        if AppConstants.appType == .picoadda{
            let width = Int(postData.imageUrlWidth/3)
            let height = Int(Double(width)*0.3)
            if let type = postData.mediaType{
            if type == 0{
                 mediaUrl = mediaUrl.replacingOccurrences(of: "upload/", with: "upload/w_\(width),h_\(height),g_south_east,c_lpad,l_picoaddaWatermark:imageWatermark.png/")
                Helper.downloadVideoLinkAndCreateAssetForSocialShare(mediaUrl, fileName: name, isVideo: false, messageTag: "Photo") { status in
                    Helper.hidePI()
                    if status {
                        complition(true)
                    }else{
                        Helper.showAlert(head: "", message: "Failed.")
                    }
                }
                
            }else{
                 mediaUrl = mediaUrl.replacingOccurrences(of: "upload/", with: "upload/w_\(width),h_\(height),g_south_east,l_picoaddaWatermark:videoWatermark.gif/")
                guard let mediaURL = URL(string: mediaUrl) else {return}
                guard let videoEndDetailsUrl = imageArrayToVideoURL else {return}
                let fileURLs = [mediaURL,videoEndDetailsUrl]
                
                DPVideoMerger().mergeVideos(withFileURLs: fileURLs) { mergedVideoURL, error in
                    if let videoUrl = mergedVideoURL{
                        print(videoUrl)
                        Helper.downloadVideoLinkAndCreateAssetForSocialShare(videoUrl.absoluteString, fileName: name, isVideo: true, messageTag:"Video") { status in
                            Helper.hidePI()
                            if status {
                                complition(true)
                            }else{
                                Helper.showAlert(head: "", message: "Failed.")
                            }
                        }
                        }
                        
                    
                }
                 
            }
            }
        }else{
            let width = Int(postData.imageUrlWidth/4)
            if let type = postData.mediaType{
                if type == 0{
                    mediaUrl = mediaUrl.replacingOccurrences(of: "upload/", with: "upload/w_\(width),g_south_east,l_dulyWaterMark:imageWaterMark.png/")
                    Helper.downloadVideoLinkAndCreateAssetForSocialShare(mediaUrl, fileName: name, isVideo: false, messageTag:"Photo") { status in
                        Helper.hidePI()
                        if status {
                            complition(true)
                        }else{
                            Helper.showAlert(head: "", message: "Failed.")
                        }
                    }
                }else{
                    mediaUrl = mediaUrl.replacingOccurrences(of: "upload/", with: "upload/w_\(width),h_\(width),g_south_east,l_WaterMark:videoWaterMark.gif/")
                    guard let mediaURL = URL(string: mediaUrl) else {return}
                    guard let videoEndDetailsUrl = imageArrayToVideoURL else {return}
                    let fileURLs = [mediaURL,videoEndDetailsUrl]
                    
                    
                    VideoGenerator.presetName = AVAssetExportPresetPassthrough
                    VideoGenerator.fileName = "merged"
                    
                    VideoGenerator.mergeMovies(videoURLs: fileURLs) { result in
                        switch result{
                            
                        case.success(let videoUrl):
                            print(videoUrl)
                            Helper.downloadVideoLinkAndCreateAssetForSocialShare(videoUrl.absoluteString, fileName: name, isVideo: true, messageTag:"Video") { status in
                                Helper.hidePI()
                                if status {
                                    complition(true)
                                }else{
                                    Helper.showAlert(head: "", message: "Failed.")
                                }
                            }
                        case .failure(let err):
                            print(err)
                        }
                    }
                    
                }
            }
        }
        
           
            
    }
    @IBAction func shareDeeplink(_ sender: Any) {
        let message = "Hey".localized + "! " + "Check out this post on".localized + " \(AppConstants.AppName) " + "app".localized
             Helper.createDeepLink(forPost: true, postModel: postData) { (success, url) in
                 if success{
                     let items: [Any] = [message, url as Any]
                     let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                     ac.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                     }
                     self.present(ac, animated: true)
                     print("Success")
                 }else{
                     print("Failed")
                 }
                 Helper.hidePI()
             }
    }
    
    
    func postImageToInstagram() {
        self.downloadPostVideoImage { status in
            DispatchQueue.main.async {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                
                var fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                
                if self.postData.mediaType == 1 {
                    fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
                }
                
                if let lastAsset = fetchResult.firstObject as? PHAsset {
                    
                    let url = URL(string: "instagram://library?LocalIdentifier=\(lastAsset.localIdentifier)")!
                    
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    } else {
                        if URL(string: "https://apps.apple.com/app/instagram/id389801252?vt=lo") != nil {
                            UIApplication.shared.open(URL(string: "https://apps.apple.com/app/instagram/id389801252?vt=lo")!)
                        }
                    }
                }
            }
        }
    }
    
    

    
    /*
     Bug Name:- Add Social media post share
     Fix Date:- 22/06/21
     Fix By  :- Jayram G
     Description of Fix:- updated code from dubly , improved share post
     */
    func shareToFaceBook(){
        let photo:SharePhoto = SharePhoto()
        if self.postData.mediaType == 1 {
            self.downloadPostVideoImage { status in
                DispatchQueue.main.async {
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                
                    let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
                print(fetchResult.count)

                    if let lastAsset = fetchResult.firstObject as? PHAsset {
                        let video = ShareVideo()
                        video.videoAsset = lastAsset
                        let content = ShareVideoContent()
                       content.video = video
                        let sd = ShareDialog()
                        sd.shareContent = content
                        sd.show()
                    }
                }
            }
        }else{
            self.downloadPostVideoImage { status in
                DispatchQueue.main.async {
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                    let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                    if let lastAsset = fetchResult.firstObject  as? PHAsset{
                        photo.image = self.getUIImage(asset: lastAsset)
                        photo.isUserGenerated = true
                        let content:SharePhotoContent = SharePhotoContent()
                        content.photos = [photo]
                        let sd = ShareDialog()
                        sd.delegate = self
                        sd.shareContent = content
                        sd.show()
                    }
                }
            }
        }
    }
    
    
    
    
}

extension ShareToSocialViewController: SharingDelegate {
   func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
       print("-----FB results \(results)")
   }
   
   func sharer(_ sharer: Sharing, didFailWithError error: Error) {
       print("-----FB Error \(error)")
   }
   
   func sharerDidCancel(_ sharer: Sharing) {
       print("-----FB Cancelled")
   }
    
    func getUIImage(asset: PHAsset) -> UIImage? {

        var img: UIImage?
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .original
        options.isSynchronous = true
        manager.requestImageData(for: asset, options: options) { data, _, _, _ in

            if let data = data {
                img = UIImage(data: data)
            }
        }
        return img
    }
    
    func getURL(ofPhotoWith mPhasset: PHAsset, completionHandler : @escaping ((_ responseURL : URL?) -> Void)) {
            
            if mPhasset.mediaType == .image {
                let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
                options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                    return true
                }
                mPhasset.requestContentEditingInput(with: options, completionHandler: { (contentEditingInput, info) in
                    completionHandler(contentEditingInput!.fullSizeImageURL)
                })
            } else if mPhasset.mediaType == .video {
                let options: PHVideoRequestOptions = PHVideoRequestOptions()
                options.version = .original
                PHImageManager.default().requestAVAsset(forVideo: mPhasset, options: options, resultHandler: { (asset, audioMix, info) in
                    if let urlAsset = asset as? AVURLAsset {
                        let localVideoUrl = urlAsset.url
                        completionHandler(localVideoUrl)
                    } else {
                        completionHandler(nil)
                    }
                })
            }
            
        }
}
