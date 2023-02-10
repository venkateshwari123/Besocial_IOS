//
//  ImagePickerViewModel.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 11/12/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import TLPhotoPicker
import Photos

class ImagePickerViewModel {
    
    let chatViewObj : ChatViewController?
    var pickerView: TLPhotosPickerViewController?
    var selectedAssets = [TLPHAsset]()
    var selectedImg = [UIImage]()
    var selectedVideo = [String]()
    
    init(_ chatObj:ChatViewController) {
        chatViewObj = chatObj
    }
    
    
    func openIphoneLibrery(complition: @escaping ([TLPHAsset]) -> Void) {
        
        pickerView = TLPhotosPickerViewController(withTLPHAssets: { [weak self] (assets) in // TLAssets
            self?.selectedAssets = assets
            
            for asset in assets{
                if  asset.type == .photo{
                    
                //self?.selectedImg.append( asset.fullResolutionImage!)
                    
                }else if asset.type == .video{
                    
                    //asset.phAsset
                    let options: PHVideoRequestOptions = PHVideoRequestOptions()
                    options.version = .original
                    
                    PHImageManager.default().requestAVAsset(forVideo: asset.phAsset! , options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                        if let urlAsset = asset as? AVURLAsset {
                            let localVideoUrl: URL = urlAsset.url as URL
                            //selectedVideo.append(localVideoUrl)
                            print("video URL \(localVideoUrl)")
                            
                        } else {
                            
                        }
                    })
                }
            }
                complition(assets)
            
            }, didCancel: { [weak self] in
                DispatchQueue.main.async{
                    self?.chatViewObj?.dismiss(animated: true, completion: nil)
                }
                
        })
        
        pickerView?.didExceedMaximumNumberOfSelection = { [weak self] (picker) in
            //exceed max selection
            self?.openAlertView()
        }
        pickerView?.configure.maxSelectedAssets = 5
        pickerView?.configure.autoPlay = false
        pickerView?.selectedAssets = self.selectedAssets
        chatViewObj?.present(pickerView!, animated: true, completion: nil)
    }
    
    

    func openAlertView(){
        
        Helper.showAlertViewOnWindow("Oops".localized, message: "Exceed Maximum Number Of Selection".localized)
        
//        let alert = UIAlertController.init(title: "Oops", message: "Exceed Maximum Number Of Selection", preferredStyle: .alert)
//        let action = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
//        alert.addAction(action)
//        self.chatViewObj?.present(alert, animated: true, completion: nil)
    }
    
    
    
}

