//
//  CoinTransacationCell.swift
//  Do Chat
//
//  Created by 3Embed on 06/11/20.
//  Copyright © 2020 Rahul Sharma. All rights reserved.
//

import UIKit

class CoinTransacationCell: UITableViewCell {
   
    @IBOutlet weak var imgFlag: UIImageView!
    @IBOutlet weak var lbltitle: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var imgCoin: UIImageView!
    @IBOutlet weak var transactionIdLabel: UILabel!
    
    @IBOutlet weak var timeStampLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setCellData(model: CoinWalletModel){
        if model.txntype == 2 {
            self.imgFlag.image = #imageLiteral(resourceName: "coin_out")
        }else{
            self.imgFlag.image = #imageLiteral(resourceName: "coin_in")
        }
        if let txnId = model.txnid {
            let last4 = String(txnId.suffix(11))
            self.transactionIdLabel.text = "Trans ID".localized + ": \(last4)"
        }
        
        self.lblAmount.text = "\(model.amount ?? "0")"
        self.lbltitle.text = model.descc
        self.timeStampLabel.text =  Date().getDateFromTimeStamp(dateString: model.txntimestamp ?? "", fromFormat : "yyyy-MM-dd'T'HH:mm:ss.SSSZ", toFormate: "dd MMM yyyy,HH:mm:ss")
    }
}

