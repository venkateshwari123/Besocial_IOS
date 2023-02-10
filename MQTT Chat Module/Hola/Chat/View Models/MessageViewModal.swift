//
//  MessageViewModal.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 23/08/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class MessageViewModal {
    
    let couchbaseObj = Couchbase.sharedInstance
    let message : Message!
    
    let selfID = Utility.getUserid()
    
    /// Initiaizing the message object with the Message object.
    ///
    /// - Parameter message: Message Object
    init(withMessage message: Message) {
        self.message = message
    }
    
    func addLastDateAndTime(toCell cell: JSQMessagesCollectionViewCell, isSelf: Bool) -> JSQMessagesCollectionViewCell {
        cell.timeLabelOutlet?.attributedText = self.setDateTime(isSelf: isSelf)
        cell.currentStatusOutlet?.attributedText = self.setReadStatus()
        cell.backgroundColor = .clear
        return cell
    }
    
    func setDay()  -> NSAttributedString {
        guard let timestamp = self.message.timeStamp else { return NSAttributedString() }
        let dayStr = DateExtension().getDateString(fromTimeStamp: timestamp)
        let attribute = [convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.darkGray]
        let str = NSAttributedString(string: dayStr, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
        return str
    }
    
    func setDateTime(isSelf: Bool)  -> NSAttributedString {
        guard let timestamp = message.timeStamp else { return NSAttributedString() }
        let lastmsgDate = DateExtension().getDateObj(fromTimeStamp: timestamp)
        let date = DateExtension().lastMessageInHours(date: lastmsgDate)
        var attribute: [String : Any]?
        if isSelf{
            attribute = [convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.white] as [String : Any]
        }else{
            attribute = [convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.black] as [String : Any]
        }
        let str = NSAttributedString(string: date, attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute!))
        return str
    }
    
    func setReadStatus() -> NSAttributedString {
        let attribute = [convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.black]
        if message.isSelfMessage {
            var str = NSAttributedString(string: "✔︎", attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
//            if message.messageStatus == "0" {
//                let attribute = [convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.white]
//                str = NSAttributedString(string: "@", attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
//                return str
//            }
//            else
            if message.messageStatus == "1" {
                let attribute = [convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.black]
                str = NSAttributedString(string: "✔︎", attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                return str
            }
            else if message.messageStatus == "2" {
                let attribute = [convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.white]
                str = NSAttributedString(string: "✔︎✔︎", attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                return str
            }
            else if message.messageStatus == "3" {
                let tikColor = Helper.hexStringToUIColor(hex: "#09A9FD")
                let attribute = [convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : tikColor]
                str = NSAttributedString(string: "✔︎✔︎", attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
                return str
            }
            return str
        }
        let str = NSAttributedString(string: "", attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
        return str
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
