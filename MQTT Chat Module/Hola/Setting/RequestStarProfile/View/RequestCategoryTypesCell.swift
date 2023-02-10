//
//  RequestCategoryTypesCell.swift
//  Starchat
//
//  Created by Rahul Sharma on 5/6/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G
import UIKit
class RequestCategoryTypesCell: UITableViewCell {
    
    //MARK:- Outlets
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    /// Settign  Model Data into Cell
    ///
    /// - Parameter allCategoryList: allCategoryList (RequestStarCategoryModel)
    func categoryData(allCategoryList: RequestStarCategoryModel){
        self.titleLabel.text = allCategoryList.categorie
        let categoryId = allCategoryList.userId
    }
}
