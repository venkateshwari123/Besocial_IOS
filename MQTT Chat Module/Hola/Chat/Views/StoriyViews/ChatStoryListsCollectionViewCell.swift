//
//  ChatStoryListsCollectionViewCell.swift
//  PicoAdda
//
//  Created by 3Embed on 09/11/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class ChatStoryListsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var storyContainerView: UIView!
    
    @IBOutlet weak var storyImageView: UIImageView!
    
//    @IBOutlet weak var userImageContainer: UIView!
//    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    //MARK:- View life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        self.userImageView.makeCornerRadious(readious: self.userImageView.frame.size.width / 2)
//        self.userImageView.makeBorderWidth(width: 1, color: UIColor.white)
//        self.makeShadow(readious: 5, layer: self.userImageContainer.layer)
        self.storyImageView.makeCornerRadious(readious: self.storyImageView.frame.width / 2)
        
        self.storyContainerView.makeCornerRadious(readious: self.storyContainerView.frame.size.width / 2)
        let leftColor = Helper.hexStringToUIColor(hex: AppColourStr.gradientLeftColor)
        let rightColor = Helper.hexStringToUIColor(hex: AppColourStr.gradientRightColor)
        self.storyContainerView.makeLeftToRightGeadient(leftColor: leftColor, rightColor: rightColor)
        
//        let layer = self.storyContainerView.layer
//        self.makeShadow(readious: self.storyContainerView.frame.width / 2, layer: layer)
    }
    
    func makeShadow(readious: CGFloat, layer: CALayer){
        let layer = self.storyContainerView.layer
        layer.shadowRadius = 2;
        layer.cornerRadius = readious;
        layer.masksToBounds = false;
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowOpacity = 1
        layer.shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: readious).cgPath
    }
    
}
