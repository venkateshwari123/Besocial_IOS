//
//  Fonts.swift
//  UFly
//
//  Created by 3Embed on 11/09/17.
//  Copyright © 2017 Nabeel Gulzar. All rights reserved.
//

import UIKit

///Enumeration Constants For Fonts

struct FontAttruiibutes{
    let text:String
    let family:FontFamily
    let size:FontSize
    let color:UIColor
}

enum FontFamily{
    case primary(Primary)
    case secondary(Secondary)
    case ternary(Ternary)
    case custom(String)
    var value:String{
        switch self {
        case .primary(let fontName):
            return fontName.rawValue
        case .secondary(let fontName):
            return fontName.rawValue
        case .ternary(let fontName):
            return fontName.rawValue
        case .custom(let fontName):
            return fontName
        }
    }
}

enum FontSize{
    case standard(StandardSize)
    case custom(CGFloat)
    var value: CGFloat {
        switch self {
        case .standard(let size):
            return size.rawValue
        case .custom(let customSize):
            return customSize
        }
    }
}

enum Ternary:String{
    case Bold               = "ProductSans-Bold"
    case Regular            = "ProductSans-Regular"
}

enum Secondary:String{
    case Black             = "Raleway-Black"
    case Bold              = "Raleway-Bold"
    case ExtraBold         = "Raleway-ExtraBold"
    case ExtraLight        = "Raleway-ExtraLight"
    case Light             = "Raleway-Light"
    case Medium            = "Raleway-Medium"
    case Regular           = "Raleway-Regular"
    case Thin              = "Raleway-Thin"
    case SemiBold          = "Raleway-SemiBold"
}

enum Primary:String {
    case Black             = "Poppins-Black"
    case Bold              = "Poppins-Bold"
    case ExtraBold         = "Poppins-ExtraBold"
    case ExtraLight        = "Poppins-ExtraLight"
    case Light             = "Poppins-Light"
    case Medium            = "Poppins-Medium"
    case Regular           = "Poppins-Regular"
    case Thin              = "Poppins-Thin"
    case SemiBold          = "Poppins-SemiBold"
}

enum StandardSize: CGFloat {
    case h25 = 25.0
    case h22 = 22.0
    case h20 = 20.0
    case h18 = 18.0
    case h16 = 16.0
    case h14 = 14.0
    case h12 = 12.0
    case h10 = 10.0
    case h8 = 8.0
}

class Fonts: NSObject {
    
    class func setFont(_ sender:UIView,fontFamiy:FontFamily,size:FontSize = .custom(0.0),color:UIColor = .black){
        setFont(sender, style: fontFamiy.value, size: size.value,color:color)
    }
    //////////////////////////////////////////////////////////////////
    fileprivate class func setFont(_ sender: UIView,style:String,size:CGFloat,color:UIColor){
        if let element = sender as? UILabel {
            element.font = UIFont(name: style, size: size != 0.0 ? size : element.font.pointSize)
            element.textColor = color != .black ? color : .black
        }else if let element = sender as? UITextField {
            element.font = UIFont(name: style, size: (size != 0.0 ? size : element.font?.pointSize)!)
            element.textColor = color != .black ? color : .black
        }else if let element = sender as? UIButton {
            element.titleLabel?.font = UIFont(name: style, size: (size != 0.0 ? size : element.titleLabel?.font.pointSize)!)
            element.setTitleColor(color != .black ? color : .black, for: .normal)
        }else if let element = sender as? UITextView{
            element.textColor = color
            element.font = UIFont(name: style, size: size)
        }
    }
    
     class func nsmutableAttributedString(string:String,fontFamily:FontFamily,size:FontSize,color:UIColor)->NSMutableAttributedString{
        return NSMutableAttributedString(string: string, attributes: [NSAttributedString.Key.font:UIFont(name: fontFamily.value, size: size.value)!,NSAttributedString.Key.foregroundColor:color])
    }
}
