//
//  EntertainmentPostsViewController.swift
//  PicoAdda
//
//  Created by 3Embed on 11/11/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class EntertainmentPostsViewController: UIViewController {
    
    @IBOutlet weak var postedByCollectionView: UICollectionView!
    @IBOutlet weak var noTagPostsView: UIView!
    @IBOutlet weak var noPostLbl: UILabel!
    
    
    var postedByViewModel = PostedByViewModel()
    var canServiceCall: Bool = true
    var noofPostsCount:Int?
    var isChannel: Bool = false
    var isCategory: Bool = false
    var isHashTag:Bool = false
    var entertainmentCategoryId: String = ""
    var navigationTitle:String = ""
    
    struct cellIdentifier {
        static let EntertainmentPostsCollectionCellId = "EntertainmentPostsCollectionCellId"
    }
    
    struct storyboardId {
        static let PostDetailsViewController = "PostDetailsViewController"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noPostLbl.text = "There is no posts available".localized + "."
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshPosts), name: NSNotification.Name(rawValue: "refreshingPosts"), object: nil)
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Utility.isDarkModeEnable(){
            UIApplication.shared.statusBarStyle = .lightContent
        }else{
            UIApplication.shared.statusBarStyle = .darkContent
        }
        self.navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: navigationTitle)
        self.getServiceResponse(categoryId: entertainmentCategoryId)
        
    }
    
    
    @objc func refreshPosts() {
        self.postedByViewModel.postedByArray.removeAll()
        self.postedByViewModel.offset = -20
        self.getServiceResponse(categoryId: entertainmentCategoryId)
    }
    
    
    
    //MARK:- Service call
    func getServiceResponse(categoryId:String){
        Helper.showPI()
        
        //        self.postedByViewModel.limit = 20
        
        postedByViewModel.getPostedByHashTagData(isHashTag: isHashTag, hashTag: categoryId, isChannel: isChannel) { (success, error,canServiceCall) in
            Helper.hidePI()
            if success{
                self.setNoPostView()
                self.noofPostsCount = self.postedByViewModel.postedByArray.count
                self.postedByCollectionView.reloadData()
                let userID = Utility.getUserid()
                //                if self.isChannel && userID != self.postedByViewModel.channelModel?.userId{
                //                    self.setChannelDetails()
                //                    self.showChannelUI()
                //                }
            }else if let error = error{
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
                self.postedByViewModel.offset = self.postedByViewModel.offset - 20
            }
            self.canServiceCall = canServiceCall
        }
    }
    
    
    func setNoPostView(){
        if self.postedByViewModel.postedByArray.count ==  0{
            self.noTagPostsView.isHidden = false
        }else {
            self.noTagPostsView.isHidden = true
        }
        
    }
    
}

extension EntertainmentPostsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.postedByViewModel.postedByArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier.EntertainmentPostsCollectionCellId, for: indexPath) as? EntertainmentPostsCollectionCell else { fatalError() }
        if let socialModelData = self.postedByViewModel.postedByArray[indexPath.row] as? SocialModel{
            cell.setCellDataFrom(modelData: socialModelData)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let indexPassed: Bool = indexPath.item >= self.postedByViewModel.postedByArray.count - 5
        if canServiceCall && indexPassed{
            canServiceCall = false
            getServiceResponse(categoryId: entertainmentCategoryId)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return Utility.makePostsSize(frame: self.view.frame)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2, left: 2, bottom: 0, right: 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        /*
         Bug Name:- The redirection on clicking on the posts in the categories at the top is incorrec
         Fix Date:- 08/06/21
         Fix By  :- Jayaram G
         Description of Fix:- Passing selected post index
         */
        
        if AppConstants.appType == .picoadda {
            Route.navigateToInstaDetailsVc(navigationController: self.navigationController, postsArray: self.postedByViewModel.postedByArray, needToCallApi: false, postId: nil,index: indexPath.item)
        }else{
            Route.navigateToAllPostsVertically(navigationController: self.navigationController,postsArray: self.postedByViewModel.postedByArray, selectedIndex: indexPath.item,isFromProfilePage:true,isCommingFromPostsList:true,delegate: self)
        }
    }
}

//MARK:- Post details view controller delegate
extension EntertainmentPostsViewController: PostDetailsViewControllerDelegate{
    func homeDataChanged() {
        self.getServiceResponse(categoryId: entertainmentCategoryId)
    }
}

