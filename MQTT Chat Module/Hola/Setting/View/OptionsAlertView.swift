//
//  OptionsAlertView.swift
//  Starchat
//
//  Created by Rahul Sharma on 04/07/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//
protocol OptionsAlertViewDelegate {
    
    func dismissFunction(_ viewController:UIViewController)
}

import Foundation
class OptionsAlertView: UIView {
    
    //MARK:- Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var alertView: UIView!
    
    var optionsAlertDelegate:OptionsAlertViewDelegate?
    
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
        Bundle.main.loadNibNamed("OptionsAlertView", owner: self, options: nil)
        contentView.frame = bounds
        contentView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth,UIView.AutoresizingMask.flexibleHeight]
        alertView.layer.cornerRadius = 5.0
        alertView.clipsToBounds = true
        addSubview(contentView)
        
    }
  
    @IBAction func dismissButton_Action(_ sender: UIButton) {
    
    }
}
