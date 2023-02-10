//
//  CardCell.swift
//  StripeDemo
//
//  Created by Rahul Sharma on 22/12/19.
//  Copyright © 2019 stripe. All rights reserved.


import UIKit
import Stripe

protocol CardCellDelegate {
    func deletePressed()
}
class CardCell: UITableViewCell {
    
    /// Card ImageView where we can show card brand images like Visa, MasterCard, JCB etc or sometime ApplePay Logo
    @IBOutlet weak var cardImageView: UIImageView!
    
    /// Card last 4 digit or Apple Pay
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var expiryDateLabel: UILabel!
    @IBOutlet weak var deleteCardButton: UIButton!
    @IBOutlet weak var customView: UIView!
    var delegate : CardCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    /// Update card cell
    /// - Parameter card: card details
    func update(_ card: Card, isDefault: Bool) {
        titleLabel.text = card.last4
        cardImageView.image = card.brand
//        accessoryType = card.isDefault == true ? .checkmark : .none
        let lastdigits = "\(card.expiryYear ?? 0)".suffix(2)
        expiryDateLabel.text = "\(00+(card.expiryMonth ?? 0))/\(lastdigits)"
        setDefaultCard(isDefault: isDefault)
        if let brand = card.brand{
            cardImageView.image = brand
        }
         
    }
    
    @IBAction func deleteCardButtonAction(_ sender: Any) {
        delegate?.deletePressed()
    }
    
    func setDefaultCard(isDefault: Bool){
        if isDefault{
            self.customView.layer.borderWidth = 1
           // self.customView.backgroundColor = UIColor.hexStringToUIColor(hex: "#E2F4FF")
            self.customView.backgroundColor   = UIColor.setColor(lightMode: AppColourStr.cardBackground, darkMode: AppColourStr.descriptionLabel)
            self.customView.layer.borderColor = UIColor.hexStringToUIColor(hex: "#49ABF3").cgColor
            self.customView.clipsToBounds = true
            self.customView.makeCornerRadious(readious: 10)
        }
        else{
            self.customView.layer.borderWidth = 1
            //self.customView.backgroundColor = .white
            self.customView.backgroundColor = UIColor.init(hex: "#87CEFA")
            self.customView.layer.borderColor = #colorLiteral(red: 0.9386680722, green: 0.9387995601, blue: 0.9386265874, alpha: 1)
            self.customView.clipsToBounds = true
            self.customView.makeCornerRadious(readious: 0)
        }
    }
    
     func cardImage(with type: String) -> UIImage {
        
        switch type {
            
        case "visa":
            return STPImageLibrary.brandImage(for: STPCardBrand.visa)
        case "mastercard":
            return STPImageLibrary.brandImage(for: STPCardBrand.masterCard)
        case "discover":
            return STPImageLibrary.brandImage(for: STPCardBrand.discover)
        case "american express":
            return STPImageLibrary.brandImage(for: STPCardBrand.amex)
        case "amex":
            return STPImageLibrary.brandImage(for: STPCardBrand.amex)
        case "jcb":
            return STPImageLibrary.brandImage(for: STPCardBrand.JCB)
        case "diners club":
            return STPImageLibrary.brandImage(for: STPCardBrand.dinersClub)
        default:
            return STPImageLibrary.brandImage(for: STPCardBrand.unknown)
        }
    }
}
