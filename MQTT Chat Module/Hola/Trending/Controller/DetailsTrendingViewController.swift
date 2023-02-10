//
//  DetailsTrendingViewController.swift
//  Starchat
//
//  Created by Rahul Sharma on 19/09/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
import QuiltView
import DGElasticPullToRefresh
class DetailsTrendingViewController: UIViewController {
    
    
    var navigationTitle:String?
    var trendingViewModel = TrendingViewModel()
    var canTrendingServiceCall: Bool = false
    var categoryModelObj: CategoryModel?
    var largeCellIndex: Int = 1
    
    
    @IBOutlet weak var detailsTredingCollectionView: UICollectionView!
    @IBOutlet weak var noActivityView: UIView!
    @IBOutlet weak var noTrendingPostLbl: UILabel!
    
    struct CellIds {
        static let detailsTrendingCollectionViewCell = "DetailsTrendingCollectionViewCell"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Trending collection view layout
        setUpUI()
        
        guard let modelData = self.categoryModelObj else {return}
        getTrendingService(categoryModel: modelData)
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
        self.navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: self.navigationTitle ?? "")
    }
    
    
    
    func setUpUI() {
        
        let layout = self.detailsTredingCollectionView?.collectionViewLayout as? QuiltView
        layout?.scrollDirection = UICollectionView.ScrollDirection.vertical
        layout?.itemBlockSize   = CGSize(
            width: self.view.frame.size.width / 3,
            height: self.view.frame.size.width / 3
        )
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()

        noTrendingPostLbl.text = "There is no trending post".localized + "."
        detailsTredingCollectionView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            // Add your logic here
            //            self?.trendingViewModel.trendingOffset = -20
            self?.getTrendingService()
            self?.detailsTredingCollectionView.tintColor = UIColor.white
            }, loadingView: loadingView)
        detailsTredingCollectionView.dg_setPullToRefreshFillColor(Helper.hexStringToUIColor(hex: AppColourStr.secondoryAPPColor))
        detailsTredingCollectionView.dg_setPullToRefreshBackgroundColor(detailsTredingCollectionView.backgroundColor!)
    }
    
    func getTrendingService(categoryModel: CategoryModel){
        Helper.showPI()
        trendingViewModel.getTrending(categorymodel: categoryModel) { (success, error, canServiceCall) in
            self.detailsTredingCollectionView.dg_stopLoading()
            if success{
                //                print("Success ")
                self.setNoPostView()
                self.detailsTredingCollectionView.reloadData()
            }else if let error = error{
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
                self.trendingViewModel.trendingOffset = self.trendingViewModel.trendingOffset - 20
            }
            self.canTrendingServiceCall = canServiceCall
        }
    }
    
    func getTrendingService(){
        guard let modelData = self.categoryModelObj else {return}
        self.trendingViewModel.trendingOffset = -20
        self.getTrendingService(categoryModel: modelData)
    }
    
    private func setNoPostView(){
        if self.trendingViewModel.trendingModelArray.count == 0{
            self.noActivityView.isHidden = false
        }else{
            self.noActivityView.isHidden = true
        }
        
    }
}

// MARK: - UICollectionViewDelegate,UICollectionViewDataSource
extension DetailsTrendingViewController: UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.trendingViewModel.trendingModelArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIds.detailsTrendingCollectionViewCell, for: indexPath) as? DetailsTrendingCollectionViewCell else { fatalError()}
        let modelData = self.trendingViewModel.trendingModelArray[indexPath.item]
        let isPlaying = (indexPath.item % 8 == self.largeCellIndex) ? true : false
//        cell.setCellDataFrom(modelData: modelData, isPlaying: isPlaying)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return Utility.makePostsSize(frame: self.view.frame)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
    }
}

//MARK:- Quilt view Delegate for trending collection view Flow Layout
extension DetailsTrendingViewController : QuiltViewDelegate {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, blockSizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        if indexPath.item % 8 == self.largeCellIndex{
            return CGSize(width: 2, height: 2 )
        }else{
            //            print("small index path: \(indexPath.item)")
            return CGSize(width:1, height: 1 )
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let postDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.PostDetailsViewController) as? PostDetailsViewController else{return}
//        postDetailsVC.selectedIndex = indexPath.item
//        postDetailsVC.delegate = self
////        postDetailsVC.postDetailsViewModel.socialModelArray = self.trendingViewModel.trendingModelArray
//        postDetailsVC.isCommingFromPostsList = false
//        self.navigationController?.pushViewController(postDetailsVC, animated: true)
        
        if AppConstants.appType == .picoadda {
            Route.navigateToInstaDetailsVc(navigationController: self.navigationController, postsArray: nil, needToCallApi: false, postId: nil)
        }else{
            Route.navigateToAllPostsVertically(navigationController: self.navigationController, selectedIndex: indexPath.item,delegate: self)
        }
    }
    
    // Set the spacing between the cells
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetsForItemAtIndexPath indexPath: IndexPath) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
    }
}

//MARK:- Post details view controller delegate
extension DetailsTrendingViewController: PostDetailsViewControllerDelegate{
    func homeDataChanged() {
        self.getTrendingService()
    }
}
