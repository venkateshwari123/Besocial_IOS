//
//  AudioListViewController.swift
//  dub.ly
//
//  Created by DINESH GUPTHA on 12/18/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Locksmith
import AVKit
import Alamofire

protocol AudioSelectedDelegate {
    func selectedAudio(selectedAudio:Audio)
}

class AudioListViewController: BaseViewController {
    
    
    @IBOutlet weak var hotSongsBtn: UIButton!
    @IBOutlet weak var myFaviourtesBtn: UIButton!
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var audioListTableview: UITableView!
    
    var delegate:AudioSelectedDelegate?
    var audioPlayer:AVAudioPlayer?
    
    lazy var audioList = [Audio]()
    lazy var allFavouriteAudios = [Audio]()
    lazy var allAudioCategories = [DubAudioCategory]()
    var audioCategory:DubAudioCategory?
    
    var isAudioSelected:Bool = false
    lazy var isAudioListForCategory = false
    lazy var selectedAudioID = ""
    var selectedAudioName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        hotSongsBtn.setTitle("HOT SONGS".localized, for: .normal)
        myFaviourtesBtn.setTitle("MY FAVOURITES".localized, for: .normal)
        fetchDetails()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
    func fetchDetails() {
        if isAudioListForCategory {
            updateUIForCategoriesList()
        } else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "back_arrow"), style: .plain, target: self, action: #selector(dismissAction))
            self.title = "Add a sound".localized
            self.navigationController?.navigationBar.titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary([NSAttributedString.Key.font.rawValue: Utility.Font.Bold.ofSize(17)])
            self.navigationController?.navigationBar.tintColor = .black
            
            //requesting API to fetch all the hot songs List.
            getAudioList()
            
            //requesting API to fetch all the categories.
            getAudioCategoryList()
            
