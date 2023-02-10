//
//  CategoryListTableViewCell.swift
//  dub.ly
//
//  Created by 3Embed Software Tech Pvt Ltd on 14/12/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

class CategoryListTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var categorySelectionImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.categoryImageView.makeCornerRadious(readious: self.categoryImageView.frame.size.width / 2)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setDataInCategoryListCell(modelData: CategoryListModel, isSelected: Bool){
        self.categoryImageView.setImageOn(imageUrl: modelData.categoryActiveIconUrl, defaultImage: #imageLiteral(resourceName: "defaultImage"))
        self.categoryNameLabel.text = modelData.categoryName
        let imageName = isSelected ? "select_category_icon" : "unselecte_category_icon"
        let image = UIImage(named: imageName)!
        self.categorySelectionImageView.image = image
    }
    
}
