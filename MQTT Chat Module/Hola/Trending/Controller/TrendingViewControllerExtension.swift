
//
//  TrendingViewControllerExtension.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 27/04/20.
//  Copyright © 2020 Rahul Sharma. All rights reserved.
//

import Foundation
import UIKit
import QuiltView

// MARK: - UITableViewDelegate,UITableViewDataSource
extension TrendingViewController: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else {
            return self.trendingViewModel.trendingModelArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let exploreCategoryCell = tableView.dequeueReusableCell(withIdentifier: String(describing: ExploreCategoryTableViewCell.self), for: indexPath) as? ExploreCategoryTableViewCell else {fatalError()}
            exploreCategoryCell.categoryList = self.trendingViewModel.categoryModelArray
            exploreCategoryCell.delegate = self
            return exploreCategoryCell
        }else{
            guard let exploreTrendingCell = tableView.dequeueReusableCell(withIdentifier: String(describing: ExploreTableViewCell.self), for: indexPath) as? ExploreTableViewCell else {fatalError()}
            exploreTrendingCell.ExploreTableViewCellDelegateObj = self
            exploreTrendingCell.indexPathObj = indexPath.row
            exploreTrendingCell.setCellDataFrom(modelData: self.trendingViewModel.trendingModelArray[indexPath.row])
            exploreTrendingCell.reloadCollection(socialObject: self.trendingViewModel.trendingModelArray[indexPath.row])
            return exploreTrendingCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            
            /*Refactor Name :- change font size of category name and change size of category cell
              Refactor Date :- 22/03/2021
              Refactor By :- Nikunj C
              Description Of Refactor :- change height from 90 to dynamic hight  */
            
            return self.exploreTableViewOutlet.frame.size.width / 3 + 20
        }else {
            if self.trendingViewModel.trendingModelArray[indexPath.row].totalPosts == 0 {
                //                self.exploreTableViewOutlet.allowsSelection = false
                return 50
            }else {
                /* Bug Name : Posts to be taller and not square in the explore page
                 Fix Date : 10-Jul-2021
                 Fixed By : Jayaram G
                 Description Of Fix : Made taller for dubly
                 */
                if AppConstants.appType == .picoadda {
                    return 170
                }else{
                    let width = self.view.frame.size.width / 3
                    let height = (width - 5) * 5 / 4
                    return height + 70.0
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if AppConstants.appType == .dubly,let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus{
            presentWelcomeController()
        }else{
            if self.trendingViewModel.trendingModelArray[indexPath.row].totalPosts != 0 {
                let postedbyController = PostedByViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.postedBy) as PostedByViewController
                postedbyController.hashTagName = self.trendingViewModel.trendingModelArray[indexPath.row].hashTagName
                postedbyController.isHashTag = true
                postedbyController.noofPostsCount = self.trendingViewModel.trendingModelArray[indexPath.row].totalPosts ?? 0
                postedbyController.hashTagImageUrl = self.trendingViewModel.trendingModelArray[indexPath.row].hashTagImage
                self.navigationController?.pushViewController(postedbyController, animated: true)
        }
        
        }
        
    }
}

//MARK:- Quilt view Delegate for trending collection view Flow Layout
extension TrendingViewController : QuiltViewDelegate {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, blockSizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        if indexPath.item % 8 == self.largeCellIndex{
            return CGSize(width: 2, height: 2 )
        }else{
            return CGSize(width:1, height: 1 )
        }
    }
    
    // Set the spacing between the cells
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetsForItemAtIndexPath indexPath: IndexPath) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)   
    }
}


