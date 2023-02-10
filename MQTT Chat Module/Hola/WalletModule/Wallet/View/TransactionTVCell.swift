//
//  TransactionTVCell.swift
//  Yelo
//
//  Created by Rahul Sharma on 24/04/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

class TransactionTVCell: UITableViewCell {

    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusVerticalView: UIView!
    @IBOutlet weak var transactionIdLabel: UILabel!
    @IBOutlet weak var transactionTitleLabel: UILabel!
    @IBOutlet weak var transactionAmountLabel: UILabel!
    @IBOutlet weak var transactionTimeStampLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        
        statusView.makeCornerRadious(readious: statusView.frame.width / 2)
        
        transactionIdLabel.font = Theme.getInstance().transactionTimeStampStyle.getFont()
         transactionIdLabel.textColor = Theme.getInstance().transactionTimeStampStyle.getTextColor()
        
        transactionTitleLabel.font = Theme.getInstance().transactionTitleLabel.getFont()
//        transactionTitleLabel.textColor = Theme.getInstance().transactionTitleLabel.getTextColor()
        
        transactionAmountLabel.font = Theme.getInstance().transactionAmountLabel.getFont()
//        transactionAmountLabel.textColor = Theme.getInstance().transactionAmountLabel.getTextColor()
        
        transactionTimeStampLabel.font = Theme.getInstance().transactionTimeStampStyle.getFont()
        transactionTimeStampLabel.textColor = Theme.getInstance().transactionTimeStampStyle.getTextColor()
    }
    
    func configutreCell(transaction: Transaction){
        self.transactionIdLabel.text = transaction.txnid
        self.transactionTitleLabel.text = transaction.description
        self.transactionTimeStampLabel.text = Date().getDateFromTimeStamp(dateString: transaction.txntimestamp, fromFormat : "yyyy-MM-dd'T'HH:mm:ss.SSSZ", toFormate: "dd MMM yyyy,HH:mm:ss")
        self.transactionAmountLabel.text = transaction.currencySymbol + " " + transaction.amount // for dynamic currency transaction.currency
        
        if transaction.txntype == "2" {//debited
            statusView.backgroundColor = #colorLiteral(red: 0.8527343869, green: 0.1535999477, blue: 0, alpha: 1)
        }
        
        if transaction.txntype == "1" {//credited
            statusView.backgroundColor = #colorLiteral(red: 0.2962744832, green: 0.7188703418, blue: 0.08175323159, alpha: 1)
        }
    }
}
