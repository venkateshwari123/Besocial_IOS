//
//  TransactionStatusTableViewCell.swift
//  Yelo
//
//  Created by Rahul Sharma on 03/06/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

class TransactionStatusTableViewCell: UITableViewCell {

    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
    }
    
    //sets ui for cell
    private func setUI(){
        titleLabel.font = Theme.getInstance().tableViewTitleLabelStyle.getFont()
        if Utility.isDarkModeEnable(){
            titleLabel.textColor = .white
            timeStampLabel.textColor = .white
        }else{
            titleLabel.textColor = Theme.getInstance().tableViewTitleLabelStyle.getTextColor()
            timeStampLabel.textColor = Theme.getInstance().tableViewTimeStampLabelStyle.getTextColor()
        }
        
        
        timeStampLabel.font = Theme.getInstance().tableViewTimeStampLabelStyle.getFont()
        
        
        statusView.makeCornerRadious(readious: statusView.frame.height / 2)
    }
    
    func configure(title:String,value: String){
        titleLabel.text = title.localized
        if let doubleDate = Double(value){
            
            timeStampLabel.text = Date().getDateFromTimeStampwithFormat(value: doubleDate/1000, format: "hh:mm a, dd MMM yyyy")
        }
        
        /*
         Bug Name:- Add color indication for transaction status
         Fix Date:- 08/06/21
         Fix By  :- Jayaram G
         Description of Fix:- Added background color to statusview
         */
        
        switch title {
        case "NEW":
            self.statusView.backgroundColor = Helper.hexStringToUIColor(hex: "#00B0FF")
        case "TRANSFERRED","APPROVED":
            self.statusView.backgroundColor = Helper.hexStringToUIColor(hex: "#84DE04")
        case "PENDING":
            self.statusView.backgroundColor = Helper.hexStringToUIColor(hex: "#DEBD04")
        case "REJECTED","FAILED","CANCELLED":
            self.statusView.backgroundColor = Helper.hexStringToUIColor(hex: "#ff0000")
         default:
            self.statusView.backgroundColor = Helper.hexStringToUIColor(hex: "#DEBD04")
         }
        //Date().getDateFromTimeStamp(dateString: transaction.txntimestamp, fromFormat : "yyyy-MM-dd'T'HH:mm:ss.SSSZ", toFormate: "hh:mm a, dd MMM yyyy")
    }
}
