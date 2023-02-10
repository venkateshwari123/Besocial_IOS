//
//  ResetViewPrompt.swift
//  Shoppd
//
//  Created by Rahul Sharma on 26/09/19.
//  Copyright © 2019 Nabeel Gulzar. All rights reserved.
//

import UIKit

enum LoginType{
    case Email(Email)
    case Phone(Phone)
}

enum Phone{
    case setPassword
    case loginPassword
}

enum Email{
    case normal
    case faceBook
    case google
    case apple
    case setPassword
}

class ResetViewPrompt: UIView {
    @IBOutlet weak var closeButtonView: UIView!
    @IBOutlet weak var resetPasswordTitle: UILabel!
    @IBOutlet weak var resetPasswordDescription: UILabel!
    @IBOutlet weak var phoneImageView: UIImageView!
    @IBOutlet weak var phoneTitleLabel: UILabel!
    @IBOutlet weak var emailImageView: UIImageView!
    @IBOutlet weak var emailTitleLAbel: UILabel!
    @IBOutlet weak var promptView: UIView!
    @IBOutlet weak var emailOptionView: UIView!
    @IBOutlet weak var phoneOptionView: UIView!
    var closeButtonAction:(()->Void)?
    var selectedLoginOption:((LoginType)->Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetUp()
    }
    
    func initialSetUp(){
        phoneImageView.image = UIImage(named: "phone")
        emailImageView.image = UIImage(named: "email-2")
        closeButtonView.setCornerRadius(cornerRadius: closeButtonView.frame.height/2)
        closeButtonView.backgroundColor = setColor(colors: Colors.rgba_lightGray14)
        Fonts.setFont(resetPasswordTitle, fontFamiy: .primary(.Medium), size: .custom(19), color: resetPasswordTitle.setColor(colors: Colors.rgba_dark))
        Fonts.setFont(resetPasswordDescription, fontFamiy: .primary(.Regular), size: .standard(.h12), color: setColor(colors: Colors.rgba_lightGray2))
        phoneTitleLabel.text = "Phone Number"
        Fonts.setFont(phoneTitleLabel, fontFamiy: .primary(.Regular), size: .standard(.h14), color: setColor(colors: Colors.rgba_dark))
        emailTitleLAbel.text = "Email Address"
        Fonts.setFont(emailTitleLAbel, fontFamiy: .primary(.Regular), size: .standard(.h14), color: setColor(colors: Colors.rgba_dark))
        phoneOptionView.layer.borderWidth = 0.5
        phoneOptionView.layer.borderColor = setColor(colors: Colors.rgba_lightGray15).cgColor
        emailOptionView.layer.borderWidth = 0.5
        emailOptionView.layer.borderColor = setColor(colors: Colors.rgba_lightGray15).cgColor
        promptView.setCornerRadius(cornerRadius: 10)
    }
    
    @IBAction func forgotButtonAction(_ sender: Any) {
        guard let button = sender as? UIButton else{return}
        selectedLoginOption?(button.tag == 0 ? .Phone(.loginPassword) : .Email(.normal))
    }
    @IBAction func closeButtonAction(_ sender: Any) {
        closeButtonAction?()
    }
}
