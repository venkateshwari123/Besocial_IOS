//
//  PaymentMethodTVCell.swift
//  Yelo
//
//  Created by Rahul Sharma on 26/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

class PaymentMethodTVCell: UITableViewCell {

    @IBOutlet weak var logoImageView: UIImageView!
    
    @IBOutlet weak var selectImageView: UIImageView!
    @IBOutlet weak var paymentTitle: UILabel!
    
    @IBOutlet weak var backGroundView: UIView!
    
    @IBOutlet weak var selectedButton:UIButton!
    @IBOutlet weak var walletAmount: UILabel!
    
    @IBOutlet weak var walletWidth: NSLayoutConstraint!
    var indexPath:IndexPath?
    @IBOutlet weak var addMoneyButton:UIButton!
    @IBOutlet weak var addMoneyBGView:UIView!
    @IBOutlet weak var addMoneyStack:UIStackView!

    var selectedButtonAction:((IndexPath?)->Void)?
    
    var showAddMoney:Bool = false{
        didSet{
            walletAmount.isHidden = !showAddMoney
            walletWidth.constant = showAddMoney ? 110 : 0
            addMoneyBGView.isHidden = !showAddMoney
            addMoneyStack.isHidden = !showAddMoney
        }
    }
    
    var hideCardSelection:Bool = false{
        didSet{
            selectedButton.isEnabled = !hideCardSelection
            selectImageView.isHidden = hideCardSelection
        }
    }
    
    var walletdata:(balance:Double,currency:String)?{
        didSet{
            guard let walletData = walletdata else{
                walletAmount.text = ""
                return}
//            let balance = walletData.balance.formattedWithSeparator
//            walletAmount.text = "\(walletData.currency)\(balance)"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        logoImageView.image = UIImage(named: "payment")
        paymentTitle.text = "Pay On Delivery"
//        Fonts.setFont(paymentTitle, fontFamiy: .primary(.SemiBold), size: .standard(.h16), color: UIColor.Light.black)
//        Fonts.setFont(walletAmount, fontFamiy: .primary(.Regular), size: .standard(.h14), color: UIColor.Light.black)
//        backGroundView.backgroundColor = UIColor.Light.white1
        addMoneyButton.setTitle("Add Money", for: .normal)
//        Fonts.setFont(addMoneyButton, fontFamiy: .primary(.SemiBold), size: .custom(14), color: UIColor.blue)
        addMoneyButton.layer.cornerRadius = 2.5
        addMoneyButton.layer.borderWidth = 1
        addMoneyButton.layer.borderColor = UIColor.blue.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func selectedButtonAction(_ sender: Any) {
        selectedButtonAction?(indexPath)
    }
}

