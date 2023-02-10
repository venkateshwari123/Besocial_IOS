//
//  EmailSentPrompt.swift
//  Shoppd
//
//  Created by Rahul Sharma on 26/09/19.
//  Copyright © 2019 Nabeel Gulzar. All rights reserved.
//

import UIKit

class EmailSentPrompt: UIView {
    @IBOutlet weak var checkmail: UILabel!
    @IBOutlet weak var checkdescription: UILabel!
    @IBOutlet weak var mailId: UILabel!
    @IBOutlet weak var okButtonView: UIView!
    var okButonPressed:(()->Void)?
    @IBOutlet weak var messagePromptView: UIView!
    @IBOutlet weak var okButtonTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetUp()
    }
    
    
    func initialSetUp(){
        checkmail.text = "Check Your Mail"
        Fonts.setFont(checkmail, fontFamiy: .primary(.Medium), size: .custom(24), color: setColor(colors: Colors.rgba_dark))
        checkdescription.text = "We have sent you the link to"
        Fonts.setFont(checkdescription, fontFamiy: .primary(.Regular), size: .custom(13), color: setColor(colors: Colors.rgba_lightGray2 ))
        Fonts.setFont(mailId, fontFamiy: .primary(.Regular), size: .standard(.h14), color: setColor(colors: Colors.rgba_dark))
        Fonts.setFont(okButtonTitle, fontFamiy: .primary(.SemiBold), size: .standard(.h14), color: .white)
        okButtonView.backgroundColor =  UIColor.blue
        okButtonView.layer.borderWidth = 3
        okButtonView.layer.borderColor =  UIColor.blue.cgColor
        messagePromptView.setCornerRadius(cornerRadius: 5)
    }
    @IBAction func okButtonAction(_ sender: Any) {
        okButonPressed?()
    }
    
}
