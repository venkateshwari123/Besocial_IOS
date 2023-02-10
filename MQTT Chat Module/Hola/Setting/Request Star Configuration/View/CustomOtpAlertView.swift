//
//  CustomOtpAlertView.swift
//  Starchat
//
//  Created by Rahul Sharma on 12/06/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G

import Foundation

/// To managing Action in Custom View
protocol CustomAlertOtpViewDelegate {
    func okBtnClicked()
}
class CustomOtpAlertView: UIView {
    
    //MARK:- Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var alertImage: UIImageView!
    @IBOutlet weak var okBtnOutler: UIButton!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    //MARK:- Variables&Declarations
    var delegete : CustomAlertOtpViewDelegate?
    
    
    override init(frame: CGRect){
        super.init(frame:frame)
        commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    /// SettingUp View
    private func commonInit(){
        Bundle.main.loadNibNamed("CustomOtpAlertView", owner: self, options: nil)
        contentView.frame = bounds
        contentView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth,UIView.AutoresizingMask.flexibleHeight]
        okBtnOutler.makeImageCornerRadius(9)
        alertView.layer.cornerRadius = 5.0
        alertView.clipsToBounds = true
        addSubview(contentView)
        
        
    }
    
    /// Ok Button Action
    ///
    /// - Parameter sender: Ok Button
    @IBAction func okAction(_ sender: UIButton) {
        delegete?.okBtnClicked()
    }
    
}
