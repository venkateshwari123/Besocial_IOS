//
//  StreamViewController.swift
//  Stream
//
//  Created by Vengababu Maparthi on 13/11/18.
//  Copyright © 2018 Vengababu Maparthi. All rights reserved.
//

import UIKit
import AVFoundation
import CameraBackground

//import AntMediaSDK
protocol StreamViewControllerDelegate {
    func removeActiveStreams()
}
class StreamViewController: UIViewController {
    
    @IBOutlet weak var appNameLiveTitle: UILabel!
    @IBOutlet weak var liveImageView: UIImageView!
    @IBOutlet weak var detailsBackView: UIView!
    @IBOutlet weak var coverImageInstructionViewOutlet: UIView!
    @IBOutlet weak var retakeImage: UIButton!
    @IBOutlet weak var captureImage: UIButton!
    @IBOutlet weak var goLiveButton: UIButton!
    @IBOutlet weak var vwGoLive: UIView!
    @IBOutlet weak var vwShareStream: UIView!
    @IBOutlet weak var swtchShouldShare: UISwitch!
    @IBOutlet weak var shareButtonOutlet: UIButton!
    
    @IBOutlet weak var earnedMoneyLabel: UILabel!
    @IBOutlet weak var switchCameraBtn: UIButton!
    @IBOutlet weak var lblLiveTime: UILabel!
    @IBOutlet weak var lblGifts: UILabel!
    @IBOutlet weak var lblViews: UILabel!
    @IBOutlet weak var lblCoins: UILabel!
    @IBOutlet weak var lblstartStreaming: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var descriptionLbl2: UILabel!
    @IBOutlet weak var snapCoverPhoto: UILabel!
    @IBOutlet weak var streamEndedLbl: UILabel!
    @IBOutlet weak var coinTitleLbl: UILabel!
    @IBOutlet weak var giftsTitleLbl: UILabel!
    @IBOutlet weak var moneyEarnedTitleLbl: UILabel!
    @IBOutlet weak var viewCountTitleLbl: UILabel!
    @IBOutlet weak var liveTimeTitleLbl: UILabel!
    @IBOutlet weak var saveVideoTitleLbl: UILabel!
    
    
    var showShareStream : Bool = false
    var streamName : String = ""
    var usingFrontCamera = false
    /*need to check*/
    //    var temp = [UploadImage]()
    var imageUrl  = ""
    var selectImage = UIImage()
    var onStreamModel = ONStreamModel()
    var streamModel = StreamModel()
    var userImage = ""
    var streamTime : String = ""
    var delegateObj:StreamViewControllerDelegate?
    
