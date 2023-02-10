//
//  UIButtonExtension.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 05/10/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
typealias ActionBlock = () -> Void

private var eventKey = 0

extension UIButton {
    func handleControlEvent(_ event: UIControl.Event, withBlock action: @escaping () -> Void) {
        objc_setAssociatedObject(self, &eventKey, action, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        addTarget(self, action: #selector(UIButton.callActionBlock(_:)), for: event)
    }
    
    @objc func callActionBlock(_ sender: Any?) {
        let block = objc_getAssociatedObject(self, &eventKey) as? ActionBlock
        if block != nil {
            block?()
        }
    }
}

extension UITextField {
    func setTheme(){
        self.layer.cornerRadius = 5
        self.layer.borderColor = Colors.inactiveBorder.cgColor
        self.layer.borderWidth = 0.7
        self.setPaddingPoints(10)
        self.tintColor = UIColor.darkGray
    }
    
    func setPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    func addRightImage(image: String, tintColor: UIColor? = nil) {
        let mainView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
        let rtImgView = UIImageView(image: UIImage(named: image))
        if let tintColor = tintColor{
            rtImgView.tintColor = tintColor
        }
        rtImgView.frame = CGRect(x: 0, y: 0, width: 30, height: 20)
        rtImgView.contentMode = .scaleAspectFit
        mainView.addSubview(rtImgView)
        mainView.isUserInteractionEnabled = false
        self.rightView = mainView
        self.rightViewMode = .always
    }
}

