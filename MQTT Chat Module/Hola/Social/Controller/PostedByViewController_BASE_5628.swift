//
//  PostedByViewController.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 29/08/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher

class PostedByViewController: UIViewController {

   
    @IBOutlet weak var navigationTitleLable: UILabel!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var channelImageView: UIImageView!
    @IBOutlet weak var subscribeCountLabel: UILabel!
    @IBOutlet weak var subscribeButtonOutlet: UIButton!
    @IBOutlet weak var channelViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var channelView: UIView!
   
   
    @IBOutlet weak var postedByCollectionView: UICollectionView!
    
    var socialModelData: SocialModel?
   
    @IBOutlet weak var noPostView: UIView!
    
    var isChannel: Bool = false
    var isCategory: Bool = false
    var isHashTag:Bool = false
    var categoryName: String?
    var channelName: String?
    var hashTagName: String?
    var postedByViewModel = PostedByViewModel()
    var canServiceCall: Bool = false
    var noofPostsCount:Int?
    var isPresented: Bool = false
    var hashTagImageUrl:String?
    var safeAreaHeight: CGFloat = 64
    var socialModelArray = [SocialModel]()
    var isFromProfileBtn:Bool = false
 
    
    struct cellIdentifier {
        static let postedByCoollectionCell = "postedByCollectionCell"
    }
    
    struct storyboardId {
        static let PostDetailsViewController = "PostDetailsViewController"
    }
    
    //MARK:- View life cycle
    override func viewDidLoad(){
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        self.getServiceResponse()
        viewSetUp()
    }