            //requesting API to fetch all the faviuorite songs list..
            getFavouriteAudioList()
        }
    }
    
    @objc func dismissAction() {
        self.dismiss(animated: true, completion: {
            if !self.isAudioSelected {
                print(" No Audio ")
                if self.selectedAudioName == "" {
                    Helper.showAlertViewOnWindow("", message: "Selection of dubbing sound cancelled".localized)
                }
            }
        })
    }
    
    func updateUIForCategoriesList() {
        
        //hiding categories LIST UI.
        var frame = categoryView.frame
        frame.size.height = 0
        categoryView.frame = frame
        
        self.navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: audioCategory?.categoryName ?? "")
        self.hotSongsBtn.isHidden = true
        self.myFaviourtesBtn.isHidden = true
        
        //requesting API to fetch all the audios in patciular category.
        getAudioListByCategory()
    }
    
    func getAudioListByCategory() {
        
        //fetching api response and converting into array of category models.
        
        
        Helper.showPI()
        
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode()]
        let apiCall = RxAlmofireClass()
        let pathName = "musicList" + "?categoryId=\(audioCategory!.categoryId)"
        apiCall.newtworkRequestAPIcall(serviceName: pathName, requestType: .get, parameters: nil ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getTrendingResponse.rawValue)
        apiCall.subject_response.subscribe(onNext: {dict in
            Helper.hidePI()
            guard let dataArray = dict["data"] else {return}
            if let audioS = dataArray as? [Any] {
                if audioS.count == 0{
                    if let image = UIImage(named: "NoMedia") {
                        self.setTableViewOrCollectionViewBackground(tableView: self.audioListTableview, collectionView: nil, image: image, labelText: "", labelWithImage: false, yPosition: self.view.center.y - 30)
                    }
                }
                for singleAudio in audioS.enumerated() {
                    if let audiDetails = singleAudio.element as? [String:Any] {
                        self.audioList.append(Audio.init(details:audiDetails))
                    }
                }
            }
            
            self.audioListTableview.reloadData()
        }, onError: {error in
            Helper.hidePI()
        })
    }
    
    
    @IBAction func faviouriteButtonAction(_ sender: Any) {
        
        //finding the respective audio index and updating the UI.
        //CALLING favioutrite API based on condition.
        //updating locally for favourites audios.
        
        
        //finding the respective audio index and updating the UI.
        let selectedButton = sender as! UIButton
        var selectedAudio:Audio
        if self.hotSongsBtn.isSelected {
            selectedAudio = self.audioList[selectedButton.tag]
            selectedAudio.isFavourite = !selectedAudio.isFavourite
            self.audioList[selectedButton.tag] = selectedAudio
        } else {
            selectedAudio = self.allFavouriteAudios[selectedButton.tag]
            selectedAudio.isFavourite = !selectedAudio.isFavourite
            self.allFavouriteAudios[selectedButton.tag] = selectedAudio
        }
        self
            .audioListTableview.reloadData()
        
        
        //CALLING favioutrite API based on condition.
        updateFavAudioAPI(audioId:selectedAudio.id, isFav:selectedAudio.isFavourite)
        
        
        //updating locally for favourites audios.
        if(self.hotSongsBtn.isSelected){
            updateFavList(audio:selectedAudio, isFav:selectedAudio.isFavourite)
        } else {
            updateAllAudioList(audio:selectedAudio, isFav:selectedAudio.isFavourite)
        }
    }
    
    func updateAllAudioList(audio:Audio,isFav:Bool) {
        
        //finding index from all audios list(HOT SONGS) and updating fav status locally.
        for eachAudio in self.audioList.enumerated() {
            if eachAudio.element.id == audio.id {
                self.audioList[eachAudio.offset].isFavourite = audio.isFavourite
            }
        }
    }
    
    func updateFavList(audio:Audio,isFav:Bool) {
        
        //finding index from faviourites  audios list(faviourites SONGS) and updating fav status locally.
        
        if(isFav) {
            self.allFavouriteAudios = [audio] + self.allFavouriteAudios
        } else {
            //remove if exists.
            for eachAudio in self.allFavouriteAudios.enumerated() {
                if eachAudio.element.id == audio.id {
                    self.allFavouriteAudios.remove(at:eachAudio.offset)
                }
            }
        }
    }
    
    
    
    @IBAction func hotSoongsBtnAction(_ sender: Any) {
        
        
        // stop playing audio and updating the button UI.
        self.audioPlayer?.pause()
        self.hotSongsBtn.isSelected = true
        self.myFaviourtesBtn.isSelected = false
        self.audioListTableview.reloadData()
    }
    
    @IBAction func myFavBtnAction(_ sender: Any) {
        // stop playing audio and updating the button UI.
        self.audioPlayer?.pause()
        self.hotSongsBtn.isSelected = false
        self.myFaviourtesBtn.isSelected = true
        self.audioListTableview.reloadData()
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        if isAudioListForCategory {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: {
                if !self.isAudioSelected {
                    print(" No Audio ")
                    if self.selectedAudioName == "" {
                        Helper.showAlertViewOnWindow("", message: "Selection of dubbing sound cancelled".localized)
                    }
                }
            })
        }
    }
    
    @IBAction func dubBtnAction(_ sender: Any) {
        let selectedButton = sender as! UIButton
        
        //saving the auido locally and dismissing the UI.
        //if it is already saved then not savinag again.
        self.isAudioSelected = true
        if self.hotSongsBtn.isSelected {
            saveAudioAndDismiss(selectedAudio:self.audioList[selectedButton.tag])
        } else {
            saveAudioAndDismiss(selectedAudio:self.allFavouriteAudios[selectedButton.tag])
        }
    }
    
    func playSelectedSound(selectedAudio:Audio) {
        
        if let audioUrl = URL(string: selectedAudio.url) {
            
            // then lets create your document folder url
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            print(destinationUrl)
            
            // to check if it exists before downloading it
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                print("The file already exists at path")
                
                DispatchQueue.main.async {
                    do {
                        /*
                         Bug Name:- Audio not playing on speaker
                         Fix Date:- 02/06/21
                         Fix By  :- jayaram G
                         Description of Fix:- Added defaultToSpeaker option
                         */
                        try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.allowBluetooth,.allowBluetoothA2DP,.allowBluetoothA2DP,.defaultToSpeaker])
                        
                        try AVAudioSession.sharedInstance().setActive(true)
                        
                        self.audioPlayer = try AVAudioPlayer(contentsOf: destinationUrl)
                        self.audioPlayer?.enableRate = true
                        self.audioPlayer?.prepareToPlay()
                        self.audioPlayer?.numberOfLoops = -1
                        self.audioPlayer?.play()
                        self.audioListTableview.reloadData()
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
            } else {
                
                Helper.showPI()
                // if the file doesn't exist
                // you can use NSURLSession.sharedSession to download the data asynchronously
                URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) -> Void in
                    guard let location = location, error == nil else {
                        DispatchQueue.main.async {
                            Helper.hidePI()
                        }
                        return }
                    do {
                        // after downloading your file you need to move it to your destination url
                        try FileManager.default.moveItem(at: location, to: destinationUrl)
                        print("File moved to documents folder")
                        DispatchQueue.main.async {
                            Helper.hidePI()
                            self.playSelectedSound(selectedAudio:selectedAudio)
                        }
                    } catch let error as NSError {
                        DispatchQueue.main.async {
                            Helper.hidePI()
                        }
                        print(error.localizedDescription)
                    }
                }).resume()
            }
        }
    }
    
    func getAudioList() {
        Helper.showPI()
        let params = [String : Any]()
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode()]
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: "musicList", requestType: .get, parameters: nil ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getTrendingResponse.rawValue)
        apiCall.subject_response.subscribe(onNext: {dict in
            
            Helper.hidePI()
            guard let dataArray = dict["data"] else {return}
            
            if let audioS = dataArray as? [Any] {
                for singleAudio in audioS.enumerated() {
                    if let audiDetails = singleAudio.element as? [String:Any] {
                        self.audioList.append(Audio.init(details:audiDetails))
                    }
                }
            }
            self.audioListTableview.reloadData()
        }, onError: {error in
            Helper.hidePI()
        })
    }
    
    func updateFavAudioAPI(audioId:String,isFav:Bool) {
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode()]
        let params = ["musicId":audioId,"isFavourite":isFav] as [String : Any]
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: "favouriteMusic", requestType: .post, parameters: params ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getTrendingResponse.rawValue)
        apiCall.subject_response.subscribe(onNext: {dict in
            
        }, onError: {error in
            
        })
        apiCall.disposebag
    }
    
    func getFavouriteAudioList() {
        let params = [String : Any]()
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode()]
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: "favouriteMusic", requestType: .get, parameters: nil  ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getTrendingResponse.rawValue)
        apiCall.subject_response.subscribe(onNext: {dict in
            guard let dataArray = dict["data"] else {return}
            
            if let audioS = dataArray as? [Any] {
                for singleAudio in audioS.enumerated() {
                    if let audiDetails = singleAudio.element as? [String:Any] {
                        self.allFavouriteAudios.append(Audio.init(details:audiDetails))
                    }
                }
            }
            self.audioListTableview.reloadData()
        }, onError: {error in
            
        })
    }
    
    func getAudioCategoryList() {
        let params = [String : Any]()
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode()]
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: "musicCategory", requestType: .get, parameters: nil  ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getTrendingResponse.rawValue)
        apiCall.subject_response.subscribe(onNext: {dict in
            guard let dataArray = dict["data"] else {return}
            
            if let audioS = dataArray as? [Any] {
                for singleAudio in audioS.enumerated() {
                    if let audiDetails = singleAudio.element as? [String:Any] {
                        self.allAudioCategories.append(DubAudioCategory.init(details:audiDetails))
                    }
                }
            }
            
            if self.allAudioCategories.count > 0 {
                var frame = self.categoryView.frame
                var totalWidth = self.view.frame.size.width - 20
                totalWidth = totalWidth/4
                totalWidth = totalWidth+45+totalWidth
                frame.size.height = totalWidth
                self.categoryView.frame = frame
            }
            self.categoryCollectionView.reloadData()
            self.audioListTableview.reloadData()
        }, onError: {error in
        })
    }
    
    @IBAction func playButtonAction(_ sender: Any) {
        
    }
}


extension Date {
    var millisecondsSince1970:String {
        return String((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
}


//Milliseconds to date
extension Double {
    func dateFromMilliseconds() -> Date {
        return Date(timeIntervalSince1970: TimeInterval(self)/1000)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
    return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}
