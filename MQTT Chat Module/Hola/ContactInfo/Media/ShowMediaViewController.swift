//
//  showMediaView.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 12/02/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import AVKit
import AssetsLibrary
import Photos
protocol ShowVideoPlayerDelegate {
    func presentVideoPlayer(withURL : URL)
}

class ShowMediaViewController : UIViewController {
    
    let  MyCollectionViewCellId = "ShowMediaCollectionViewCell"
    
    @IBOutlet weak var showMediaCollectionView: UICollectionView!
    
    @IBOutlet weak var playButtonOtuelt: UIButton!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var contentView: UIView!
    var isTapped = false
    var messages : [Message]!
    var selectedMessageUrl : String?
    var showVideoPlayerDelegate : ShowVideoPlayerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCell()
        self.showMediaCollectionView.delegate = self
        self.showMediaCollectionView.dataSource = self
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapCliked(tapGesture:)))
        self.view.addGestureRecognizer(tapGesture)
        self.showMediaCollectionView.isHidden = true
        self.scrollToSelectedIndex()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.editPlayButton()
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
    func scrollToSelectedIndex() {
        if let msgUrl = selectedMessageUrl {
            if let rowIndex = self.getCurrentIndex(withSelectedPath: msgUrl, withMediaMsgs: messages) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.showMediaCollectionView.isHidden = false
//                    self.showMediaCollectionView.scrollToItem(at: IndexPath(item: rowIndex, section: 0), at: .centeredHorizontally, animated: false)
                    self.showMediaCollectionView.setContentOffset(CGPoint(x: Int(self.showMediaCollectionView.frame.width) * rowIndex, y: 0), animated: false)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.playVideo()
                    }
                }
            }
        }
    }
    
    private func getCurrentIndex(withSelectedPath selectedPath : String, withMediaMsgs mediaMsgs: [Message]) -> Int? {
        let selectedMsg = mediaMsgs.filter({
            if let str = $0.getVideoFileName() {
                return str == selectedPath
            }
            return false
        })
        if selectedMsg.count>0 {
            if let rowIndex = mediaMsgs.index(of: selectedMsg[0]) {
                return rowIndex
            }
        }
        return nil
    }
    
    func registerCell() {
        self.showMediaCollectionView.register(UINib(nibName: "ShowMediaCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ShowMediaCollectionViewCell")
    }
    
    @IBAction func backCliked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func playButtonAction(_ sender: UIButton) {
        self.playVideo()
    }
    
    private func playVideo() {
        if let visibleCell = self.showMediaCollectionView.visibleCells.first as? ShowMediaCollectionViewCell {
            self.playButtonOtuelt.isSelected = true
            if let urlStr = visibleCell.videoURL {
                let mediaURL = URL(fileURLWithPath: urlStr)
                self.playVideo(withURL: mediaURL)
            }
        }
    }
    
    func playVideo(withURL url : URL) {
        let player = AVPlayer(url: url)
        self.playButtonOtuelt.isSelected = true
        let playerController = AVPlayerViewController()
        playerController.player = player
        self.present(playerController, animated: false, completion: {
            player.play()
            self.playButtonOtuelt.isSelected = false
        })
    }
    
    @IBAction func saveImageBtnAction(_ sender: UIButton) {
        
            if let visibleCell = self.showMediaCollectionView.visibleCells.first as? ShowMediaCollectionViewCell {
                if visibleCell.videoURL != nil && visibleCell.videoURL != "" {
                self.playButtonOtuelt.isSelected = true
                if let urlStr = visibleCell.videoURL {
                    let mediaURL = URL(fileURLWithPath: urlStr)
                    saveVideoToGallery(filePath: mediaURL)
                }
            }else{
                    UIImageWriteToSavedPhotosAlbum(visibleCell.showMediaImageView.image ?? UIImage(),self, #selector(self.image(_:withPotentialError:contextInfo:)), nil)
            }
        }
    }
    
    //MAKR: helper methods
    
    @objc func image(_ image: UIImage, withPotentialError error: NSErrorPointer, contextInfo: UnsafeRawPointer) {
        let alert = UIAlertController(title: "Image Saved".localized, message: "Image successfully saved to Photos library".localized, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK".localized, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
    
}

private extension ShowMediaViewController {
    
    @objc func swipeCliked() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func tapCliked(tapGesture : UITapGestureRecognizer){
        if isTapped == false {
            isTapped = true
            navView.isHidden = true
            bottomView.isHidden = true
        } else {
            isTapped = false
            navView.isHidden = false
            bottomView.isHidden = false
        }
    }
}

extension ShowMediaViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.editPlayButton()
    }
    
    fileprivate func editPlayButton() {
        self.playButtonOtuelt.isHidden = true
        if let visibleCell = self.showMediaCollectionView.visibleCells.first as? ShowMediaCollectionViewCell {
            self.playButtonOtuelt.isHidden = visibleCell.playButtonOutlet.isHidden
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.editPlayButton()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCellId, for: indexPath) as! ShowMediaCollectionViewCell
            cell.msgObject = messages[indexPath.row]
            cell.playButtonDelegate = self
        return cell
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
    }
}

extension ShowMediaViewController : playButtonActionDelegate {
    func playButtonPressed(withURLString urlStr: String) {
        let mediaURL = URL(fileURLWithPath: urlStr)
        self.playVideo(withURL: mediaURL)
    }
}

