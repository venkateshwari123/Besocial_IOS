//
//  FilterCollectionViewCell.swift
//  photoTaking
//
//  Created by Sacha Durand Saint Omer on 21/10/16.
//  Copyright © 2016 octopepper. All rights reserved.
//

import Stevia

class FilterCollectionViewCellYPImagePicker: UICollectionViewCell {
    
    let name = UILabel()
    let imageView = UIImageView()
    override var isHighlighted: Bool { didSet {
        UIView.animate(withDuration: 0.1) {
            self.contentView.transform = self.isHighlighted
                ? CGAffineTransform(scaleX: 0.95, y: 0.95)
                : CGAffineTransform.identity
        }
        }
    }
    override var isSelected: Bool { didSet {
        if #available(iOS 13.0, *) {
            name.textColor = isSelected
                ? .label
                : UIColor(r: 154, g: 154, b: 154)
        } else {
            name.textColor = isSelected
                ? UIColor(r: 38, g: 38, b: 38)
                : UIColor(r: 154, g: 154, b: 154)
            // Fallback on earlier versions
        }
        
        
        name.font = .systemFont(ofSize: 11, weight: isSelected
            ? UIFont.Weight.medium
            : UIFont.Weight.regular)
        }
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        sv(
            name,
            imageView
        )
        
        |name|.top(0)
        |imageView|.bottom(0).heightEqualsWidth()
        
        name.font = .systemFont(ofSize: 11, weight: UIFont.Weight.regular)
        if #available(iOS 13.0, *) {
            name.textColor = .label
        } else {
            name.textColor = UIColor(r: 154, g: 154, b: 154)
            // Fallback on earlier versions
        }
        name.textAlignment = .center
        imageView.contentMode = .scaleAspectFill
        
        imageView.layer.shadowColor = UIColor(r: 46, g: 43, b: 37).cgColor
        imageView.layer.shadowOpacity = 0.3
        imageView.layer.shadowOffset = CGSize(width:0, height:10)
        imageView.layer.shadowRadius = 20
        imageView.clipsToBounds = true
    }
}
