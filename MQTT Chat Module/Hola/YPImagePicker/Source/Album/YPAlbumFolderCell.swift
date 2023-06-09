//
//  YPAlbumFolderCell.swift
//  YPImagePicker
//
//  Created by Sacha Durand Saint Omer on 20/07/2017.
//  Copyright © 2017 Yummypets. All rights reserved.
//

import UIKit
import Stevia

class YPAlbumFolderCell: UITableViewCell {
    
    let thumbnail = UIImageView()
    let title = UILabel()
    let numberOfPhotos = UILabel()
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.addArrangedSubview(title)
        stackView.addArrangedSubview(numberOfPhotos)
        
        sv(
            thumbnail,
            stackView
        )
        
        layout(
            6,
            |-10-thumbnail.size(78),
            6
        )
        
        alignHorizontally(thumbnail-10-stackView)
        
        thumbnail.contentMode = .scaleAspectFill
        thumbnail.clipsToBounds = true
        
        title.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.regular)
        numberOfPhotos.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
    }
}
