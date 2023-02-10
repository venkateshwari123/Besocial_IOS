//
//  HeaderTVCell.swift
//  Yelo
//
//  Created by Rahul Sharma on 24/04/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

protocol HeaderTVCellDelegate {
    func transactionSelectionButtonAction()
}

class HeaderTVCell: UITableViewCell {
    
    @IBOutlet weak var recentTransactionTitle: UILabel!
    @IBOutlet weak var transactionPeriodButton: UIButton!
    @IBOutlet weak var transactionTypeLabel: UILabel!

    var delegate : HeaderTVCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .white
        recentTransactionTitle.text = "Recent Transactions".localized
        transactionTypeLabel.font = Theme.getInstance().walletTransactionButtonStyle.getFont()
//        transactionTypeLabel.textColor = Theme.getInstance().walletTransactionButtonStyle.getTextColor()
    }
    
    @IBAction func transactionPeriodButtonAction(_ sender: Any) {
        delegate?.transactionSelectionButtonAction()
    }
    
    func configureCell(title: String){
        transactionTypeLabel.text = title
    }
}