    override func viewWillAppear(_ animated: Bool) {
        
        if self.isChannel  || self.isCategory{
            self.navigationView.isHidden = true
            self.navigationController?.isNavigationBarHidden = false
        }else {
            self.navigationView.isHidden = false
            self.navigationController?.isNavigationBarHidden = true
        }
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
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    /// To set title and UI of view
    func viewSetUp(){
//        self.channelViewHeightConstraint.constant = 0.0;
        
        // self.hashTagTextLabel.text = hashTagName
//        if let postsCount = noofPostsCount as? Int {
//            self.noOfPosts.text = "\(postsCount) Public Posts"
//        }
//        self.hashTagImageView.makeImageCornerRadius(65)
        
//        self.hashTagBackView.makeCornerRadious(readious: self.hashTagBackView.frame.size.width / 2)
//        let leftColor = Helper.hexStringToUIColor(hex: AppColourStr.gradientLeftColor)
//        let rightColor = Helper.hexStringToUIColor(hex: AppColourStr.gradientRightColor)
//        self.hashTagBackView.makeLeftToRightGeadient(leftColor: leftColor, rightColor: rightColor)
//
//        self.hashTagImageView.image = #imageLiteral(resourceName: "HashTag_icon")
//        self.hashTagCoverImageView.image = #imageLiteral(resourceName: "HashTag_icon")
        self.channelView.isHidden = true
      //  self.postsVColletionTopLayOutConstraint.constant = 33
        
      //  self.hashTagView.isHidden = false
       // self.collectionViewTopConstraint.constant = 229
        
        
        
        
        
//        self.navigationController?.navigationBar.isTranslucent = true
        self.channelViewHeightConstraint.constant = 0
        self.subscribeButtonOutlet.isHidden = true
        self.view.layoutIfNeeded()
        if isChannel, let channelName = self.channelName{
            self.title = channelName
            self.subscribeButtonOutlet.makeBorderWidth(width: 1.0, color: Helper.hexStringToUIColor(hex: AppColourStr.appColor))
        }else if isCategory{
            self.title = categoryName
        }
    }
    
    /// Set data in channles elements
    func setChannelDetails(){
        self.subscribeButtonOutlet.isHidden = false
        if let channelData = self.postedByViewModel.channelModel{
            self.subscribeCountLabel.text = "\(channelData.sunscriber) Subscribers"
            self.channelImageView.setImageOn(imageUrl: channelData.channelImageUrl, defaultImage: #imageLiteral(resourceName: "defaultImage"))
            if channelData.isSubscribed == 0{
                self.subscribeButtonOutlet.backgroundColor = UIColor.white
                self.subscribeButtonOutlet.isSelected = false
                var subscribetext: String = "Subscribe"
                if channelData.privicy == 1{
                    subscribetext = "Request"
                }
                self.subscribeButtonOutlet.setTitle(subscribetext, for: .normal)
            }else{
                self.subscribeButtonOutlet.backgroundColor = Helper.hexStringToUIColor(hex: AppColourStr.appColor)
                self.subscribeButtonOutlet.isSelected = true
                var subscribetext: String = "Subscribed"
                if channelData.privicy == 1{
                    if channelData.isSubscribed == 1{
                        subscribetext = "Requested"
                    }else if channelData.isSubscribed == 3{
                        subscribetext = "Rejected"
                    }
                }
                self.subscribeButtonOutlet.setTitle(subscribetext, for: .normal)
            }
        }
    }
    
    /// To show shannel UI
    func showChannelUI(){
        UIView.animate(withDuration: 0.4, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
          //  self.channelViewHeightConstraint.constant = 135.0;
            self.channelView.isHidden = false
//            self.postsVColletionTopLayOutConstraint.constant = 33
//            self.hashTagView.isHidden = true
          //  self.collectionViewTopConstraint.constant = 0
            let userID = Utility.getUserid()
            if self.isChannel && userID != self.postedByViewModel.channelModel?.userId{
                self.subscribeButtonOutlet.isHidden = false
            }else{
                self.subscribeButtonOutlet.isHidden = true
            }

 
            self.channelViewHeightConstraint.constant = 140
            self.view.updateConstraints()
            self.view.layoutIfNeeded()
            self.channelView.makeShadowEffect(color: UIColor.lightGray)
        }) { (finished) in
            
        }
    }
    
    private func setNoPostView(){
     //   self.noPostView.isHidden = (self.postedByViewModel.postedByArray.count == 0) ? false : true
    }
    
    //MARK:- Button action
    @IBAction func subscribeButtonAction(_ sender: Any) {
        if var channelData = self.postedByViewModel.channelModel, let id = channelData.channelId{
            if self.subscribeButtonOutlet.isSelected{
                channelData.isSubscribed = 0
            }else{
                channelData.isSubscribed = 1
            }
            subscribeServiceCall(subscribe:  !self.subscribeButtonOutlet.isSelected, channelId: id)
            self.postedByViewModel.channelModel = channelData
            setChannelDetails()
        }
    }
    
    
    @IBAction func backButtonAction(_ sender: Any) {
        if isPresented{
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
 
    //MARK:- Service call
    func getServiceResponse(){
        guard let tagName = self.hashTagName?.replace(target: "#", withString: "") else {return}
        Helper.showPI()
        postedByViewModel.getPostedByHashTagData(isHashTag: isHashTag, hashTag: tagName, isChannel: isChannel) { (success, error, canServiceCall) in
            Helper.hidePI()
            if success{
                self.setNoPostView()
                self.noofPostsCount = self.postedByViewModel.postedByArray.count
                  self.postedByCollectionView.reloadData()
                let userID = Utility.getUserid()
                if self.isChannel {
                    self.setChannelDetails()
                    self.showChannelUI()
                }
             }else if let error = error{
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error, message: error.localizedDescription)
                }
                self.postedByViewModel.offset = self.postedByViewModel.offset - 20
            }
            Helper.hidePI()
            self.canServiceCall = canServiceCall
        }
    }
    
    func subscribeServiceCall(subscribe: Bool, channelId: String){
        Helper.showPI()
        postedByViewModel.subscribeAndUnsubscribChannel(subscribe: subscribe, channelId: channelId) { [weak self] (success, error) in
            DispatchQueue.main.async{
                Helper.hidePI()
            }
            if !success{
                Helper.hidePI()
                guard let strongSelf = self else{return}
                if var channelData = strongSelf.postedByViewModel.channelModel{
                    if strongSelf.subscribeButtonOutlet.isSelected{
                        channelData.isSubscribed = 0
                    }else{
                        channelData.isSubscribed = 1
                    }
                    strongSelf.postedByViewModel.channelModel = channelData
                    strongSelf.setChannelDetails()
                }
            }
        }
     }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}

extension PostedByViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.postedByViewModel.postedByArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier.postedByCoollectionCell, for: indexPath) as? PostedByCollectionViewCell else { fatalError() }
        if let socialModelData = self.postedByViewModel.postedByArray[indexPath.row] as? SocialModel{
            /*
             Bug Name:- lock icon not appear on paid post
             Fix Date:- 27/03/21
             Fixed By:- Nikunj C
             Discription of Fix:- use function setCellDataFrom
             */
            
//            cell.setPostedByData(modelData: socialModelData)
            cell.setCellDataFrom(modelData: socialModelData)

        }
        
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
        return CGSize(width: width - 2, height: width - 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2, left: 2, bottom: 0, right: 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        /* Bug Name :  Eplore : select category tap video not scrolling
                             Fix Date : 12-apr-2021
                             Fixed By : Vishal D
                             Description Of Fix : passed missing arguments
                           */
        if isFromProfileBtn {
            Route.navigateToInstaDetailsVc(navigationController: self.navigationController, postsArray: self.socialModelArray , needToCallApi: true, postId: self.socialModelArray[indexPath.row].postId,index: indexPath.row)
        }else {
            /*
             Bug Name:- post show two time
             Fix Date:- 22/04/21
             Fixed By:- Nikunj C
             Description of Fix:- change arguments
             */
            Route.navigateToInstaDetailsVc(navigationController: self.navigationController, postsArray: self.postedByViewModel.postedByArray,needToCallApi: false, postId: self.postedByViewModel.postedByArray[indexPath.row].postId,index: indexPath.row)
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if scrollView == self.postedByCollectionView{
            let movedOffset = scrollView.contentOffset.y
            //            print("scroll view: \(movedOffset)")
            //Stop scrolling in table view reachs it's top
            if scrollView.contentOffset.y <= -40 {
                scrollView.contentOffset = CGPoint(x: 0, y: -40)
            }
            
            let pageWidth: CGFloat = 300
            let ratio = (movedOffset + safeAreaHeight - 50) / pageWidth
            //            print("ratio: \(ratio)")
            
            self.navigationView.backgroundColor = UIColor(white: 1, alpha: ratio)
            self.navigationTitleLable.textColor = UIColor.black.withAlphaComponent(ratio)
            if ratio > 0.2{
                self.navigationView.backgroundColor = UIColor(white: 1, alpha: 1)
                self.navigationTitleLable.text = self.hashTagName
                self.navigationTitleLable.isHidden = false
                //   self.navUserNameLabel.font = Utility.Font.Regular.ofSize(10)
//                for layer in self.navigationView.layer.sublayers! {
//                    if layer.name == Strings.maskLayer {
//                        layer.isHidden  = true
//                    }
//                }
                self.navigationTitleLable.textColor = UIColor.black
            }else{
//                self.navigationTitleLable.textColor = UIColor.clear
              //  changeNavItemColor(to: UIColor.white)
                self.navigationTitleLable.textColor = .black
                self.navigationTitleLable.isHidden = true
//                for layer in self.navigationView.layer.sublayers! {
//                    if layer.name == Strings.maskLayer {
//                        layer.isHidden  = false
//                    }
//                }
            }
            if ratio > 0.2{
              //  changeNavItemColor(to: UIColor.black)
                self.navigationTitleLable.textColor = .black
                self.navigationTitleLable.text = self.hashTagName

            }
        }
    
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header : ReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HastagReusableVIewId", for: indexPath) as! ReusableView
        header.hashTagTitleLabel.text = isCategory ? categoryName : hashTagName
        
        header.hashTagImage.setImageOn(imageUrl: self.hashTagImageUrl, defaultImage: #imageLiteral(resourceName: "HashTag_icon"))
        header.coverImageView.setImageOn(imageUrl: self.hashTagImageUrl, defaultImage: #imageLiteral(resourceName: "bannerImage"))

        if let postsCount = noofPostsCount {
            if self.postedByViewModel.postedByArray.count > 1 {
            header.hashTagViewsCount.text = "\(self.postedByViewModel.postedByArray.count) Posts"
            }else{
                header.hashTagViewsCount.text = "\(self.postedByViewModel.postedByArray.count) Post"
            }
            
        }
        return header
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        var size = CGSize.init()
        if self.isChannel  || self.isCategory{
            self.navigationView.isHidden = true
            return CGSize(width: view.frame.width, height: 0)
            
        }
        self.navigationView.isHidden = false
        return CGSize(width: view.frame.width, height: 180)
    }
    }
//    private func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UIView {
//        return hashTagView
//    }
    


class ReusableView: UICollectionReusableView {
    
    @IBOutlet weak var coverImageView: UIImageView!
    
    @IBOutlet weak var hashTagImageBackView: UIView!
    
    
    @IBOutlet weak var hashTagImage: UIImageView!
    
    @IBOutlet weak var hashTagTitleLabel: UILabel!
    
    @IBOutlet weak var hashTagViewsCount: UILabel!
    
    @IBOutlet weak var hashTagDescriptLabel: UILabel!
    
    override func awakeFromNib() {
        
        self.hashTagImage.makeImageCornerRadius(37.5)
                self.hashTagImageBackView.makeCornerRadious(readious: self.hashTagImageBackView.frame.size.width / 2)
                let leftColor = Helper.hexStringToUIColor(hex: AppColourStr.gradientLeftColor)
                let rightColor = Helper.hexStringToUIColor(hex: AppColourStr.gradientRightColor)
                self.hashTagImageBackView.makeLeftToRightGeadient(leftColor: leftColor, rightColor: rightColor)
        
//                self.hashTagImage.image = #imageLiteral(resourceName: "HashTag_icon")
//                 self.coverImageView.image = #imageLiteral(resourceName: "HashTag_icon")
        
    }
    
   
}

//MARK:- Post details view controller delegate
extension PostedByViewController: PostDetailsViewControllerDelegate{
    func homeDataChanged() {
        self.getServiceResponse()
    }
}

//MARK:- Post details view controller delegate
extension PostedByViewController: PostedByViewControllerDelegate{
    func updateDataFollow(following: Bool, index: Int) {
         for (indexobj,data) in self.postedByViewModel.postedByArray.enumerated() {
            if data.userId == self.postedByViewModel.postedByArray[index].userId {
                self.postedByViewModel.postedByArray[indexobj].isFollowing = following
            }
        }
    }
    
    
}


