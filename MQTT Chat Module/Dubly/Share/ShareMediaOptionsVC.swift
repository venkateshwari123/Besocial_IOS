//
//  ShareMediaOptionsVC.swift
//  Do Chat
//
//  Created by Rahul Sharma on 24/08/20.
//  Copyright © 2020 Rahul Sharma. All rights reserved.
//

import UIKit
import MobileCoreServices
import Alamofire
import AVKit
import Regift

protocol ShareMediaOptionsVCDelegate {
    func playVideo()
    func showMoreOptions()
    func deletePost()
    func editPost()
    func reportPost()
    func openSocialShareOptions(data: SocialModel)
}
var player: AVAudioPlayer?

enum MediaOptions : String, CaseIterable{
    case Duet
    case Bookmark
    case Forward
    case Download
    case Gif
    case CopyLink
    case Record
    case SharePost
    case ShareProfile
    case More
    case DeletePost
    case EditPost
    case Report
//    case More
}


class ShareMediaOptionsVC: UIViewController {
var data : SocialModel?
var videoFetcher = VideoFetcher()
var dynamicLinkForPost : URL?
var dynamicLinkForProfile : URL?
var imageArrayToVideoURL : URL?
    
/// Callback method , arg1 = audioPath, arg2 = playVideo, arg3 = bookmark
var callBack : ((String,Bool,Bool)->())?
var showMoreOptions : (()->())?
var bookmarkStatus = ""
var delegateObj: ShareMediaOptionsVCDelegate? = nil
@IBOutlet var optionsCollectionView : UICollectionView!
@IBOutlet var userName : UILabel!
@IBOutlet var views : UILabel!
let model = SaveCollectionViewModel.init(api: SavedCollectionAPI.init())
var dataModel = DublyPostDetailsViewModel()
    /* Feature Name : Share Profile
     Feature Date : 7-Apr-2021
     Feature Added By : jayaram G
     Description Of Feature : added anither option for share profile
     */
    var videoOptions = ["Bookmark","Forward","Download","Gif","CopyLink","Record","EditPost","DeletePost","Report"]
    var imageOptions = ["Bookmark","Forward","Download","CopyLink","EditPost","DeletePost","Report"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        Helper.navigationController = self.navigationController
        if let postData = data{
            if postData.isBookMarked{
                bookmarkStatus = "Bookmarked".localized
            }else{
                bookmarkStatus = "Bookmark".localized
            }
            userName.text = "@\(postData.userName ?? "")"
            userName.textColor = UIColor.setColor(lightMode: AppColourStr.textColor, darkMode: AppColourStr.whiteColor)
            views.textColor = UIColor.setColor(lightMode: AppColourStr.textColor, darkMode: AppColourStr.whiteColor)
            /*
             Bug Name:- view count is not same outside and inside
             Fix Date:- 07/04/2021
             Fixed By:- Jayaram G
             Description of Fix:- changed the parameter from data.
             */
                views.text = "\(postData.distinctView) " + "Views".localized
            
            /*
             Bug Name:- Handle options for self and other user profile
             Fix Date:- 20/04/2021
             Fixed By:- Jayaram G
             Description of Fix:- Removing options according to user profile
             */
            
            if postData.userId == Utility.getUserid() {
                imageOptions.remove(at: 6)
                videoOptions.remove(at: 8)
            }else{
                videoOptions.remove(at: 7)
                videoOptions.remove(at: 6)
                imageOptions.remove(at: 5)
                imageOptions.remove(at: 4)
            }
            if let audioData =  postData.mediaData, let id = audioData.mediaId, id.count > 0{
                videoOptions.remove(at: 5)
            }
            optionsCollectionView.delegate = self
            optionsCollectionView.dataSource = self
        }
        self.createDynamicLinkForPost()
        self.createDynamicLinkForProfile()
     NotificationCenter.default.addObserver(self, selector: #selector(postSavedToCollection), name: NSNotification.Name(rawValue: "PostSaved"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(true)
           self.navigationController?.navigationBar.isHidden = true
       }
    
    deinit {
         NotificationCenter.default.removeObserver(self)
      }
    
    /* Feature Name : Share Profile
     Feature Date : 7-Apr-2021
     Feature Added By : jayaram G
     Description Of Feature : separated creating dynamiclinks for proflie and post
     */
    func createDynamicLinkForPost(){
        guard let postData = data else{
            return
        }
        Helper.createDeepLink(forPost: true, postModel: postData) { (success, url) in
                        if success{
                            self.dynamicLinkForPost = url
                        }else{
                        }
        }
    }
    
    
    /* Feature Name : Share Profile
     Feature Date : 7-Apr-2021
     Feature Added By : jayaram G
     Description Of Feature : separated creating dynamiclinks for proflie and post
     */
    func createDynamicLinkForProfile(){
        guard let postData = data else{
            return
        }
        Helper.createDeepLink(forPost: false, postModel: postData) { (success, url) in
                        if success{
                            self.dynamicLinkForProfile = url
                        }else{
                        }
        }
    }
    func extractAudioFromVideo(srcURL:URL){
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let audioPath = URL(fileURLWithPath: documentsDirectory!.absoluteString).appendingPathComponent("soundOneNew.m4a").path

        var myasset: AVAsset? = nil
         myasset = AVAsset(url: srcURL)

        var exportSession: AVAssetExportSession? = nil
        if let myasset = myasset {
            exportSession = AVAssetExportSession(asset: myasset, presetName: AVAssetExportPresetAppleM4A)
        }

        exportSession?.outputURL = URL(fileURLWithPath: audioPath)
        exportSession?.outputFileType = .m4a

        let vocalStartMarker = CMTimeMake(value: Int64(Int(floor(0 * 100))), timescale: 100)
        let vocalEndMarker = myasset!.duration //CMTimeMake(value: Int64(Int(ceil(myasset!.duration * 100))), timescale: 100)

        let exportTimeRange = CMTimeRangeFromTimeToTime(start: vocalStartMarker, end: vocalEndMarker)

        exportSession?.timeRange = exportTimeRange
        if FileManager.default.fileExists(atPath: audioPath) {
            do {
                try FileManager.default.removeItem(atPath: audioPath)
            } catch {
            }
        }

        exportSession?.exportAsynchronously(completionHandler: {
            if exportSession?.status == .failed {
                print("failed")
                Helper.hidePI()
            } else {
                print("AudioLocation : \(audioPath)")
                Helper.hidePI()
                if let closure = self.callBack{
                    DispatchQueue.main.async {
                        closure(audioPath,false,self.data!.isBookMarked)
                    Helper.navigationController = nil
                    self.dismiss(animated: false, completion: nil)
                    }
                    
                }
            }
        })

    }
    
    @objc  func postSavedToCollection(_ notification: NSNotification){
        if let collectionName = notification.object as? String {
            Helper.toastView(messsage: "Post saved to".localized + " \(collectionName)", view: self.view,isFromBookMark: true,controller : self)
        }
    }

    func playSound(urlPath:String) {
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: URL.init(string: urlPath)!, fileTypeHint: AVFileType.m4a.rawValue)

            /* iOS 10 and earlier require the following line:
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

            guard let player = player else { return }

            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
    

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let closure = self.callBack{
            closure("",true,self.data!.isBookMarked)
        }
         Helper.navigationController = nil
        self.dismiss(animated: true, completion: nil)
            
    }
    
    func presentWelcomeController() {
        let loginVC = LoginVC.instantiate(storyBoardName: "Authentication") as LoginVC
         loginVC.isFromHomeVC = true
         let navVC = UINavigationController(rootViewController: loginVC)
         navVC.modalPresentationStyle = .overCurrentContext
         navVC.navigationBar.isHidden = true
         self.present(navVC, animated: true, completion: nil)
     }
    
    /// Function to navigate to saved Collection
    /// - Parameter sender: tag = 1 save to collection, tag = 0 show the collection
    @objc func toastAction(sender : UIButton){
        let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Main, bundle: nil)
              let collectionVC = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.SavedCollectionsViewController) as! SavedCollectionsViewController
              collectionVC.hidesBottomBarWhenPushed = true
       
        if sender.tag == 1, let postData = data{
             collectionVC.isFromHome = true
            collectionVC.postIdToSave = postData.postId!
            collectionVC.thumnailToSave = postData.mainImageUrl!
        }
       self.navigationController?.pushViewController(collectionVC, animated: true)
        
    }

}

extension ShareMediaOptionsVC:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let postData = data, postData.mediaType == 0{
            return imageOptions.count
        }else{
        return  videoOptions.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShareMediaOptionsCell", for: indexPath) as? ShareMediaOptionsCell else{return UICollectionViewCell()}
        cell.bookmarkStatus = bookmarkStatus
        if let postData = data, postData.mediaType == 0{
            cell.setView(value: imageOptions[indexPath.row])
               }else{
            cell.setView(value: videoOptions[indexPath.row])
               }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var option = ""
       if let postData = data, postData.mediaType == 0{
                   option = imageOptions[indexPath.row]
                   }else{
                    option =  videoOptions[indexPath.row]
                   }
        switch MediaOptions.init(rawValue:option ) {
         case .Duet:
          break
         case .Bookmark:
              if let status = Utility.getIsGuestUser() , status {
                presentWelcomeController()
                return
              }
            if let postData = data,let id = postData.postId {
                  if !postData.isBookMarked {
                      model.addBookmark(id)
                      model.didUpdateDict = { response in
                        self.data?.isBookMarked = true
                        self.bookmarkStatus = "Bookmarked".localized
                        self.optionsCollectionView.reloadData()
                        Helper.toastView(messsage: "Save to collection".localized + ".", view: self.view,isFromBookMark: true,controller : self,isSaveToCollection: true)
                          
                      }
                      model.didError = { error in
                      }
                  }else{
                    self.model.removeBookmark(id)
                      self.model.didUpdateDict = { response in
                        self.data?.isBookMarked = false
                        self.bookmarkStatus = "Bookmark".localized
                     self.optionsCollectionView.reloadData()
                      Helper.toastView(messsage: "Post removed from collection".localized + ".", view: self.view, isFromBookMark: true,controller: self)
    
                      }
                      self.model.didError = { error in
                          
                      }
                      
                  }
            }
    
         break
         case .Forward:
            guard let postData = data else{
                return
            }
            /*
             Feature Name:- Added share posts to social media
             Feature Date:- 28/07/21
             Featured By:- Jayaram G
             Description of Feature:- Added delegate to open social sharing options
             */
            self.dismiss(animated: true) {
                self.delegateObj?.openSocialShareOptions(data: postData)
            }
         break
         case .Download:
            if let status = Utility.getIsGuestUser() , status {
                           presentWelcomeController()
                return
                         }
            guard let postData = data,var mediaUrl = postData.imageUrl, let name = postData.title else{
                return
            }
            /*
             Bug Name:- watermark is not look good, not able to download video/image
             Fix Date:- 24/05/21
             Fixed By:- Jayaram G
             Description of Fix:- manage width, height and padding, changed watermark path
             */
            let width = Int(postData.imageUrlWidth/4)
            if let isDownload = postData.allowDownload, isDownload, let type = postData.mediaType{
                if type == 0{
                    mediaUrl = mediaUrl.replacingOccurrences(of: "upload/", with: "upload/w_\(width),g_south_east,l_watermark:imageWatermark.png/")
                    Helper.downloadVideoLinkAndCreateAsset( mediaUrl, fileName: name, isVideo: false, messageTag: "Photo")
                }else{
                    mediaUrl = mediaUrl.replacingOccurrences(of: "upload/", with: "upload/w_\(width),g_south_east,l_watermark:videoWatermark.gif/")
                    guard let mediaURL = URL(string: mediaUrl) else {return}
                    guard let videoEndDetailsUrl = imageArrayToVideoURL else {return}
                    let fileURLs = [mediaURL,videoEndDetailsUrl] 
                    DispatchQueue.global(qos: .background).async {

                    DPVideoMerger().mergeVideos(withFileURLs: fileURLs) { mergedVideoURL, error in
                            if let videoUrl = mergedVideoURL{
                                print(videoUrl)
                                Helper.downloadVideoLinkAndCreateAsset(videoUrl.absoluteString, fileName: name, isVideo: true, messageTag: "Video")
                            }
                            
                        }
                        }
                    self.dismiss(animated: true,completion: {
                                      self.delegateObj?.playVideo()
                                  })
                }
            }else{
            Helper.toastView(messsage: "Downloading is disabled for this post".localized + ".", view: self.view)
            }
            
         break
         case .Gif:
            if let status = Utility.getIsGuestUser() , status {
                           presentWelcomeController()
                return
                         }
            guard var mediaUrl = data?.imageUrl, let name = data?.title else{
                          return
                      }
             Helper.toastView(messsage: "Download Will be available in your device gallery shortly".localized + ".", view: self.view)
            /*
             Bug Name:- Crashing on download gif
             Fix Date:- 10/07/21
             Fixed By:- Jayaram G
             Description of Fix:- Changed height and width
             */
            mediaUrl = mediaUrl.replacingOccurrences(of: "upload/", with: "upload/w_\(100),h_\(100),g_south_east,l_dulyWaterMark:videoWaterMark.gif/")
               let stamp  = arc4random_uniform(900000) + 100000
                let mediaName = "\(name)/\(stamp).mp4"
                    videoFetcher.downloadAndSave(videoUrl: URL.init(string: mediaUrl)!, fileName: mediaName, progress:{(progress) in
                    }, completionBlock: { (videoUrl) in
                              let frameCount = 16
                              let delayTime  = Float(0.2)
                              let loopCount  = 0
                              let regift = Regift(sourceFileURL: videoUrl!, frameCount: frameCount, delayTime: delayTime, loopCount: loopCount)
                            Helper.downloadVideoLinkAndCreateAsset(regift.createGif()!.absoluteString,fileName:mediaName, messageTag: "Gif")
                           })
          
         break
         case .CopyLink:
            guard let url =  dynamicLinkForPost else{
                return
            }
            UIPasteboard.general.string = url.absoluteString
            Helper.toastView(messsage: "Link Copied".localized, view: self.view)
         break
         case .Record:
            if let status = Utility.getIsGuestUser(), status {
                presentWelcomeController()
                return
                }
            guard let mediaUrl = data?.imageUrl, let name = data?.title else{
                                    return
                                }
                         Helper.showPI()
                      let stamp  = arc4random_uniform(900000) + 100000
                      let mediaName = "\(name)/\(stamp).mp4"
                 videoFetcher.downloadAndSave(videoUrl: URL.init(string: mediaUrl)!, fileName: mediaName, progress:{(progress) in
                 }, completionBlock: { (videoUrl) in
                     self.extractAudioFromVideo(srcURL: videoUrl!)
                        })

         break
        case .SharePost :
            
            /* Feature Name : Share Profile
             Feature Date : 7-Apr-2021
             Feature Added By : jayaram G
             Description Of Feature : separated creating dynamiclinks for proflie and post
             */
            let items: [Any] = ["Hey".localized + "! " + "Check out this post on".localized + " \(AppConstants.AppName) " +  "app".localized, dynamicLinkForPost as Any]
                                  let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                                  ac.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                                      
                                  }
                                  self.present(ac, animated: true)
         break
        
//        case .More :
//              if let status = Utility.getIsGuestUser() , status {
//                                                   presentWelcomeController()
//                                        return
//                                                 }
//              if let closure = self.showMoreOptions{
//                    closure()
//                  self.dismiss(animated: true, completion: nil)
//              }
//
//            break
        case .ShareProfile:
            
