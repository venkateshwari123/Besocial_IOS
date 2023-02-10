//
//  BankListTableViewCell.swift
//  Yelo
//
//  Created by Rahul Sharma on 06/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

class BankListTableViewCell: UITableViewCell {

    @IBOutlet weak var selectionImageVeiw: UIImageView!
    @IBOutlet weak var bankAccountLabel: UILabel!
    @IBOutlet weak var bankCodeLabel: UILabel!
    @IBOutlet weak var detailButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bankAccountLabel.font = Theme.getInstance().rechargeSuccessDetailStyle.getFont()
        bankAccountLabel.font = Theme.getInstance().rechargeSuccessDetailStyle.getFont()
        
        //bankCodeLabel.font = Theme.getInstance().pswdRecoverSubHeadingStyle.getFont()
       // bankCodeLabel.font = Theme.getInstance().pswdRecoverSubHeadingStyle.getFont()
    }
    
    func configureCell( bank: Bank, isSelectd: Bool){
        self.bankAccountLabel.text =  "XXXX " + bank.last4
//        self.bankCodeLabel.text = bankCode
        self.selectionImageVeiw.image = isSelectd ? #imageLiteral(resourceName: "radio_selected") : #imageLiteral(resourceName: "radio_empty")
    }
}