//MARK:- Text view delegate for related hashtags
extension TrendingViewController: UITextViewDelegate,ExploreTableViewCellDelegate{
    func movingToDetailsVc(index: Int,collectionIndex:Int) {
        if AppConstants.appType == .picoadda {
            guard let socialDetailsVC =  UIStoryboard.init(name: AppConstants.StoryBoardIds.instaHome, bundle: nil).instantiateViewController(withIdentifier: String(describing: SocialDetailsViewController.self)) as? SocialDetailsViewController else{return}
            socialDetailsVC.needToCallApi = false
            socialDetailsVC.isFromTrendingPage = true
            socialDetailsVC.scrollToSelectedIndex = collectionIndex
            socialDetailsVC.hashTag = self.trendingViewModel.trendingModelArray[index].hashTagName ?? ""
            navigationController?.pushViewController(socialDetailsVC, animated: true)
        }else{
//            if let status = Utility.getIsGuestUser() , !status {
//
//                 }else {
//                     presentWelcomeController()
//                 }
            Route.navigateToAllPostsVertically(navigationController: self.navigationController, postId:self.trendingViewModel.trendingModelArray[index].posts[collectionIndex].postId,postsArray: nil,hashTagName: self.trendingViewModel.trendingModelArray[index].hashTagName ?? "", isCommingFromChat:true,isFromProfilePage:true,isFromTrendingPage:true)

        }

    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool{
        print(URL.absoluteString)
        let postedbyController = PostedByViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.postedBy) as PostedByViewController
        postedbyController.hashTagName = URL.absoluteString
        postedbyController.isHashTag = true
        self.navigationController?.pushViewController(postedbyController, animated: true)
        return false
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let indexPassed: Bool = indexPath.item >= self.trendingViewModel.trendingModelArray.count - 2
        if canTrendingServiceCall && indexPassed{
            canTrendingServiceCall = false
            self.getTrendingPosts()
        }
    }
    
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

//MARK:- Post details view controller delegate
extension TrendingViewController: PostDetailsViewControllerDelegate{
    func deleteSocialPost(index: Int) {
         
    }
    
    func homeDataChanged() {
        self.getCategoriesService()
    }
}


// MARK: - ExploreCategoryTableViewCellDelegate
// MARK: - ExploreCategoryTableViewCellDelegate
extension TrendingViewController: ExploreCategoryTableViewCellDelegate{
    func paggingForCategoryServiceCall() {
        if self.canCategoryServiceCall {
            canCategoryServiceCall = false
            self.getCategoriesService()
        }
    }
    
    func didSelectCellAtIndex(index: Int) {
        if AppConstants.appType == .dubly,let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus{
            presentWelcomeController()
        }else{
            if self.trendingViewModel.categoryModelArray[index].categoryName ?? "" == "Star" {
                let storyboard = UIStoryboard(name: AppConstants.StoryBoardIds.Main, bundle: nil)
                guard let exploreStarPagesVc = storyboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.ExploreStarPagesViewControllerVcId) as? ExploreStarPagesViewController else{return}
                exploreStarPagesVc.hidesBottomBarWhenPushed = true
                exploreStarPagesVc.navigationItem.title = "Star Pages"
                self.navigationController?.pushViewController(exploreStarPagesVc, animated: true)
            }else if self.trendingViewModel.categoryModelArray[index].categoryName ?? "" == "Live" {
                let storyboard = UIStoryboard(name: AppConstants.StoryBoardIds.live, bundle: nil)
                guard let onGoingStreamVC = storyboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.OnGoingStreamVC) as? OnGoingStreamVC else{return}
                self.navigationController?.pushViewController(onGoingStreamVC, animated: true)
            }else {
                let storyboard = UIStoryboard(name: AppConstants.StoryBoardIds.Main, bundle: nil)
                guard let entertainVc = storyboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.EntertainmentPostsViewControllerVcId) as? EntertainmentPostsViewController else{return}
                entertainVc.entertainmentCategoryId = self.trendingViewModel.categoryModelArray[index].categoryId ?? ""
                entertainVc.navigationTitle = self.trendingViewModel.categoryModelArray[index].categoryName ?? ""
                entertainVc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(entertainVc,animated: true)
            }
        }
     
    }
}