            /* Feature Name : Share Profile
             Feature Date : 7-Apr-2021
             Feature Added By : jayaram G
             Description Of Feature : separated creating dynamiclinks for proflie and post
             */
            let items: [Any] = ["Hey".localized + "! " + "Check out this profile on".localized + " \(AppConstants.AppName) " + "app".localized, dynamicLinkForProfile as Any]
                                      let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                                      ac.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                                          
                                      }
                    self.present(ac, animated: true)
            break
        case .none:
            break
        /*
         Bug Name:- Add Delete post , edit post and report in this screen
         Fix Date:- 20/04/2021
         Fixed By:- Jayaram G
         Description of Fix:- Added delete post , edit post and report actions
         */
        case .DeletePost:
            self.dismiss(animated: true) {
                DispatchQueue.main.async {
                    self.delegateObj?.deletePost()
                }
            }
            break
        case .EditPost:
            self.dismiss(animated: true) {
                DispatchQueue.main.async {
                    self.delegateObj?.editPost()
                }
            }
            break
        case .Report:
            self.dismiss(animated: true) {
                DispatchQueue.main.async {
                    self.delegateObj?.reportPost()
                }
            }
            break
        case .More:
            self.dismiss(animated: true) {
                DispatchQueue.main.async {
                    self.delegateObj?.showMoreOptions()
                }
            }
            
        }
        
    }

}

//extension ShareMediaOptionsVC:UICollectionViewDelegateFlowLayout{
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: self.view.frame.width/3 , height: 120)
//    }
//}


