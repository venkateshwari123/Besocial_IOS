//
//  CameraBottomOptionsCVCell.swift
//  Do Chat
//
//  Created by Rahul Sharma on 11/07/20.
//  Copyright © 2020 Rahul Sharma. All rights reserved.
//


import UIKit

class CameraBottomOptionsCVCell: UICollectionViewCell {

    @IBOutlet weak var optionTitle:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }


    
    override func layoutSubviews()
    {
        super.layoutSubviews()
    }
    
    func setSelected(){
        if  let font: UIFont = UIFont.init(name: "CenturyGothic-Bold", size: 14){
       optionTitle.textColor = UIColor.white
        optionTitle.font = font
        }
    }
    
    func setUnSelected(){
           if  let font: UIFont = UIFont.init(name: "CenturyGothic-Bold", size: 14){
        optionTitle.textColor = UIColor.white
         optionTitle.font = font
         }
       }
    
    func hideCells(){
           if let font: UIFont = UIFont.init(name: "CenturyGothic", size: 14){
             optionTitle.textColor = UIColor.clear
             optionTitle.font = font
            }
           }
 
}
