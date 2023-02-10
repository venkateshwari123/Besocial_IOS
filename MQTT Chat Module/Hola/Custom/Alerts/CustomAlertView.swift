//
//  CustomAlertView.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 14/09/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit


protocol customViewdelegte {
    
    func  didDonecliked()
    func  didEditCliked()
}


class CustomAlertView: UIView {
    
     var delegete : customViewdelegte?

    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var userNumberLbl: UILabel!
    
    override init(frame: CGRect){
        
        super.init(frame:frame)
        commonInit()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    
    private func commonInit(){
        
        Bundle.main.loadNibNamed("CustomAlertView", owner: self, options: nil)
        
        contentView.frame = bounds
        contentView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth,UIView.AutoresizingMask.flexibleHeight]
        alertView.layer.cornerRadius = 5.0
        alertView.clipsToBounds = true
        addSubview(contentView)
        
        let tapgester = UITapGestureRecognizer.init(target: self, action: #selector(tapCliked))
        backView.addGestureRecognizer(tapgester)
    }

    
    @objc func tapCliked() {
        self.removeFromSuperview()
    }
    
    
    @IBAction func editBtnAction(_ sender: Any) {
        
        delegete?.didEditCliked()
    }
    
    
    @IBAction func okBtnAction(_ sender: Any) {
        
        delegete?.didDonecliked()
    }
    
    

}
