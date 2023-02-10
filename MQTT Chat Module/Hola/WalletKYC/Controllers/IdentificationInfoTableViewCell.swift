//
//  IdentificationInfoTableViewCell.swift
//  PicoAdda
//
//  Created by A.SENTHILMURUGAN on 1/8/1399 AP.
//  Copyright © 1399 Rahul Sharma. All rights reserved.
//

import UIKit
import TextFieldEffects

protocol SelectDocumentTypeDelegate {
    
     func addTransparentView(frames: CGRect)

}

class IdentificationInfoTableViewCell: UITableViewCell , UITextFieldDelegate {


    @IBOutlet weak var dropDownBtnHeightConstraint: NSLayoutConstraint!
  
    @IBOutlet weak var dropDownBtn: UIButton!
    @IBOutlet weak var typeContentTF: HoshiTextField!

    
    @IBOutlet weak var dropDownArrowImageView: UIImageView!
    var delegate : SelectDocumentTypeDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textFieldUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
   
    func setDataInCell(index: Int) {

        switch index {
        case 0:
            self.dropDownBtnHeightConstraint.constant = 50
            self.dropDownArrowImageView.isHidden = false
            self.typeContentTF.placeholder = "Select".localized + " " + "Document Type".localized
            self.typeContentTF.isUserInteractionEnabled = false
            self.typeContentTF.tag = 1
            self.dropDownBtn.isHidden = false
        case 1:
            self.dropDownBtnHeightConstraint.constant = 0
            self.dropDownArrowImageView.isHidden = true
            self.typeContentTF.placeholder = "Document Number".localized + "*"
            self.typeContentTF.isUserInteractionEnabled = true
            self.typeContentTF.tag = 2
            self.dropDownBtn.isHidden = true
          
        case 2:
             self.dropDownBtnHeightConstraint.constant = 0
            self.dropDownArrowImageView.isHidden = true
            self.typeContentTF.isUserInteractionEnabled = true
            self.typeContentTF.placeholder = "Name On Document".localized + "*"
             self.typeContentTF.tag = 3
             self.dropDownBtn.isHidden = true
            
        default :
            break


        }
        
    }

    @IBAction func dropDownButtonPressed(_ sender: UIButton) {
        
        delegate?.addTransparentView(frames: sender.frame)
    }
    
    func textFieldUI() {
//           self.typeContentTF.textColor =  UIColor.setColor(lightMode: "#484848", darkMode: AppColourStr.whiteColor)
//           self.typeContentTF.placeholderColor =  UIColor.lightGray
           self.typeContentTF.placeholderLabel.font = Utility.Font.Regular.ofSize(22)
           let frame = self.typeContentTF.frame
           self.typeContentTF.borderRect(forBounds: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: 0.1))
       }
    
}
