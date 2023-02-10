//
//  VideoPreviewViewController.swift
//  dub.ly
//
//  Created by DINESH GUPTHA on 12/17/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import AVFoundation
import UIKit
import SCRecorder
import AVKit
import AssetsLibrary
import Photos
import MobileCoreServices

protocol VideoPreviewViewControllerDelegate {
    func storyPostingDone()
}
protocol ChatVideoDelegate{
    func selectedVideo(video: URL)
}
protocol ClearVideoSegments {
    func resetVideoRecorder()
}
class VideoPreviewViewController: FiilterViewController {
    
    @IBOutlet weak var viewForPlayer: UIView!
    
    @IBOutlet weak var saveLabel: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var storyLabel: UILabel!
    @IBOutlet weak var storyBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var addMusicButton: UIButton!
    @IBOutlet weak var topMenuView: UIView!
    var videoConfig:SCFilterImageView?
    @IBOutlet weak var bottomMenuView: UIView!
    @IBOutlet weak var nextBtnOutlet: UIBarButtonItem!
    
    var session = SCRecordSession()
    let player = SCPlayer()
    let storyAPIObj = StoryAPI()
    var selectedAudio:Audio?
    var audioPlayer:AVAudioPlayer?
    var videoAssest:AVAsset?
    var videoUrl: String?
    var videoUrlAsset: AVURLAsset?
    fileprivate var originalImage: UIImage?
    fileprivate var avVideoComposition: AVVideoComposition!
    var addVideoAsset = true
    var isForStory = false
    var isFromRecording: Bool = false
    var isForInstagramCamera = false
    var chatVideoDelegateObj: ChatVideoDelegate?
    var clearVideoDelObj: ClearVideoSegments?
    var isFromChat:Bool = false
    var audioPath: URL?
    var delegate: VideoPreviewViewControllerDelegate?
    var isPlayerAdded = true
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
         isPlayerAdded = true
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.title = "Edit".localized
        self.saveLabel.text = "Save".localized
        self.storyLabel.text = "Your Story".localized
        self.nextBtnOutlet.title = "Next".localized
        self.nextBtnOutlet.tintColor = .label
        if !isForStory {
            self.saveLabel.isHidden = true
            self.saveBtn.isHidden = true
            self.storyBtn.isHidden = true
            self.storyLabel.isHidden = true
        } else {
            self.shareBtn.isHidden = true
            self.navigationItem.rightBarButtonItem = nil
        }
        
        if addVideoAsset {
            addVideoAsset = false
            if !isForInstagramCamera {
                videoAssest = session.assetRepresentingSegments()
            }
            let playerView = SCVideoPlayerView.init(player: self.player)
            playerView.playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
            playerView.frame = self.viewForPlayer.bounds
            playerView.autoresizingMask = self.viewForPlayer.autoresizingMask
            if isPlayerAdded {
            self.viewForPlayer.addSubview(playerView)
                isPlayerAdded = false
            }
            player.loopEnabled = true
            player.delegate = self
            viewForPlayer.bringSubviewToFront(topMenuView)
            viewForPlayer.bringSubviewToFront(bottomMenuView)
        
            self.playVideoWith()
        }
        
