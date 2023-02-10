//
//  SuccessResetPassword.swift
//  Shoppd
//
//  Created by Rahul Sharma on 14/10/19.
//  Copyright © 2019 Nabeel Gulzar. All rights reserved.
//

import UIKit

class SuccessResetPassword: UIView {
    
    @IBOutlet weak var checkMarkImageView: UIImageView!
    @IBOutlet weak var resetPassword: UILabel!
    @IBOutlet weak var successDescription: UILabel!
    @IBOutlet weak var gotohomeView: UIView!
    @IBOutlet weak var gotoHomeLabel: UILabel!
    var gotoHomeAction:(()->Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetUp()
    }
    var hidegoToButton:Bool = false{
        didSet{
            gotohomeView.isHidden = hidegoToButton
        }
    }
    var hideDescription:Bool = false{
        didSet{
            successDescription.isHidden = hideDescription
        }
    }
    func initialSetUp(){
        checkMarkImageView.image = UIImage(named: "Success_Check")
        Fonts.setFont(resetPassword, fontFamiy: .primary(.Medium), size: .custom(19), color: resetPassword.setColor(colors: Colors.rgba_dark))
        Fonts.setFont(successDescription, fontFamiy: .primary(.Light), size: .standard(.h12), color: successDescription.setColor(colors: Colors.rgba_lightGray20))
        gotohomeView.backgroundColor = UIColor.blue
        Fonts.setFont(gotoHomeLabel, fontFamiy: .primary(.Regular), size: .standard(.h14), color: .white)
    }
    @IBAction func gotoHomeAction(_ sender: Any) {
        gotoHomeAction?()
    }
    
}
