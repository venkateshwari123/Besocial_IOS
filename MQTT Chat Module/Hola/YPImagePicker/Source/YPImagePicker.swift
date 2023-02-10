//
//  YPImagePicker.swift
//  YPImgePicker
//
//  Created by Sacha Durand Saint Omer on 27/10/16.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import PixelEditor
import PixelEngine

open class YPImagePickerConfiguration {
    public static let shared = YPImagePickerConfiguration()
    public var onlySquareImages = false
}

public class YPImagePicker: UINavigationController, PixelEditViewControllerDelegate {
    
    public static var albumName = "DefaultYPImagePickerAlbumName" {
        didSet { PhotoSaver.albumName = albumName }
    }
    
    public var showsVideo = true
    public var usesFrontCamera: Bool {
        get { return picker.usesFrontCamera }
        set { picker.usesFrontCamera = newValue }
    }
    public var showsFilters = true
    public var didSelectImage: ((UIImage) -> Void)?
    public var didSelectVideo: ((Data, UIImage) -> Void)?
    public var onlySquareImages = false {
        didSet {
            YPImagePickerConfiguration.shared.onlySquareImages = onlySquareImages
        }
    }
    
    //Permission related variables
    var isRequestedVideoPermisson:Bool {
        return UserDefaults.standard.bool(forKey:AppConstants.UserDefaults.isAppRequestedVideo)
    }
    var isRequestedAudioPermisson:Bool {
        return UserDefaults.standard.bool(forKey:AppConstants.UserDefaults.isAppRequestedAudio)
    }
    var isRequestedGalleryPermisson: Bool{
        return UserDefaults.standard.bool(forKey:AppConstants.UserDefaults.isAppRequestedGallery)
    }
    var isCameraPermissionGranted: Bool = false
    var isVideoPermissionGranted: Bool = false
    var isGalleryPermissionGranted: Bool = false
    var permissionView: PermissionView?
    
    private let picker = PickerVC()
    
    public func preheat() {
        _ = self.view
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if isRequestedVideoPermisson && isRequestedGalleryPermisson{
//            self.setUpPickerUI()
        }else{
            self.permissionView = PermissionView.instanceFromNib()

            self.permissionView!.didDismissPermissionView = {
                DispatchQueue.main.async { [unowned self] in
                    self.dismiss(animated: true, completion: nil)
                }
            }
            self.permissionView!.allPermissionDone = {
                DispatchQueue.main.async { [unowned self] in
                    self.permissionView?.removeFromSuperview()
                    self.permissionView = nil
                    self.setUpPickerUI()
                }
            }
        }
        self.setUpPickerUI()

    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let perView = self.permissionView else{return}
        perView.frame = self.view.bounds
        self.view.addSubview(perView)
        self.view?.bringSubviewToFront(perView)
    }
    
    
    
    func setUpPickerUI(){
        picker.showsVideo = showsVideo
        viewControllers = [picker]
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.tintColor = .systemBackground
        } else {
            // Fallback on earlier versions
        }
        navigationBar.isTranslucent = false
        navigationBar.backgroundColor = .systemBackground
        
        picker.didSelectImage = { [unowned self] pickedImage, isNewPhoto in
            Helper.hidePI()
            if self.showsFilters {
//                let filterVC = FiltersVC(image:pickedImage)
//                filterVC.didSelectImage = { filteredImage, isImageFiltered in
//                    self.didSelectImage?(filteredImage)
//                    if isNewPhoto || isImageFiltered {
//                        PhotoSaver.trySaveImage(filteredImage)
//                    }
//                }
                
                let filters = self.getFiltersCube()
                let storage = ColorCubeStorage(filters: filters)
                let filterVC = PixelEditViewController(image: pickedImage, colorCubeStorage: storage)
                filterVC.delegate = self
//                filterVC.navigationItem.title =
                
               
                // Use Fade transition instead of default push animation
                let transition = CATransition()
                transition.duration = 0.3
                transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                transition.type = CATransitionType.fade
                self.view.layer.add(transition, forKey: nil)
                self.pushViewController(filterVC, animated: false)
            } else {
                self.didSelectImage?(pickedImage)
                if isNewPhoto {
                    PhotoSaver.trySaveImage(pickedImage)
                }
            }
        }
        
        picker.didSelectVideo = { [unowned self] videoURL in
            let thumb = thunbmailFromVideoPath(videoURL)
            // Compress Video to 640x480 format.
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            if let firstPath = paths.first {
                let path = firstPath + "/\(Int(Date().timeIntervalSince1970))temporary.mov"
                let uploadURL = URL(fileURLWithPath: path)
                let asset = AVURLAsset(url: videoURL)
                let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPreset640x480)
                exportSession?.outputURL = uploadURL
                exportSession?.outputFileType = AVFileType.mov
                exportSession?.shouldOptimizeForNetworkUse = true //USEFUL?
                exportSession?.exportAsynchronously {
                    switch exportSession!.status {
                    case .completed:
                        if let videoData = FileManager.default.contents(atPath: uploadURL.path) {
                            DispatchQueue.main.async {
                                self.didSelectVideo?(videoData, thumb)
                            }
                        }
                    default:
                        // Fall back to default video size:
                        if let videoData = FileManager.default.contents(atPath: videoURL.path) {
                            DispatchQueue.main.async {
                                self.didSelectVideo?(videoData, thumb)
                            }
                        }
                    }
                }
            }
        }
        //force picker load view
        _ = picker.view
    }
    
    func getFiltersCube()->[FilterColorCube]{
        let filterArray = ["Clarendon".localized,"Inkwell".localized,"Sutro".localized,"Lofi".localized,"Earlybird".localized,"Oslo".localized,"Ginza".localized,"Dogpatch".localized]
        var filters = [FilterColorCube]()
        for index in 0...7{
            let imageName = "LUT_M0\(index + 1).png"
            guard let lutImage: UIImage = UIImage(named: imageName) else{continue}
            let filter = FilterColorCube(
                name: filterArray[index],
                identifier: imageName,
                lutImage: lutImage,
                dimension: 64
            )
            filters.append(filter)
        }
        return filters
    }
    
    //MARK:- Pixel editor delegate
    public func pixelEditViewController(_ controller: PixelEditViewController, didEndEditing editingStack: EditingStack) {
        controller.navigationController?.popViewController(animated: false)
        let image = editingStack.makeRenderer().render(resolution: .full)
        ImageSaveHelper.saveImageDocumentDirectory(imageToSave:image, completionHandler: { (imagePath) in
            let createPostVc = CreatePostViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.CreatePost) as CreatePostViewController
            self.isNavigationBarHidden = false
            createPostVc.mediaPath = imagePath
            createPostVc.selectedImage = image
            createPostVc.isForVideo = false
            self.pushViewController(createPostVc, animated:true)
        })
    }
    
    public func pixelEditViewControllerDidCancelEditing(in controller: PixelEditViewController) {
        controller.navigationController?.popViewController(animated: false)
    }
    
}

func thunbmailFromVideoPath(_ path: URL) -> UIImage {
    let asset = AVURLAsset(url: path, options: nil)
    let gen = AVAssetImageGenerator(asset: asset)
    gen.appliesPreferredTrackTransform = true
    let time = CMTimeMakeWithSeconds(0.0, preferredTimescale: 600)
    var actualTime = CMTimeMake(value: 0, timescale: 0)
    let image: CGImage
    do {
        image = try gen.copyCGImage(at: time, actualTime: &actualTime)
        let thumbnail = UIImage(cgImage: image)
        return thumbnail
    } catch { }
    return UIImage()
}
