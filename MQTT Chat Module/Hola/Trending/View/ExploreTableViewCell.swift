//
//  ExploreTableViewCell.swift
//  Starchat
//
//  Created by Rahul Sharma on 25/09/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

protocol ExploreTableViewCellDelegate {
    func movingToDetailsVc(index: Int,collectionIndex:Int)
}
class ExploreTableViewCell: UITableViewCell {

    
    /// All Outlets
    @IBOutlet weak var exploreTrendingCollectionView: UICollectionView!
    @IBOutlet weak var noOfHashTagsLabel: UILabel!
    @IBOutlet weak var hashTagNameLabel: UILabel!
    @IBOutlet weak var hashTagImageOutlet: UIImageView!

    
    /// variables and Declarations
    var ExploreTableViewCellDelegateObj:ExploreTableViewCellDelegate?
    var categoryModel: CategoryModel?
    var isLoadedOnce: Bool = false
    var largeCellIndex: Int = 1
    var selectedIndex: Int = 0
    var indexPathObj:Int?
    var modelDataObj:TrendingPostModel?
    var arrPosts : [SocialModel] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
     }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    /// Setting data in Cell
    ///
    /// - Parameter modelData: passing trending post model
    func setCellDataFrom(modelData: TrendingPostModel){
        modelDataObj = modelData
     self.hashTagNameLabel.text = modelData.hashTagName
        self.noOfHashTagsLabel.text = "\(modelData.totalPosts ?? 0)"+" "+"posts".localized
     self.hashTagImageOutlet.setImageOn(imageUrl: modelData.hashTagImage, defaultImage: #imageLiteral(resourceName: "HashTag_icon") )
    }
 }

//MARK:- collection view detasource and delegate
extension ExploreTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrPosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AppConstants.CellIds.trendingCollectionViewCellId, for: indexPath) as? TrendingCollectionViewCell else { fatalError()}
             let isPlaying = (indexPath.item % 8 == self.largeCellIndex) ? true : false
             cell.setCellDataFromExplore(modelData: arrPosts[indexPath.item], isPlaying: isPlaying)
        cell.treadingImageView.backgroundColor = .white
        return cell
    }
 
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ExploreTableViewCellDelegateObj?.movingToDetailsVc(index: indexPathObj ?? 0, collectionIndex: indexPath.item)
      }
   
    
     func reloadCollection(socialObject: TrendingPostModel){
        self.arrPosts = socialObject.posts
        self.exploreTrendingCollectionView.reloadData()
     }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.frame.size.width / 3
        let height = (width - 5) * 5 / 4
        /* Bug Name : Posts to be taller and not square in the explore page
         Fix Date : 10-Jul-2021
         Fixed By : Jayaram G
         Description Of Fix : Made taller for dubly
         */
        if AppConstants.appType == .picoadda {
            return CGSize(width: width - 3, height: width - 3)
        }else{
            return CGSize(width: width - 3, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == exploreTrendingCollectionView{
            return UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        }else{
            return UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        }
    }
}
