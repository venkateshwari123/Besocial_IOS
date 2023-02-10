//
//  WalletBalanceTVCell.swift
//  Yelo
//
//  Created by Rahul Sharma on 24/04/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

protocol BalanceTVCellDelegate{
    func rechargeButtonPressed()
    func withdrwaButtonPressed()
}

class BalanceTVCell: UITableViewCell {

    
    @IBOutlet weak var balanceView: UIView!
    @IBOutlet weak var balanceTitleLabel: UILabel!
    @IBOutlet weak var balanceAmountLabel: UILabel!
    @IBOutlet weak var rechargeButton: UIButton!
    @IBOutlet weak var withdrawButton: UIButton!
    @IBOutlet weak var rechargeBackView: UIView!
    @IBOutlet weak var withdrawBackView: UIView!
    
    var delegate : BalanceTVCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
        balanceTitleLabel.text = "Balance".localized
        rechargeButton.setTitle("Recharge".localized, for: .normal)
        withdrawButton.setTitle("Withdraw".localized, for: .normal)
    }
    
    func setup() {

        self.rechargeBackView.makeCornerRadious(readious: 10)
        self.withdrawBackView.makeCornerRadious(readious: 10)
        rechargeButton.clipsToBounds = true
        rechargeButton.layer.cornerRadius = 10

        
        
    }
    
    func configureCell(){
        let walletData = KeychainHelper.sharedInstance.getWalletBalance()
        balanceAmountLabel.text = "\(Utility.getWalletCurrenySymbol()) " +  (walletData ?? "0")//Utility.getWalletCurrenySymbol()
        
        if KeychainHelper.sharedInstance.getWalletBalance() == "" {
            balanceAmountLabel.text = "\(Utility.getWalletCurrenySymbol()) 0"//Utility.getWalletCurrenySymbol()
        }
    }
    
    
    @IBAction func withdrawButtonAction(_ sender: Any) {
         delegate?.withdrwaButtonPressed()
    }

    
    @IBAction func rechargeButtonAction(_ sender: Any) {
        delegate?.rechargeButtonPressed()
    }
    
}
