//
//  StringExtension.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 11/07/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import TextAttributes

extension String {
    
//    func attributedComment() -> NSAttributedString {
//        let attrs = TextAttributes()
////            .font(UIFont.defaultFont(size: 13))
//            .foregroundColor(UIColor.white)
//            .alignment(.left)
//            .lineSpacing(1)
//            .dictionary
//        return NSAttributedString(string: self, attributes: convertToOptionalNSAttributedStringKeyDictionary(attrs))
//    }
    
    /// Decode string from base 64.
    ///
    /// - Returns: Optional String of Decoded String.
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    
    
    /// Used for fetch the base 64 encoded string from passed string.
    ///
    /// - Returns: base 64 encoded string
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
    }
    
    var isNumeric: Bool {
           guard self.count > 0 else { return false }
           let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "(", ")", "+", " ","-"]
           return Set(self).isSubset(of: nums)
       }
    
    func replace(target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
    
     
    
    
    
    //localization of string
    var localized: String {
        return self.localised(forLanguage:Utility.getSelectedLanguegeCode() == "sw" ? ("sw") : ("en"))
    }
    
    func localised(forLanguage language: String = Locale.preferredLanguages.first!.components(separatedBy: "-").first!) -> String {

            guard let path = Bundle.main.path(forResource: language == "en" ? "Base" : language, ofType: "lproj") else {

                let basePath = Bundle.main.path(forResource: "Base", ofType: "lproj")!

                return Bundle(path: basePath)!.localizedString(forKey: self, value: "", table: nil)
            }

            return Bundle(path: path)!.localizedString(forKey: self, value: "", table: nil)
        }
    
    //To get height of a string
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]), context: nil)
        
        return ceil(boundingBox.height)
    }
    //To get weight of a string
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]), context: nil)
        
        return ceil(boundingBox.width)
    }
    
    
    /// To create gif url without any modification
    ///
    /// - Returns: gif url
    func makeOriginalGifUrl() -> String{
        let endIndex = self.index(self.endIndex, offsetBy: -3)
        var truncated = self.substring(to: endIndex)
        truncated = truncated + "gif"
//        let gifString = truncated.replacingOccurrences(of: "upload/", with: "upload/w_200,h_200,c_fill/")
        return truncated
    }
    
    /// To make gif url of reduced quality
    ///
    /// - Returns: return gif url
    func makeGifUrl() -> String {
        let originalGifString = self.makeOriginalGifUrl()
        let gifString = originalGifString.replacingOccurrences(of: "upload/", with: "upload/vs_20,e_loop/")
//        let gifString = truncated.replacingOccurrences(of: "upload/", with: "upload/w_200,h_200,c_fill/")
        return gifString
    }
    
    
    /// TO make imgae url from any type of URL
    ///
    /// - Returns: image url
    func makeThumbnailUrl() -> String{
        let endIndex = self.index(self.endIndex, offsetBy: -3)
        var truncated = self.substring(to: endIndex)
        truncated = truncated + "jpg"
        return truncated
    }
    
    
    /// To check a string in a string ignoring
    ///
    /// - Parameter find: string to find
    /// - Returns: string in which find string to search
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
    
    
    func toURL() -> URL {
        return URL(string: self)!
    }
    
    func toJSON() -> [String: Any]? {
        let data = self.data(using: .utf8)!
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String,Any> {
                return jsonArray
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    func contains(_ string: String, options: CompareOptions) -> Bool {
            return range(of: string, options: options) != nil
        }
}

func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString
{
    let result = NSMutableAttributedString()
    result.append(left)
    result.append(right)
    return result
}

extension Data {
    func convertTOEncodedstring() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    func convertToData() -> Data? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return data
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
