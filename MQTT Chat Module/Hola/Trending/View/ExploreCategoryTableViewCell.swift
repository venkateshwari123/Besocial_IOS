
//
//  ExploreCategoryTableViewCell.swift
//  Starchat
//
//  Created by Rahul Sharma on 25/09/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

protocol ExploreCategoryTableViewCellDelegate: class {
    func didSelectCellAtIndex(index: Int)
    func paggingForCategoryServiceCall()
    
}

class ExploreCategoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    var categoryList = [CategoryModel](){
        didSet{
            self.categoryCollectionView.reloadData()
        }
    }
    
    weak var delegate: ExploreCategoryTableViewCellDelegate?
    var selectedIndex: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

//MARK:- collection view detasource and delegate
extension ExploreCategoryTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categoryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AppConstants.CellIds.categoryCollectionCell, for: indexPath) as? CategoryCollectionViewCell else { fatalError()}
        let modelData = self.categoryList[indexPath.item]
//        let isSelected: Bool = (selectedIndex == indexPath.row)
        cell.setModelDataInCell(data: modelData, isSelected: true)
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.didSelectCellAtIndex(index: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let indexPassed: Bool = indexPath.item >= self.categoryList.count - 2
        if indexPassed{
            delegate?.paggingForCategoryServiceCall()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        /*Refactor Name :- change font size of category name and change size of category cell
          Refactor Date :- 22/03/2021
          Refactor By :- Nikunj C
          Description Of Refactor :- make cell square from rectangle  */
        
        let height = self.categoryCollectionView.frame.size.height - 14
        return CGSize(width: self.categoryCollectionView.frame.size.width / 3 + 10, height: self.categoryCollectionView.frame.size.width / 3 + 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
    }
}
