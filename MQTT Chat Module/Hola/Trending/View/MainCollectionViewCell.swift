//
//  MainCollectionViewCell.swift
//  Starchat
//
//  Created by Rahul Sharma on 03/09/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
import QuiltView
import DGElasticPullToRefresh
protocol mainCollectionViewCellDelegate:NSObject {
    func pushingToPostDetailsVc( indexItem:Int , modelData: [SocialModel])
    func updateHashTagViews(hashTagArray: [String])
    
}

class MainCollectionViewCell: UICollectionViewCell{
    
    @IBOutlet weak var trendingCollectionView: UICollectionView!
    
    @IBOutlet weak var noPostView: UIView!

    var trendingViewModel = TrendingViewModel()
    var largeCellIndex: Int = 1
    var canTrendingServiceCall: Bool = false
    var mainCollectionCellDelegateObj:mainCollectionViewCellDelegate?
    let bottomEdge: CGFloat = 20.0
    var categoryModel: CategoryModel?
    var socialModelObj:SocialModel?
    var scrollItem = IndexPath(row: 0, section: 0)
    
    
    
    override func awakeFromNib() {
//        let layout = self.trendingCollectionView?.collectionViewLayout as! QuiltView
//        layout.scrollDirection = UICollectionView.ScrollDirection.vertical
//        layout.itemBlockSize   = CGSize(
//            width: 200,
//            height: 200)
        setViewUI()
       // getCategoriesService()
       
        self.trendingCollectionView.layoutIfNeeded()
    }
    
    
    func setViewUI(){
        
        //Trending collection view layout
         self.trendingCollectionView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: bottomEdge, right: 0)
 
        // Initialize TrendingCollectionView for refresh
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        self.trendingCollectionView.tintColor = UIColor.white
        trendingCollectionView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            // Add your logic here
                self?.trendingViewModel.trendingOffset = -20
                self?.getTrendingService()
            }, loadingView: loadingView)
        trendingCollectionView.dg_setPullToRefreshFillColor(Helper.hexStringToUIColor(hex: AppColourStr.secondoryAPPColor))
        trendingCollectionView.dg_setPullToRefreshBackgroundColor(trendingCollectionView.backgroundColor!)
    }
    
    
    private func setNoPostView(){
        if self.trendingViewModel.trendingModelArray.count == 0{
            self.noPostView.isHidden = false
        }else{
            self.noPostView.isHidden = true
        }
    }
    
    
    func setUpSocialModelData(item:CategoryModel){
        self.categoryModel = item
        self.trendingCollectionView.reloadData()
        //        getTrendingService(categoryModel: item)
    }
    
    func scrollToIndex(index: IndexPath){
        scrollItem = index
    }

    
    //MARK:- Service call
    func getTrendingService(categoryModel: CategoryModel){
        Helper.showPI()
        trendingViewModel.getTrending(categorymodel: categoryModel) { (success, error, canServiceCall) in
            self.trendingCollectionView.dg_stopLoading()
            if success{
                DispatchQueue.main.async{
                    self.trendingCollectionView.reloadData()
                }
                //                print("Success ")
                   self.setNoPostView()
                self.mainCollectionCellDelegateObj?.updateHashTagViews(hashTagArray: self.trendingViewModel.hashTagArray)
             //   self.updateTrendingData()
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
        guard let modelData = self.categoryModel else {return}
        self.trendingViewModel.trendingOffset = -20
        self.getTrendingService(categoryModel: modelData)
    }
}



// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UICollectionViewDelegate
extension MainCollectionViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UICollectionViewDelegate{
 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.trendingViewModel.trendingModelArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AppConstants.CellIds.treadingCollectionCell, for: indexPath) as? TrendingCollectionViewCell
        //  let modelData = self.trendingViewModel.trendingModelArray[indexPath.item]
        //  let isPlaying = (indexPath.item % 8 == self.largeCellIndex) ? true : false
        let modelData = self.trendingViewModel.trendingModelArray[indexPath.item]
        let isPlaying = (indexPath.item % 8 == self.largeCellIndex) ? true : false
//        cell?.setCellDataFrom(modelData: modelData, isPlaying: isPlaying)
        
        cell?.layoutIfNeeded()
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //  let height = self.categoryCollectionView.frame.size.height - 14
        return CGSize(width: self.trendingCollectionView.frame.size.width / 3 - 2, height: self.trendingCollectionView.frame.size.width / 3 - 2)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        mainCollectionCellDelegateObj?.pushingToPostDetailsVc(indexItem: indexPath.item, modelData: self.trendingViewModel.trendingModelArray)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == self.trendingCollectionView{
            let indexPassed: Bool = indexPath.row >= self.trendingViewModel.trendingModelArray.count - 10
            if canTrendingServiceCall && indexPassed{
                canTrendingServiceCall = false
                guard let modelData = self.categoryModel else {return}
                self.getTrendingService(categoryModel: modelData)
                //                getTrendingService()
            }
        }
    }
    
}


//MARK:- Quilt view Delegate for trending collection view Flow Layout
extension MainCollectionViewCell : QuiltViewDelegate {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, blockSizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        if indexPath.item % 8 == self.largeCellIndex{
            return CGSize(width: 2, height: 2 )
        }else{
            //            print("small index path: \(indexPath.item)")
            return CGSize(width:1, height: 1 )
        }
    }
    
    
//    // Set the spacing between the cells
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetsForItemAtIndexPath indexPath: IndexPath) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
    }
 }
//extension MainCollectionViewCell:dataFromCollectionView{
//    func socialModelData(socialDat: SocialModel) {
//        self.trendingCollectionView.reloadData()
//    }
//
//    func dataFromTrendingVC(itemdta: CategoryModel) {
//         self.trendingCollectionView.reloadData()
//    }
//
//
//}





