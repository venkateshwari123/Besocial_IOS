//
//  SingleChatDeliveryStatusCVCell.swift
//  Infra.Market Messenger
//
//  Created by 3Embed Software Tech Pvt Ltd on 25/04/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class SingleChatDeliveryStatusCVCell: UICollectionViewCell {
    
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var MainView: UIView!
    
    @IBOutlet weak var readStatusLabel: UILabel!
    @IBOutlet weak var readTimeLable: UILabel!
    
    @IBOutlet weak var deliveryStatusLabel: UILabel!
    @IBOutlet weak var deliveredTimeLabel: UILabel!
    
    private var shadowLayer: CAShapeLayer!
    
    //MARK:- View life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
//            let shadowFrame = self.shadowView.bounds
//            let frame = CGRect(x: shadowFrame.origin.x, y: shadowFrame.origin.y, width: shadowFrame.size.width - 40, height: shadowFrame.size.height)
//            shadowLayer.path = UIBezierPath(roundedRect: frame, cornerRadius: 5).cgPath
//            shadowLayer.fillColor = UIColor.white.cgColor
//
//            shadowLayer.shadowColor = UIColor.lightGray.cgColor
//            shadowLayer.shadowPath = shadowLayer.path
//            shadowLayer.shadowOffset = CGSize(width: 2.0, height: 2.0)
//            shadowLayer.shadowOpacity = 0.8
//            shadowLayer.shadowRadius = 2

//            self.shadowView.layer.insertSublayer(shadowLayer, at: 0)
//            //layer.insertSublayer(shadowLayer, below: nil) // also works
            
//
            self.shadowView.layer.masksToBounds = false
            self.shadowView.layer.shadowColor = UIColor.lightGray.cgColor
            self.shadowView.layer.shadowPath = UIBezierPath(roundedRect: self.shadowView.bounds, cornerRadius: 5).cgPath
            self.shadowView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
            self.shadowView.layer.shadowOpacity = 0.5
            self.shadowView.layer.shadowRadius = 1.0

            self.MainView.layer.borderWidth = 0.2
            self.MainView.layer.borderColor = UIColor.lightGray.cgColor
            self.MainView.layer.cornerRadius = 5
            self.MainView.layer.masksToBounds = true
            
            
            
        }
    }
    
    
    /// To set cell data
    ///
    /// - Parameter message: message model object
    func setStatusCellData(message: Message?){
        guard let msg = message else {return}
        self.readTimeLable.text = "..."
        self.deliveredTimeLabel.text = "..."
        var attribute = [convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.black]
        self.deliveryStatusLabel.attributedText = NSAttributedString(string: "✔︎✔︎", attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
        attribute = [convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : AppColourStr.tickColor]
        self.readStatusLabel.attributedText = NSAttributedString(string: "✔︎✔︎", attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
        
        if msg.messageStatus == "2" || msg.messageStatus == "3"{
            if let date = DateExtension().getDateFromDouble(timeStamp: msg.deliveryTime!){
                let time = DateExtension().getDataAndTimeForMessageInfo(date: date)
                self.deliveredTimeLabel.text = time
            }
            if msg.messageStatus == "3"{
                if let date = DateExtension().getDateFromDouble(timeStamp: msg.readTime!){
                    let time = DateExtension().getDataAndTimeForMessageInfo(date: date)
                    self.readTimeLable.text = time
                }
            }
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
