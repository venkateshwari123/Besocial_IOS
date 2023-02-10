//
//  CategoryCollectionViewCell.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 06/09/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
 class CategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.categoryNameLabel.makeShadowEffect(color: .lightGray)
        self.makeCornerRadious(readious: 8.0)
    }
     
    func setModelDataInCell(data: CategoryModel, isSelected: Bool){
        self.categoryNameLabel.text = data.categoryName
//        print("is selected : \(isSelected)")
//        self.setBottomViewInCell(isSelected: isSelected)
        self.categoryImageView.setImageOn(imageUrl: data.categoryActiveIconUrl, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
    }
    
//    func setBottomViewInCell(isSelected: Bool){
//        if isSelected{
//            var width = self.categoryNameLabel.intrinsicContentSize.width
//            if width > (self.frame.size.width - 15){
//                width = self.frame.size.width - 15
//            }
//            self.bottomView.makeCornerRadious(readious: 1.0)
//            self.bottomView.isHidden = false
//            self.bottomViewWidthConstraint.constant = 0.0
//            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
//                self.bottomViewWidthConstraint.constant = width
//                self.heightConstraintObj.constant = 2
//                self.layoutIfNeeded()
//            }, completion: nil)
//        }else{
//            self.bottomView.isHidden = true
//            self.bottomViewWidthConstraint.constant = 0.0
//            self.heightConstraintObj.constant = 0
//            self.layoutIfNeeded()
//        }
//    }
}
