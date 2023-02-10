//
//  BusinessCustomAlertView.swift
//  Starchat
//
//  Created by Rahul Sharma on 29/05/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G
import Foundation

/// Managing Done Button Action in Alert View
protocol BusinessCustomViewdelegte {
    func  didDonecliked()
}
class BusinessCustomAlertView: UIView {
    
    //MARK:- Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var alertView: UIView!
    
    //MARK:- Variables&Declarations
    var delegete : BusinessCustomViewdelegte?
    
    override init(frame: CGRect){
        super.init(frame:frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    
    /// Setting Up AlertView
    private func commonInit(){
        Bundle.main.loadNibNamed("BusinessCustomAlertView", owner: self, options: nil)
        contentView.frame = bounds
        contentView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth,UIView.AutoresizingMask.flexibleHeight]
        alertView.layer.cornerRadius = 5.0
        alertView.clipsToBounds = true
        addSubview(contentView)
        
    }
    
    
    /// Done button action in alert View
    ///
    /// - Parameter sender: Done Button
    @IBAction func letsStartBtnAction(_ sender: UIButton) {
        delegete?.didDonecliked()
    }
    
}
