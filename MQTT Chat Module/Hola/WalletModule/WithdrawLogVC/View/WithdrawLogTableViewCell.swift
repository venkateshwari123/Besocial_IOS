

//
//  WithdrawLogTableViewCell.swift
//  Yelo
//
//  Created by Rahul Sharma on 09/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

class WithdrawLogTableViewCell: UITableViewCell {
    
    @IBOutlet weak var statuView: UIView!
    @IBOutlet weak var transactionId: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        transactionId.font = Theme.getInstance().withdrawLogIdStyle.getFont()
        transactionId.textColor = UIColor.setColor(lightMode: "292929", darkMode: "FFFFFF")
            //Theme.getInstance().withdrawLogIdStyle.getTextColor()
        
        titleLabel.font = Theme.getInstance().withdrawLogTitleStyle.getFont()
        titleLabel.textColor = UIColor.setColor(lightMode: "292929", darkMode: "FFFFFF")
            //Theme.getInstance().withdrawLogTitleStyle.getTextColor()
        
        timeLabel.font = Theme.getInstance().transactionTimeStampStyle.getFont()
        timeLabel.textColor = UIColor.setColor(lightMode: "292929", darkMode: "FFFFFF")
           // Theme.getInstance().transactionTimeStampStyle.getTextColor()
        
        amountLabel.font = Theme.getInstance().transactionAmountLabel.getFont()
        amountLabel.textColor = UIColor.setColor(lightMode: "292929", darkMode: "FFFFFF")
           // Theme.getInstance().transactionAmountLabel.getTextColor()
        
        statusLabel.font = Theme.getInstance().transactionStatusStyle.getFont()
        statusLabel.textColor = Theme.getInstance().transactionStatusStyle.getTextColor()
        
        statuView.layer.cornerRadius = statuView.frame.height/2
        
        
    }

    func configureCell(txn: Transaction){
        self.amountLabel.text = "\(Utility.getWalletCurrenySymbol())" + " " + txn.amount //txn.currencySymbol
        self.transactionId.text = txn.withdrawid
        self.timeLabel.text = Date().getDateFromTimeStamp(dateString: txn.updatedate, fromFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", toFormate: "dd MMM yyyy,HH:mm:ss")
        self.titleLabel.text = txn.reason
        self.statusLabel.text = txn.status.localized
        /*
         Bug Name:- Add color indication for transaction status
         Fix Date:- 08/06/21
         Fix By  :- Jayaram G
         Description of Fix:- Added background color to statusview and label text
         */
        switch txn.status {
        case "NEW":
            self.statusLabel.textColor = Helper.hexStringToUIColor(hex: "#00B0FF")
            self.statuView.backgroundColor = Helper.hexStringToUIColor(hex: "#00B0FF")
        case "TRANSFERRED","APPROVED":
            self.statusLabel.textColor = Helper.hexStringToUIColor(hex: "#84DE04")
            self.statuView.backgroundColor = Helper.hexStringToUIColor(hex: "#84DE04")
        case "PENDING":
            self.statusLabel.textColor = Helper.hexStringToUIColor(hex: "#DEBD04")
            self.statuView.backgroundColor = Helper.hexStringToUIColor(hex: "#DEBD04")
        case "REJECTED","FAILED","CANCELLED":
            self.statusLabel.textColor = Helper.hexStringToUIColor(hex: "#ff0000")
            self.statuView.backgroundColor = Helper.hexStringToUIColor(hex: "#ff0000")
         default:
            self.statusLabel.textColor = Helper.hexStringToUIColor(hex: "#DEBD04")
            self.statuView.backgroundColor = Helper.hexStringToUIColor(hex: "#DEBD04")
         }
        //to-do : need to set color of statuView as per type of transaction
    }

}
