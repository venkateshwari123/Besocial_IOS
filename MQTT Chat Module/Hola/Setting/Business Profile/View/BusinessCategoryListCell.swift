//
//  BusinessCategoryListCell.swift
//  Starchat
//
//  Created by Rahul Sharma on 27/05/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G

import UIKit
class BusinessCategoryListCell: UITableViewCell {
    
    //MARK:- Outlets
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var seletionImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    /// Setting the businessCategory List into cell
    ///
    /// - Parameter allCategoryList: Business Category List
    func businessCategoryData(allCategoryList: BusinessCategoryModel){
        self.categoryLabel.text = allCategoryList.businessCategorieType
        let categoryId = allCategoryList.businessCategoryId
    }
    
}