    //MARK:- view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //        MQTT.sharedInstance.createConnection()
        self.appNameLiveTitle.text = "Live on".localized + " \(AppConstants.AppName)"
        self.lblstartStreaming.text = "Start Streaming".localized
        self.descriptionLbl.text = "We will notify your followers so that they will not miss this live session".localized + "."
        self.liveImageView.makeCornerRadious(readious: self.liveImageView.frame.width / 2)
        self.goLiveButton.setTitle("Start Live Stream".localized, for: .normal)
        self.snapCoverPhoto.text = "Snap cover photo".localized
        self.descriptionLbl2.text = "We will display your snap as your live stream cover photo".localized + "."
        self.streamEndedLbl.text = "Live stream ended".localized
        self.coinTitleLbl.text = "Coins".localized
        self.giftsTitleLbl.text = "Gifts".localized
        self.moneyEarnedTitleLbl.text = "Money Earned".localized
        self.viewCountTitleLbl.text = "View count".localized
        self.liveTimeTitleLbl.text = "Live Time".localized + " :"
        self.saveVideoTitleLbl.text = "Save your video under your profile for your followers to watch".localized + "."
        self.shareButtonOutlet.setTitle("Done".localized, for: .normal)
        UIApplication.shared.isIdleTimerDisabled = true
        self.goLiveButton.layer.cornerRadius = self.goLiveButton.frame.size.height / 2
        self.goLiveButton.makeGradientToUserView()
        self.detailsBackView.makeBorderWidth(width: 1.5, color: .white)
        if let name = Utility.getUserFullName() , name != ""{
            Helper.addedUserImage(profilePic: Utility.getUserImage(), imageView: self.liveImageView, fullName: name)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.addCameraBackground(.front, showButtons: false, buttonMargins:  self.view.layoutMargins)
        self.vwShareStream.isHidden = !showShareStream
        self.vwGoLive.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.endLiveStream), name: NSNotification.Name(rawValue: "EndLiveStream"), object: nil)
        if showShareStream {
            guard let streamId = Utility.getStreamId() else{return}
            streamModel.getSteramStats(streamID: streamId) { (response) in
                print("End Stream response\(response)")
                if let data = response!["data"] as? [String : Any]{
                    if let coins = data["totalEarning"] as? Int{
                        self.lblCoins.text = "\(coins)"
                    }
                    if let moneyEarned = data["MoneyEarn"] as? String {
                        self.earnedMoneyLabel.text = "\(Utility.getWalletCurrenySymbol()) \(moneyEarned)"
                    }
                    if let gifts = data["gifts"] as? Int{
                        self.lblGifts.text = "\(gifts)"
                    }
                    if let viewers = data["viwers"] as? Int{
                        self.lblViews.text = "\(viewers)"
                    }
//                    self.lblLiveTime.text = self.streamTime
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- buttons actions
    @IBAction func captureImage(_ sender: Any) {
        shoot()
    }
    
    @IBAction func backToTabbar(_ sender: Any) {
        if showShareStream{
            guard let streamId = Utility.getStreamId() else{return}
            
//            if let image = Utility.getUserImage(){
//                userImage = image
//            }
            Helper.showPI()
            let param = BroadCastParams.init(streamID: streamId, streamType: "stop", streamName: (Utility.getUserid()!)+streamName, streamThumbnail: userImage,record: false)
            streamModel.goToLiveStreaming(param: param) { (response) in
                UserDefaults.standard.removeObject(forKey: AppConstants.UserDefaults.activeStreamId)
                Helper.hidePI()
                self.dismiss(animated: true, completion: nil)
            }
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func btnShare_Tapped(_ sender: Any) {
        guard let streamId = Utility.getStreamId() else{return}
        
//        if let image = Utility.getUserImage(){
//            userImage = image
//        }
        Helper.showPI()
        let param = BroadCastParams.init(streamID: streamId, streamType: "stop", streamName: (Utility.getUserid()!)+streamName, streamThumbnail: userImage,record: false)
        streamModel.goToLiveStreaming(param: param) { (response) in
            UserDefaults.standard.removeObject(forKey: AppConstants.UserDefaults.activeStreamId)
            Helper.hidePI()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    @objc func endLiveStream() {
        guard let streamId = Utility.getStreamId() else{return}
        let param = BroadCastParams.init(streamID: streamId, streamType: "stop", streamName: (Utility.getUserid()!)+streamName, streamThumbnail: userImage,record: false)
        streamModel.goToLiveStreaming(param: param) { (response) in
            UserDefaults.standard.removeObject(forKey: AppConstants.UserDefaults.activeStreamId)
    }
    }
    
    func shoot() {
        view.takeCameraSnapshot({
            self.view.alpha = 0
            UIView.animate(withDuration: 1) { self.view.alpha = 1 }
        },completion: { capturedImage, error in
            if error == nil{
                self.selectImage = UIImage(cgImage: capturedImage!.cgImage!, scale: capturedImage!.scale, orientation: .leftMirrored)
                self.captureImage.isHidden = true
                self.switchCameraBtn.isHidden = true
                self.coverImageInstructionViewOutlet.isHidden = true
                self.goLiveButton.isHidden = false
                self.vwGoLive.isHidden = false
                self.retakeImage.isHidden = true
                
                self.uploadImageToCloudinary(imageObj: self.selectImage)
                
            }
        })
    }
    
     //method to upload data to cloudinary.
    func uploadImageToCloudinary(imageObj: UIImage) {
         
        CloudinaryManager.sharedInstance.uploadImage(image: imageObj, folder: .liveStream) { (result, error) in
            DispatchQueue.main.async {
                 if error != nil {
                    
                } else {
                    if let result = result {
                       self.userImage = result.url!
                       UserDefaults.standard.set(self.userImage, forKey: AppConstants.UserDefaults.streamThumbnailImage)
                    }
                }
            }
        }
     }
    
    
    
    @IBAction func retakeTheImage(_ sender: Any) {
        self.view.freeCameraSnapshot()
        self.captureImage.isHidden = false
        self.switchCameraBtn.isHidden = false
        self.coverImageInstructionViewOutlet.isHidden = false
        self.goLiveButton.isHidden = true
        self.retakeImage.isHidden = true
    }
    
    
    @IBAction func switchToggelAction(_ sender: Any) {
        if swtchShouldShare.isOn{
            self.shareButtonOutlet.setTitle("Share", for: .normal)
        }else{
            self.shareButtonOutlet.setTitle("Discard", for: .normal)
        }
    }
    
    
    @IBAction func goLive(_ sender: Any) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "GoLive", sender: nil)
        }
    }
    
    
    //MARK:- Nevigate
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoLive" {
            if let controller = segue.destination as? VideoViewController{
                UserDefaults.standard.removeObject(forKey: AppConstants.UserDefaults.streamID)
                UserDefaults.standard.synchronize()
                controller.clientMode = AntMediaClientMode.publish
                controller.streamName = Helper.currentTimeStamp
                UserDefaults.standard.set(Helper.currentTimeStamp, forKey: AppConstants.UserDefaults.streamName)
                controller.delegate = self
            }
        }
    }
    
    
    @IBAction func switchCameraAction(_ sender: Any) {
        self.view.switchCamera(switchCameraBtn)
    }
    
}

extension StreamViewController: VideoViewControllerDelegate{
    
    func streamDidFinish(streamName: String, streamTime : String) {
        self.vwShareStream.isHidden = false
        self.vwGoLive.isHidden = true
        self.showShareStream = true
        self.streamName = streamName
        self.lblLiveTime.text = streamTime
    }
    
    func dismissScreen() {
        self.dismiss(animated: true, completion: {
            self.delegateObj?.removeActiveStreams()
        })
    }
}