        if let stringUrl = self.videoUrl, let url = URL(string: stringUrl){
            self.setUpFilterCollectionView(url: url)
        }else{
            
            session.mergeSegments(usingPreset: AVAssetExportPresetHighestQuality) { (url, error) in
                if (error == nil) {
                    //                let url = self.session.outputUrl
                    self.setUpFilterCollectionView(url: url!)
                } else {
                    debugPrint(error as Any)
                }
            }
        }
    }
    
      override func viewDidAppear(_ animated: Bool) {
          super.viewDidAppear(animated)
          

      }
      
      override func viewWillDisappear(_ animated: Bool) {
            super.viewDidDisappear(true)
          
        }
    
    private func setUpFilterCollectionView(url: URL){
        self.videoUrl = url.absoluteString
        self.videoUrlAsset = AVURLAsset(url: url)
        self.image = self.videoUrlAsset!.videoToUIImage()
        self.originalImage = self.image
        
        DispatchQueue.main.async {
            self.playVideoWith()
        }
        if let image = self.image {
            self.imageView?.image = image
            self.smallImage = self.resizeImage(image: image)
        }
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        
    }
    
    func checkIsAnyNewStoryAvailble(newStoryDetails:[String:Any]) {
        self.postNewStory(storyDetails:newStoryDetails)
    }
    
    func doneEditingVideo(videoUrl: URL) {
        DispatchQueue.main.async {
        StoryHelper.uploadVideoToCloudinary(videoURL: videoUrl, view: self.view, message:"Uploading Video ..", onCompletion:  { (isuploaded,storyDetails) in
            if(isuploaded) {
                self.checkIsAnyNewStoryAvailble(newStoryDetails: storyDetails)
            }
        })
        }
    }
    
    func postNewStory(storyDetails:[String:Any]) {
        if videoUrl != nil {
        Helper.showPI()
        }else {
        Helper.hidePI()
        }
         
        
        let videoDuration = player.currentItem?.duration.seconds.convertDurationToMs()
        let storyDetails = ["type":storyDetails["type"] ?? "","isPrivate":false,"urlPath":storyDetails["urlPath"] ?? "","thumbnail":storyDetails["thumbnail"] ?? "","duration":videoDuration ?? ""]
        storyAPIObj.postNewStory(with:AppConstants.postStory , params:storyDetails, complitation: { (response, error) in
            print("responce")
            Helper.hidePI()
            if self.delegate != nil{
                self.delegate?.storyPostingDone()
            }
            self.presentingViewController?
                .presentingViewController?
                .dismiss(animated: true, completion: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ChangeCell"), object: nil)
        })
    }
    
    
    func playVideoWith(){
        guard let stringUrl = self.videoUrl else {
            return
        }
         playAudio()
        let url = URL(string: stringUrl)!
        let assets = AVAsset(url: url)
        player.setItemBy(assets)
        player.play()
    }
    
    func addSwipableFilters() {
        let swipableFilter = SCSwipeableFilterView(frame: self.viewForPlayer.bounds)
        swipableFilter.filters = [SCFilter (ciFilterName:"CIPhotoEffectChrome"),SCFilter (ciFilterName:"CIMinimumComponent")]
        player.scImageView = swipableFilter
        self.viewForPlayer.addSubview(swipableFilter)
    }
    
    func saveFinalVideo(videoUrl:URL,isUpload:Bool,isShare:Bool) {
        Helper.showPI()
        if let audio = selectedAudio, let url = URL.init(string:audio.url ) {
            mergeFilesWithUrl(audioUrl:url ,isUpload:isUpload,isShare:isShare, videoUrl: videoUrl)
        } else {
            //there is no audio file was selected. so upload without audio.
            if isUpload {
                //upload cloudinary.
                self.doneEditingVideo(videoUrl: videoUrl)
            } else if isShare {
                //moving to share screen.
                self.moveToShareScreen(videoPath: videoUrl.absoluteString)
            } else {
                //save to gallery.
                DispatchQueue.main.async {
                self.saveVideoToGallery(filePath: videoUrl)
                }
                
            }
        }
    }
    
    
    
    @IBAction func addStoryBtnAction(_ sender: Any) {
        mergeSegments(isUpload:true,isShare:false)
    }
    
    @IBAction func saveBtnAction(_ sender: Any) {
        mergeSegments(isUpload:false,isShare:false)
    }
    
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.clearVideoDelObj?.resetVideoRecorder()
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        mergeSegments(isUpload:false, isShare:true)
    }
    
    func moveToShareScreen(videoPath:String) {
        if isFromChat {
            Helper.hidePI()
            DispatchQueue.main.async {
                self.dismiss(animated: true) {
                    guard let videoUrl = URL(string: videoPath) else{return}
                    self.chatVideoDelegateObj?.selectedVideo(video: videoUrl)
                }
            }
        }else{
            //getting thumbnail image.
            var thumbNailImage = UIImage()
            guard let videoUrl = URL(string: videoPath) else{return}
            let avAsset = AVAsset(url: videoUrl)
            do {
                let imageGenerator = AVAssetImageGenerator(asset: avAsset)
                imageGenerator.appliesPreferredTrackTransform = true
                let cgImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 3, timescale: 1), actualTime: nil)
                let thumbnail = UIImage(cgImage: cgImage)
                thumbNailImage = thumbnail
            }catch{
                print("Error is : \(error)")
            }
            
            DispatchQueue.main.async {
                self.player.pause()
                self.audioPlayer?.stop()
                self.audioPlayer?.pause()
                let createPostVc = CreatePostViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.CreatePost) as CreatePostViewController
                createPostVc.mediaPath = videoPath
                createPostVc.selectedImage = thumbNailImage
                createPostVc.isForVideo = true
                createPostVc.selectedAudio = self.selectedAudio
                createPostVc.isFromRecording = self.isFromRecording
                self.navigationController?.pushViewController(createPostVc, animated:true)
                Helper.hidePI()
            }
            
        }
      
    }
    
    
    func mergeSegments(isUpload:Bool,isShare:Bool) {
        if let urlAssets = self.videoUrlAsset, let composition = self.avVideoComposition{
            Helper.showPI()
            urlAssets.exportFilterVideo(videoComposition: composition , completion: { (url) in
                guard let urlObject = url as URL? else{return}
                self.saveFinalVideo(videoUrl:urlObject, isUpload:isUpload,isShare:isShare)
            })
        }
        else if let urlString = self.videoUrl{
            guard let url = URL(string: urlString) else{return}
            self.saveFinalVideo(videoUrl:url, isUpload:isUpload,isShare:isShare)
        }
    
    }
    
    func updateFilterToVideoOverLay() {
        videoConfig = SCFilterImageView(frame: self.view.bounds)
        videoConfig!.filter = SCFilter(ciFilterName:"CIPhotoEffectInstant");
        player.scImageView?.backgroundColor = UIColor.clear
        player.scImageView = videoConfig!
    }
    
    func mergeFilesWithUrl(audioUrl:URL,isUpload:Bool,isShare:Bool, videoUrl: URL)
    {
        let mixComposition : AVMutableComposition = AVMutableComposition()
        var mutableCompositionVideoTrack : [AVMutableCompositionTrack] = []
        var mutableCompositionAudioTrack : [AVMutableCompositionTrack] = []
        let totalVideoCompositionInstruction : AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        
        //start merge
        let videoAsset = AVAsset(url: videoUrl)
        let aVideoAsset : AVAsset = videoAsset
        let aAudioAsset : AVAsset = AVAsset(url: audioUrl)
        var aVideoAssetTrack : AVAssetTrack!
        mutableCompositionVideoTrack.append((mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid))!)
        mutableCompositionAudioTrack.append( mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!)
        
        if !aVideoAsset.tracks(withMediaType: AVMediaType.video).isEmpty {
            aVideoAssetTrack = aVideoAsset.tracks(withMediaType: AVMediaType.video)[0]
               let aAudioAssetTrack : AVAssetTrack = aAudioAsset.tracks(withMediaType: AVMediaType.audio)[0]
            do{
                try mutableCompositionVideoTrack[0].insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aVideoAssetTrack, at: CMTime.zero)
                
                //In my case my audio file is longer then video file so i took videoAsset duration
                //instead of audioAsset duration
                
                try mutableCompositionAudioTrack[0].insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aAudioAssetTrack, at: CMTime.zero)
            } catch let error {
                print(error.localizedDescription)
            }
            
            totalVideoCompositionInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero,duration: aVideoAssetTrack.timeRange.duration )
            
            let mutableVideoComposition : AVMutableVideoComposition = AVMutableVideoComposition()
            mutableVideoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
            
            //mutableVideoComposition.renderSize = CGSizeMake(1280,720)
            
            let timeStamp = Helper.getcurrentDataAndtimeForSave()
            
            //find your video on this URl
            let savePathUrl : URL = URL(fileURLWithPath: NSHomeDirectory() + "/Documents"+"/"+"\(timeStamp)"+".mp4")
           let assetExport : AVAssetExportSession
            assetExport = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)!
            assetExport.outputFileType = AVFileType.mp4
            assetExport.outputURL = savePathUrl
            assetExport.shouldOptimizeForNetworkUse = true
            
            assetExport.exportAsynchronously { () -> Void in
                switch assetExport.status {
                    
                case AVAssetExportSession.Status.completed:
                    if isUpload {
                        //upload to cloudinary.
                        self.doneEditingVideo(videoUrl: savePathUrl)
                    } else if isShare {
                        self.moveToShareScreen(videoPath:savePathUrl.absoluteString)
                    } else {
                        //save to galley.
                        DispatchQueue.main.async {
                        self.saveVideoToGallery(filePath: savePathUrl)
                        }
                        
                    }
                case  AVAssetExportSession.Status.failed:
                    print("failed \(String(describing: assetExport.error))")
                    Helper.hidePI()
                case AVAssetExportSession.Status.cancelled:
                    print("cancelled \(String(describing: assetExport.error))")
                    Helper.hidePI()
                default:
                    print("complete")
                }
            }
        }else {
            
            return
        }
   }
    
    
    func saveVideoToGallery(filePath:URL) {
        PHPhotoLibrary.shared().performChanges({ () -> Void in
            
            let createAssetRequest: PHAssetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL:filePath)!
            _ = createAssetRequest.placeholderForCreatedAsset
            
        }) { (success, error) -> Void in
            
            
            Helper.hidePI()
            
            if success {
                
                //popup alert success
                let alert = UIAlertController(title: "Video Saved".localized, message: "Video successfully saved to Photos library".localized, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK".localized, style: UIAlertAction.Style.default, handler: nil))
                DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
                }
                
            }
            else {
                //popup alert unsuccess
                let alert = UIAlertController(title: "Failed".localized, message: "Video Failed to save in Photos library".localized, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK".localized, style: UIAlertAction.Style.default, handler: nil))
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    
    func playAudio() {
        if let _ = selectedAudio,let path = audioPath{
          player.volume = 0
          do {
        try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default,options: .defaultToSpeaker)
                   try AVAudioSession.sharedInstance().setActive(true)
                   audioPlayer = try AVAudioPlayer(contentsOf: path, fileTypeHint: AVFileType.m4a.rawValue)
                   audioPlayer?.enableRate = true
                   audioPlayer?.numberOfLoops = -1
                   audioPlayer?.prepareToPlay()
                   audioPlayer?.play()
            }
          catch{
            
            }
        }
    }
    
    
    deinit {
        print("controller deinitialzed")
    }
    

    
    //MARK:- Video Filter methods
    
    func playVideo(video:AVURLAsset, filterName:String){
        let avPlayerItem = AVPlayerItem(asset: video)
        if(filterIndex != 0){
            //            guard let url = URL(string: self.videoUrl!) else{return}
            let url = URL(string: self.videoUrl!)!
            let asset = AVURLAsset(url: url)
            
            avVideoComposition = AVVideoComposition(asset: asset, applyingCIFiltersWithHandler: { request in
                let source = request.sourceImage.clampedToExtent()
                let filter = CIFilter(name:filterName)!
                filter.setDefaults()
                filter.setValue(source, forKey: kCIInputImageKey)
                let output = filter.outputImage!
                request.finish(with:output, context: nil)
            })
            avPlayerItem.videoComposition = avVideoComposition
        }
        self.player.replaceCurrentItem(with: avPlayerItem)
        self.player.play()
    }
    
    override func applyFilter() {
        let filterName = filterNameList[filterIndex]
        if let image = self.image {
            self.originalImage = createFilteredImage(filterName: filterName, image: image)
        }
        let videoUrl = URL(string: self.videoUrl!)!
        let videoUrlAssets = AVURLAsset(url: videoUrl)
        playAudio()
        self.playVideo(video:videoUrlAssets, filterName:filterNameList[filterIndex])
    }
    
    override func createFilteredImage(filterName: String, image: UIImage) -> UIImage {
        if(filterName == filterNameList[0]){
            return self.image!
        }
        // 1 - create source image
        let sourceImage = CIImage(image: image)
        
        // 2 - create filter using name
        let filter = CIFilter(name: filterName)
        filter?.setDefaults()
        
        // 3 - set source image
        filter?.setValue(sourceImage, forKey: kCIInputImageKey)
        
        // 4 - output filtered image as cgImage with dimension.
        if let  imageObj = filter?.outputImage {
            let outputCGImage = context.createCGImage((imageObj), from: (imageObj.extent))
            
            // 5 - convert filtered CGImage to UIImage
            let filteredImage = UIImage(cgImage: outputCGImage!, scale: image.scale, orientation: image.imageOrientation)
            return filteredImage
        }
        return UIImage()
        
    }

}

extension VideoPreviewViewController:SCPlayerDelegate {
    
    func player(_ player: SCPlayer, didReachEndFor item: AVPlayerItem) {
     if let _ = selectedAudio{
       self.audioPlayer?.stop()
        self.playAudio()
        }
    }
}

extension Double {
    func toInt() -> Int? {
        if self > Double(Int.min) && self < Double(Int.max) {
            return Int(self)
        } else {
            return nil
        }
    }
}

extension Double {
    func convertDurationToMs() -> String?  {
        var durationInDouble = self * 1000.0
        durationInDouble = durationInDouble.rounded()
        let durationInInt = durationInDouble.toInt()
        let durationString:String = "\(durationInInt!)"
        return durationString
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
    return input.rawValue
}


