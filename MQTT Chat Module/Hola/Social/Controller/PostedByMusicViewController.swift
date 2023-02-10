//
//  PostedByMusicViewController.swift
//  dub.ly
//
//  Created by 3Embed Software Tech Pvt Ltd on 19/11/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit


class PostedByMusicViewController: UIViewController {

    @IBOutlet weak var musicImageView: UIImageView!
    @IBOutlet weak var numberOfVideosLabel: UILabel!
    @IBOutlet weak var musicNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UIButton!
    @IBOutlet weak var postButtonOutlet: UIButton!
    @IBOutlet weak var favouritButtonOutlet: UIButton!
    @IBOutlet weak var musicDetailsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var musicCollectionView: UICollectionView!
    
    @IBOutlet weak var NoPostView: UIView!
    
//    var musicData: MediaModel?
    var postedByViewModel = PostedByViewModel()
    
    var canServiceCall: Bool = false
    

    
    struct cellIdentifier {
        static let postedByCoollectionCell = "postedByCollectionCell"
    }
    
    //MARK:- View life cycel
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.musicImageView.makeCornerRadious(readious: musicImageView.frame.size.width / 2)
        self.postButtonOutlet.makeCornerRadious(readious: 7)
        self.postButtonOutlet.layer.borderWidth = 1.4
        self.postButtonOutlet.layer.borderColor = Helper.hexStringToUIColor(hex: "#B33CF9").cgColor
        self.navigationController?.navigationBar.layer.zPosition = 0
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "RobotoCondensed-Bold", size: 18)!]
        self.setMusicDetailsViewData()
        self.getServiceResponse()
       // self.addObserVerForCamera()
        self.musicCollectionView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 80.0, right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Utility.isDarkModeEnable(){
            UIApplication.shared.statusBarStyle = .lightContent
        }else{
            UIApplication.shared.statusBarStyle = .darkContent
        }
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        /*
         Bug Name:- toast not appear sometime
         Fix Date:- 16/04/21
         Fix By  :- Nikunj C
         Description of Fix:- refactor extra code
         */
        Helper.checkConnectionAvaibility(view: self.view)
        
    }
    
    /// To show no post view if there is no post for this music
    private func setNoPostViewUI(){
        self.NoPostView.isHidden = (self.postedByViewModel.postedByArray.count == 0) ? false : true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setMusicDetailsViewData(){
        if let modelData = postedByViewModel.mediaModel{
            let image = UIImage(named: "music-symbol")!
            self.musicImageView.setImageOn(imageUrl: modelData.imageUrl, defaultImage: image)
            if let name = modelData.name as? String{
                let height = name.height(withConstrainedWidth: self.musicNameLabel.frame.size.width, font: self.musicNameLabel.font)
                if height > 17{
                    self.musicDetailsHeightConstraint.constant = 146.0 + height
                }
            }
            self.musicNameLabel.text = modelData.name
            self.numberOfVideosLabel.text = "\(modelData.totalVideos) Videos"
            self.artistNameLabel.setTitle(modelData.artist, for: UIControl.State.normal)
            if modelData.isFavourite{
                self.favouritButtonOutlet.isSelected = true
            }else{
                self.favouritButtonOutlet.isSelected = false
            }
        }
    }
    
    //MARK:- Button Action
    @IBAction func favouritButtonAction(_ sender: Any) {
        self.favouritButtonOutlet.isSelected = !self.favouritButtonOutlet.isSelected
        postedByViewModel.makeFavouriteMusic(isSelected: self.favouritButtonOutlet.isSelected)
    }
    
    
    @IBAction func postButtonAction(_ sender: Any) {
        
        guard let mediaModel = postedByViewModel.mediaModel else{return}
        let audioDownload = AudioDownloadHelper()
        guard let path = mediaModel.path else{return}
        audioDownload.downloadAudioFile(audioUrl: path) { (success, error) in
            if success{
                let audio = Audio(mediaModel: mediaModel)
                Route.navigateToCamera(navigationController:self.navigationController,isFromPostedByMusicScreen : true, selectedAudio: audio)
            }else{
                Helper.showAlertViewOnWindow(Strings.error.localized, message: error)
            }
        }
    }
    
    
    //MARK:- Service call
    func getServiceResponse(){
        
        Helper.showPI()
        postedByViewModel.getPostedByMusic() { (success, error, canServiceCall) in
            Helper.hidePI()
            if success{
                self.setNoPostViewUI()
                self.musicCollectionView.reloadData()
                DispatchQueue.main.async {
                    self.setMusicDetailsViewData()
                }
                
            }else if let error = error{
                Helper.hidePI()
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
                self.postedByViewModel.offset = self.postedByViewModel.offset - 20
            }
            self.canServiceCall = canServiceCall
        }
    }
}

extension PostedByMusicViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.postedByViewModel.postedByArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier.postedByCoollectionCell, for: indexPath) as? PostedByCollectionViewCell else { fatalError() }
        cell.setPostedByData(modelData: self.postedByViewModel.postedByArray[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let indexPassed: Bool = indexPath.item >= self.postedByViewModel.postedByArray.count - 5
        if canServiceCall && indexPassed{
            canServiceCall = false
            getServiceResponse()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.size.width / 3
        let height = (width - 5) * 5 / 4
        return CGSize(width: width - 5, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2, left: 2, bottom: 0, right: 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         Route.navigateToAllPostsVertically(navigationController: self.navigationController,postsArray: self.postedByViewModel.postedByArray, selectedIndex: indexPath.item,isFromProfilePage:true,isCommingFromPostsList:true,delegate: self)
 
    }
}

//MARK:- Post details view controller delegate
extension PostedByMusicViewController: PostDetailsViewControllerDelegate{
    func homeDataChanged() {
        self.getServiceResponse()
    }
}
