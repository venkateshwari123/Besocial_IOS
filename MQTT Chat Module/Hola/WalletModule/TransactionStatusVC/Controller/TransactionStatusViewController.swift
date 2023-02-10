//
//  TransactionStatusViewController.swift
//  Yelo
//
//  Created by Rahul Sharma on 03/06/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

class TransactionStatusViewController: BaseViewController {

    @IBOutlet weak var StaticTimeStampLabel: UILabel!
    @IBOutlet weak var staticModeLabel: UILabel!
    @IBOutlet weak var staticAmountLabel: UILabel!
     @IBOutlet weak var staticReasonLabel: UILabel!
    
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var reasonLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var reasonLabelHeightConstraint: NSLayoutConstraint!

    
    let viewModel = TransactionStatusViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setUI()
    }
    
    //called when view is loaded for first time
    private func setup() {
        setNavigationLeftBarBackButton()
        self.title = viewModel.withdrawID
        reasonLabel.text = ""
        staticReasonLabel.text = ""
        reasonLabel.sizeToFit()
        viewModel.getWithdrawDetails { (success) in
            self.setData()
            self.tableView.reloadData()
        }
    }
    
    //this function sets necessary ui need to be done
    private func setUI(){
        StaticTimeStampLabel.font = Theme.getInstance().staticLabelStyle.getFont()
        
        if Utility.isDarkModeEnable(){
            StaticTimeStampLabel.textColor = .white
            staticModeLabel.textColor = .white
            staticAmountLabel.textColor = .white
            reasonLabel.textColor = .white
            staticReasonLabel.textColor = .white
            timeStampLabel.textColor = .white
            modeLabel.textColor = .white
            amountLabel.textColor = .white
        }else{
            StaticTimeStampLabel.textColor = Theme.getInstance().staticLabelStyle.getTextColor()
            staticModeLabel.textColor = Theme.getInstance().staticLabelStyle.getTextColor()
            staticAmountLabel.textColor = Theme.getInstance().staticLabelStyle.getTextColor()
            reasonLabel.textColor = Theme.getInstance().staticLabelStyle.getTextColor()
            staticReasonLabel.textColor = Theme.getInstance().staticLabelStyle.getTextColor()
            timeStampLabel.textColor = Theme.getInstance().valuesLabelStyle.getTextColor()
            modeLabel.textColor = Theme.getInstance().valuesLabelStyle.getTextColor()
            amountLabel.textColor = Theme.getInstance().valuesLabelStyle.getTextColor()
        }
        
        staticModeLabel.font = Theme.getInstance().staticLabelStyle.getFont()
        staticAmountLabel.font = Theme.getInstance().staticLabelStyle.getFont()
        reasonLabel.font = Theme.getInstance().staticLabelStyle.getFont()
        staticReasonLabel.font = Theme.getInstance().staticLabelStyle.getFont()
        timeStampLabel.font = Theme.getInstance().valuesLabelStyle.getFont()
        modeLabel.font = Theme.getInstance().valuesLabelStyle.getFont()
        amountLabel.font = Theme.getInstance().valuesLabelStyle.getFont()
        
    }
    
    //used to set data after details are fetched
    private func setData(){
        timeStampLabel.text = Date().getDateFromTimeStamp(dateString: viewModel.transactionDetails.createdate, fromFormat : "yyyy-MM-dd'T'HH:mm:ss.SSSZ", toFormate: "dd MMM yyyy,HH:mm:ss")
        modeLabel.text = viewModel.transactionDetails.pgname
        amountLabel.text = Utility.getWalletCurrenySymbol() + viewModel.transactionDetails.amount
        
        if viewModel.isFailed{
            reasonLabel.text = viewModel.transactionDetails.reason
            staticReasonLabel.text = "Reason"
            reasonLabel.sizeToFit()
        }else{
            reasonLabel.text = ""
            staticReasonLabel.text = ""
            reasonLabel.sizeToFit()
        }
        
    }
}
