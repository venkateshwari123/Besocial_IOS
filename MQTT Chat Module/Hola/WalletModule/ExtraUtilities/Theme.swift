//
//  ThemeClass.swift
//  Yelo
//
//  Created by 3Embed on 8/30/19.
//  Copyright © 2019 rahulSharma. All rights reserved.
//

import UIKit

import UIKit
class StyleClass {
    private var fontName : String!
    private var fontSize : CGFloat!
    private var textColor : UIColor!
    private var backgroundColor : UIColor!
    
    init(fontName : String , fontSize : CGFloat , textColor : UIColor? , backgroundColor : UIColor? ) {
        self.fontName = fontName
        self.fontSize = fontSize
        self.textColor = textColor
        self.backgroundColor = backgroundColor
    }
    
    func getFont() -> UIFont{
        return UIFont(name: fontName!, size: fontSize!)!
    }
    func getTextColor() -> UIColor{
        return textColor
    }
    func getBackgroundColor() -> UIColor{
        return backgroundColor
    }
}


class AttributedTextStyleClass {
    private var attritbutedText : String!
    private var style : StyleClass!
    private var attritbutedTextColor : UIColor?
    
    init( attritbutedText : String , style : StyleClass , attritbutedTextColor : UIColor) {
        self.style = style
        self.attritbutedTextColor = attritbutedTextColor
        self.attritbutedText = attritbutedText
    }
    
    func getStyleClass() -> StyleClass{
        return style
    }
    
    func getAttritbutedTextColor() -> UIColor?{
        return attritbutedTextColor
    }
    func getAttritbutedText() -> String{
        return attritbutedText
    }

}



class Theme{
    private static var sharedInstance : Theme!
    
    
    private init(){}
    
    public static func getInstance()-> Theme{
        if sharedInstance == nil {
            sharedInstance = Theme()
        }
        return sharedInstance
    }

    let attributeCornerRadius : CGFloat = 5.0
    
    /// login
    
    let LoginVCForgotButtonStyle = StyleClass(fontName: "CenturyGothic", fontSize: 13, textColor: UIColor.colorWithHex(color: Colors.APPBaseColorLight), backgroundColor: .white)
    
    /// signup
    let sighUpLoginTextButton = StyleClass(fontName: "CenturyGothic", fontSize: 15, textColor: .gray , backgroundColor: .white)
    let sighUpLableTextStyle = StyleClass(fontName: "CenturyGothic", fontSize: 13, textColor: .gray , backgroundColor: .white)
    let sighUpLableTextStyle1 = StyleClass(fontName: "CenturyGothic", fontSize: 13, textColor: .lightGray , backgroundColor: .white)
    let sighUpInviteStyle = StyleClass(fontName: "CenturyGothic", fontSize: 12, textColor: .black , backgroundColor: .white)
  
    /// profileTopCell editButton textStyle
    let profileEditButtonStyle = StyleClass(fontName: "CenturyGothic", fontSize: 14, textColor: .white, backgroundColor: .black)
    let navBarTitleStyle = StyleClass(fontName: "CenturyGothic", fontSize: 20, textColor: .black, backgroundColor: .white)
    
    /// password reset
    
      let passwordResetButtonStyle = StyleClass(fontName: "CenturyGothic", fontSize: 13, textColor: .white, backgroundColor: UIColor.colorWithHex(color: Colors.APPBaseColorLight))
  
    
    // editProfileVC
    /// EditProfile TextFeild Fonts and size
    let editProfileTextFieldStyle = StyleClass(fontName: "CenturyGothic", fontSize: 15, textColor: .black, backgroundColor: .white)
    
    /// EditProfile placeHolder Fonts and size
    let editProfilePlaceholderStyle = StyleClass(fontName: "CenturyGothic", fontSize: 10, textColor: .black, backgroundColor: .white)
    let editProfileUnsubscribeStyle = StyleClass(fontName: "CenturyGothic", fontSize: 11, textColor: .lightGray, backgroundColor: .white)
    let editProfileUpdate = StyleClass(fontName: "CenturyGothic", fontSize: 14, textColor: .white, backgroundColor: UIColor.colorWithHex(color: Colors.APPBaseColorLight))
    
    // categoryVC
    /// Category VC heading fonts and size
    let categoryVCHeadingStyle = StyleClass(fontName: "CenturyGothic", fontSize: 15, textColor: .black, backgroundColor: .white)
    
     let categoryTitle = StyleClass(fontName: "CenturyGothic" , fontSize: 13, textColor: .darkGray, backgroundColor: .white)
    
    /// Category VC sub-Heading fonts and size
    let categoryVCSubTextStyle = StyleClass(fontName: "CenturyGothic", fontSize: 12, textColor: .black, backgroundColor: .white)
    
    
    let errorLabelStyle = StyleClass(fontName: "CenturyGothic" , fontSize: 11, textColor: #colorLiteral(red: 0.9607843137, green: 0.4078431373, blue: 0.3764705882, alpha: 1), backgroundColor: .white)
    // menu vc
    let appBottomButtonStyle = StyleClass(fontName: "CenturyGothic" , fontSize: 11, textColor: .black, backgroundColor: .white)
    let appBottomButtonTappedStyle = StyleClass(fontName: "CenturyGothic" , fontSize: 11, textColor: UIColor.colorWithHex(color: Colors.AppBaseColor), backgroundColor: .white)
    
    // main home page
    
    let mainHomePageButtonStyle = StyleClass(fontName: "CenturyGothic" , fontSize: 16, textColor: Colors.attributeBorderColor, backgroundColor: .white)
    
    let mainHPSearchPlaceHolderStyle = StyleClass(fontName: "CenturyGothic-Bold", fontSize: 15, textColor: .black, backgroundColor: .white)
    
    let menuTitleStyle = StyleClass(fontName: "CenturyGothic", fontSize: 15, textColor: .darkGray, backgroundColor: .white)
    let badgeStyle = StyleClass(fontName: "CenturyGothic", fontSize: 13, textColor: .white, backgroundColor: #colorLiteral(red: 0.9607843137, green: 0.4078431373, blue: 0.3764705882, alpha: 1))
    
    let mainHomeHeadingStyle = StyleClass(fontName: "CenturyGothic" , fontSize: 16, textColor: Colors.attributeBorderColor, backgroundColor: .white)
    
    let homeVCLocationLbllStyle = StyleClass(fontName: "CenturyGothic" , fontSize: 11, textColor: .white, backgroundColor: .white)

    let homeVCPriceLblStyle = StyleClass(fontName: "CenturyGothic" , fontSize: 14, textColor: .gray, backgroundColor: .white)
    
    let homeVCPoductTitleStyle = StyleClass(fontName: "CenturyGothic" , fontSize: 14, textColor: .black, backgroundColor: .white)
    
    
    // changepasssword vc
    let changePasswordHeaderStyle = StyleClass(fontName: "CenturyGothic" , fontSize: 18, textColor: .black, backgroundColor: .white)
    
    let changePasswordDisStyle = StyleClass(fontName: "CenturyGothic" , fontSize: 13, textColor: .gray, backgroundColor: .white)
    
     let changePasswordDisStyle1 = StyleClass(fontName: "CenturyGothic" , fontSize: 13, textColor: UIColor.colorWithHex(color: Colors.APPBaseColorLight) , backgroundColor: .white)
    
    let changePasswordButtonStyle = StyleClass(fontName: "CenturyGothic" , fontSize: 14, textColor: .white, backgroundColor: UIColor.colorWithHex(color: Colors.APPBaseColorLight) )
    
    
    // passwordRecoverVC
    let pswdRecoverHeaderStyle = StyleClass(fontName: "CenturyGothic" , fontSize: 24, textColor : #colorLiteral(red: 0.2431372549, green: 0.2901960784, blue: 0.3490196078, alpha: 1), backgroundColor: .white)
    
    let pswdRecoverSubHeadingStyle = StyleClass(fontName: "CenturyGothic", fontSize: 14, textColor: .gray, backgroundColor: .white)
    
    // updateAlertVC
    let updateAlertStyle = StyleClass(fontName: "CenturyGothic" , fontSize: 13, textColor: .black, backgroundColor: .white)
    
    // categoryVC
   
    let subCategoryTitle = StyleClass(fontName: "CenturyGothic" , fontSize: 14, textColor: .darkGray, backgroundColor: .white)
    
    // postingVC
    let seletedCellStyle = StyleClass(fontName: "CenturyGothic", fontSize: 15, textColor: .white, backgroundColor: Colors.attributeBorderColor)
    let deSeletedCellStyle = StyleClass(fontName: "CenturyGothic", fontSize: 14, textColor: .black, backgroundColor: .white)
    
    let postHeaderStyle = StyleClass(fontName: "CenturyGothic", fontSize: 16, textColor: Colors.attributeBorderColor, backgroundColor: .white)
    
    let postHeaderStyle25 = StyleClass(fontName: "CenturyGothic-Bold", fontSize: 25, textColor: Colors.attributeBorderColor , backgroundColor: .white)
    
    let postHeaderStyle18 = StyleClass(fontName: "CenturyGothic", fontSize: 18, textColor: Colors.attributeBorderColor , backgroundColor: .white)
    
    let postHeaderStyle12 = StyleClass(fontName: "CenturyGothic", fontSize: 12, textColor: Colors.attributeBorderColor , backgroundColor: .white)
    
    let attributeTitleStyle = StyleClass(fontName: "CenturyGothic", fontSize: 14, textColor: .gray, backgroundColor: .white)
    
     let attributeUnitStyle = StyleClass(fontName: "CenturyGothic", fontSize: 12, textColor: .gray, backgroundColor: .white)
    //mainHomePageButtonStyle
    
    
    // filterVC
    
    let filterAttHeaderStyle = StyleClass(fontName: "CenturyGothic-Bold", fontSize: 18, textColor: Colors.attributeBorderColor, backgroundColor: .white)
    
     let headerButtonStyle = StyleClass(fontName: "CenturyGothic", fontSize: 14, textColor: UIColor.colorWithHex(color: Colors.AppBaseColor), backgroundColor: .white)
    
    let discriptionStyle  = StyleClass(fontName: "CenturyGothic" , fontSize: 14, textColor : Colors.attributeBorderColor, backgroundColor: .white)
    
    // reportVC
    
    let reportVCsubHeaderStyle  = StyleClass(fontName: "CenturyGothic" , fontSize: 13, textColor : Colors.reportVCSubHeaderClr, backgroundColor: .white)
    
    let reportVCHeaderStyle = StyleClass(fontName: "CenturyGothic-Bold", fontSize: 16, textColor: #colorLiteral(red: 0.1411764706, green: 0.2117647059, blue: 0.3098039216, alpha: 1), backgroundColor: .white)
    
     
    
    let report_Options = StyleClass(fontName: "CenturyGothic", fontSize: 15, textColor: #colorLiteral(red: 0.1411764706, green: 0.2117647059, blue: 0.3098039216, alpha: 1), backgroundColor: .white)
    let reportVC_SubmitStyle = StyleClass(fontName: "CenturyGothic", fontSize: 16, textColor: .white, backgroundColor: UIColor.colorWithHex(color: Colors.AppBaseColor))
    
    let reportVC_questionStyle = StyleClass(fontName: "CenturyGothic", fontSize: 16, textColor: #colorLiteral(red: 0.1411764706, green: 0.2117647059, blue: 0.3098039216, alpha: 1), backgroundColor: .white )
    

       //ProfileVC
       
    let headerCellStyle = StyleClass(fontName: "CenturyGothic", fontSize: 13, textColor: .black, backgroundColor: .white)
       
    let selectedHeaderCellStyle = StyleClass(fontName: "CenturyGothic", fontSize: 13, textColor: Colors.attributeBorderColor, backgroundColor: .white)
       
    let followCountStyle = StyleClass(fontName: "CenturyGothic-Bold" , fontSize: 14, textColor: Colors.attributeBorderColor, backgroundColor: .white)
    
    let followLabelStyle = StyleClass(fontName: "CenturyGothic" , fontSize: 14, textColor: Colors.attributeBorderColor, backgroundColor: .white)
    
       
    let bioLabelStyle = StyleClass(fontName: "CenturyGothic", fontSize: 11, textColor:.black, backgroundColor: .white)
       

       
    let commentTitleStyle = StyleClass(fontName: "CenturyGothic" , fontSize: 13, textColor: .gray, backgroundColor: .white)
       
       //Product Cell
    let productLocationStyle = StyleClass(fontName: "CenturyGothic", fontSize: 10, textColor: .white, backgroundColor: .clear)
    
    let productEditButton = StyleClass(fontName: "CenturyGothic" , fontSize: 15, textColor: Colors.attributeBorderColor, backgroundColor: .white)
 
       // Setting VC
    let SettingOption =   StyleClass(fontName: "CenturyGothic", fontSize: 14, textColor: Colors.attributeBorderColor, backgroundColor: .white)
 
       
    let settingTextfieldStyle =  StyleClass(fontName: "CenturyGothic", fontSize: 16, textColor: Colors.attributeBorderColor, backgroundColor: .white)
       
    let settingPlaceHolderStyle =  StyleClass(fontName: "CenturyGothic", fontSize: 14, textColor: Colors.placeHolderGray, backgroundColor: .white)
    
    let productPriceStyle = StyleClass(fontName: "CenturyGothic" , fontSize: 11, textColor: Colors.productPriceGray, backgroundColor: .white)
    
    let commentUserNameStyle = StyleClass(fontName: "CenturyGothic-Bold", fontSize: 15, textColor: Colors.commentTitalText, backgroundColor: .white)
    
    let exchangeRateButtonStyle = StyleClass(fontName: "CenturyGothic", fontSize: 10, textColor: .white, backgroundColor: Colors.exchangeBtnBackground)
    
    let updatePasswordPlaceHolderStyle =  StyleClass(fontName: "CenturyGothic", fontSize: 12, textColor: Colors.placeHolderGray, backgroundColor: .white)
    
    let emailLabelStyle = StyleClass(fontName: "CenturyGothic", fontSize: 11, textColor:Colors.lightBlue, backgroundColor: .white)
    
    let raingCountLabelStyle = StyleClass(fontName: "CenturyGothic", fontSize: 12, textColor:Colors.ratingCountGray, backgroundColor: .white)
    
    let popupMessageStyle  = StyleClass(fontName: "CenturyGothic" , fontSize: 14, textColor : Colors.placeHolderGray, backgroundColor: .white)
    
    let likerViewersNameStyle = StyleClass.init(fontName: "CenturyGothic", fontSize: 13, textColor: Colors.attributeBorderColor, backgroundColor: .white)
    
    let markAsSoldUserLabelStyle = StyleClass(fontName: "CenturyGothic", fontSize: 14, textColor: .black, backgroundColor: .white)
    
    let uploadedTextStyle = StyleClass(fontName: "CenturyGothic" , fontSize: 19, textColor: UIColor.colorWithHex(color: "040404"), backgroundColor: .white)
    
    let subHeadingTextStytle = StyleClass(fontName: "CenturyGothic", fontSize: 12, textColor: Colors.subHeadingColor, backgroundColor: .white)
    
    let insightsCounterLabelStyle = StyleClass(fontName: "CenturyGothic-Bold", fontSize: 22, textColor: Colors.attributeBorderColor , backgroundColor: .clear)
    
    //promotion Screen
    
    let promotionHeaderCellStyle = StyleClass(fontName: "CenturyGothic", fontSize: 14, textColor: .black, backgroundColor: .white)
    
     let promotionHeaderStyle = StyleClass(fontName: "CenturyGothic-Bold", fontSize: 20, textColor: Colors.attributeBorderColor , backgroundColor: .white)
    
    let promotionPriceLabelStyle = StyleClass(fontName: "CenturyGothic-Bold", fontSize: 22, textColor: Colors.attributeBorderColor , backgroundColor: .white)
    
    let promotionFooterLabelStyle = StyleClass(fontName: "CenturyGothic-Bold", fontSize: 13, textColor: Colors.attributeBorderColor, backgroundColor: .white)
    
    let promotionFooterButtonStyle = StyleClass(fontName: "CenturyGothic", fontSize: 13, textColor: Colors.attributeBorderColor, backgroundColor: .white)
    
    let noItemsYetLabelStyle = StyleClass(fontName: "CenturyGothic" , fontSize: 12, textColor: Colors.attributeBorderColor, backgroundColor: .white)

    let noItemDescLabelStyle = StyleClass(fontName: "CenturyGothic" , fontSize: 12, textColor: Colors.attributeBorderColor, backgroundColor: .white)
    
    let promotionBuyButtonStyle = StyleClass(fontName: "CenturyGothic" , fontSize: 16, textColor: .white, backgroundColor: .white)
    
    //sideMenu
    let sideMenuItemStylr = StyleClass(fontName: "CenturyGothic" , fontSize: 15, textColor: Colors.attributeBorderColor, backgroundColor: .white)
    
    
    let userNameLabelStyle = StyleClass(fontName: "CenturyGothic", fontSize: 15, textColor: Colors.attributeBorderColor, backgroundColor: .white)
    
    let menuBottomButtonStyle = StyleClass(fontName: "CenturyGothic" , fontSize: 13, textColor:  Colors.attributeBorderColor, backgroundColor: .white)
    
    let notificationCounterLabelStyle = StyleClass(fontName: "CenturyGothic" , fontSize: 15, textColor:  .white, backgroundColor: .clear)
    
    let sideMenuLoginbuttonStyle = StyleClass(fontName: "CenturyGothic" , fontSize: 18, textColor: Colors.attributeBorderColor, backgroundColor: .white)
    
    let sideMenuLoginbuttonBlueStyle = StyleClass(fontName: "CenturyGothic" , fontSize: 18, textColor: Colors.lightBlue, backgroundColor: .white)
    
    
    //New Home
      let homeSearchPlaceHolderStyle = StyleClass(fontName: "CenturyGothic", fontSize: 14, textColor: .white, backgroundColor: .black)
    let homeProductHeaderLabelStyle = StyleClass(fontName: "CenturyGothic-Bold", fontSize: 15, textColor: Colors.attributeBorderColor, backgroundColor: .white)
    
    //Add Comment
    let navBartitleStyle = StyleClass(fontName: "CenturyGothic" , fontSize: 16, textColor: Colors.attributeBorderColor, backgroundColor: .white)
    
     let navBartitleStyle2 = StyleClass(fontName: "CenturyGothic" , fontSize: 18, textColor: Colors.attributeBorderColor, backgroundColor: .white)
    //Comments
     let commentsTextStyle = StyleClass(fontName: "CenturyGothic", fontSize: 15, textColor: .black, backgroundColor: .white)
    
    //PDP
    let showMoreCommentButtonStyle = StyleClass(fontName: "CenturyGothic", fontSize: 16, textColor: Colors.lightBlue, backgroundColor: .white)
    
    //appNotification
     let appNotificationTextStyle = StyleClass(fontName: "CenturyGothic", fontSize: 14, textColor: #colorLiteral(red: 0.5450980392, green: 0.5843137255, blue: 0.6039215686, alpha: 1), backgroundColor: .white)
    
    let AppNotificationTimeStampStyle = StyleClass(fontName: "CenturyGothic" , fontSize: 12, textColor: #colorLiteral(red: 0.003921568627, green: 0.1215686275, blue: 0.2470588235, alpha: 1), backgroundColor: .white)
    
    //makeOffer Screen
    let makeOfferLastPriceStyle = StyleClass(fontName: "CenturyGothic", fontSize: 13, textColor: #colorLiteral(red: 0.5450980392, green: 0.5843137255, blue: 0.6039215686, alpha: 1), backgroundColor: .white)
    
    let makeOfferPlaceHolderStyle = StyleClass(fontName: "CenturyGothic", fontSize: 13, textColor: #colorLiteral(red: 0.5450980392, green: 0.5843137255, blue: 0.6039215686, alpha: 1), backgroundColor: .white)
    
    //Delete Profile Screen
    
    let deleteProfileDeleteButttonStyle = StyleClass(fontName: "CenturyGothic", fontSize: 18, textColor: Colors.attributeBorderColor, backgroundColor: .white)
    
    let deleteProfileCancelButttonStyle = StyleClass(fontName: "CenturyGothic", fontSize: 18, textColor: .white, backgroundColor: Colors.lightBlue)
    
    let becomePromoterDescriptionStyle = StyleClass(fontName: "CenturyGothic" , fontSize: 15, textColor: Colors.attributeBorderColor, backgroundColor: .white)
    
    let becomePromoterBottomTextLabelStyle = StyleClass(fontName: "CenturyGothic" , fontSize: 11, textColor: Colors.attributeBorderColor, backgroundColor: .white)
    
     let sucessProductUploadTextStyle = StyleClass(fontName: "CenturyGothic-Bold", fontSize: 14, textColor: Colors.attributeBorderColor, backgroundColor: .white)
    
    //add address screen
    
    let addAddressButtonStyle = StyleClass(fontName: "CenturyGothic" , fontSize: 15, textColor: .white, backgroundColor: UIColor.colorWithHex(color: Colors.APPBaseColorLight) )
    
    let addAddressTitleLabelStyle = StyleClass(fontName: "CenturyGothic", fontSize: 19, textColor: .black, backgroundColor: .white)
    
    let addAddressSubTitleLabelStyle = StyleClass(fontName: "CenturyGothic", fontSize: 17, textColor: .lightGray, backgroundColor: Colors.lightBlue)
    
    let addAddressPinCodeLabelStyle = StyleClass(fontName: "CenturyGothic" , fontSize: 17, textColor: .black, backgroundColor: .white)
    
    let addAddressDefaultLabelStyle = StyleClass(fontName: "CenturyGothic" , fontSize: 15, textColor: .systemBlue, backgroundColor: .white)
    
    //for no data label
    
    let noLabelStyle = StyleClass(fontName: "CenturyGothic" , fontSize: 15, textColor: .black, backgroundColor: .white)
    
    //for wallet screen
    
    let balanceTitleLabel = StyleClass(fontName: "CenturyGothic", fontSize: 15, textColor: .systemGreen, backgroundColor: .white)
    
    let pendingTitleLabel = StyleClass(fontName: "CenturyGothic", fontSize: 15, textColor: .systemRed, backgroundColor: .white)
    
    let amountLabel = StyleClass(fontName: "CenturyGothic-Bold", fontSize: 24, textColor: .darkGray, backgroundColor: .white)
    
    let amountButton = StyleClass(fontName: "CenturyGothic", fontSize: 17, textColor: .white, backgroundColor: nil)
    
    //tableview wallet
    let transactionTimeStampStyle = StyleClass(fontName: "CenturyGothic", fontSize: 12, textColor: #colorLiteral(red: 0.7169507146, green: 0.7170528769, blue: 0.7169185281, alpha: 1), backgroundColor: .white)
    
    
    let transactionTitleLabel = StyleClass(fontName: "CenturyGothic", fontSize: 14, textColor: #colorLiteral(red: 0.2815778553, green: 0.28162238, blue: 0.2815638185, alpha: 1), backgroundColor: .white)
    
    let transactionAmountLabel = StyleClass(fontName: "CenturyGothic-Bold", fontSize: 14, textColor:  #colorLiteral(red: 0.2815778553, green: 0.28162238, blue: 0.2815638185, alpha: 1), backgroundColor: .white)
    
     let transactionStatusStyle = StyleClass(fontName: "CenturyGothic", fontSize: 12, textColor: #colorLiteral(red: 0.2692596316, green: 0.5920466185, blue: 0.9408026934, alpha: 1), backgroundColor: .white)
    
    let alertLabel = StyleClass(fontName: "CenturyGothic", fontSize: 16, textColor: UIColor(named: "#2C3339D1"), backgroundColor: .white)
    
    //qrcode screen
    let QRCodeButton = StyleClass(fontName: "CenturyGothic", fontSize: 15, textColor: nil, backgroundColor: nil)
    
    let soldProductStype = StyleClass(fontName: "CenturyGothic-Bold", fontSize: 18, textColor: #colorLiteral(red: 0.925612092, green: 0.1714008451, blue: 0, alpha: 1), backgroundColor: nil)
    
    let updatePostPromotionStyle = StyleClass(fontName: "CenturyGothic-Bold", fontSize: 13, textColor: Colors.attributeBorderColor , backgroundColor: .white)
    
    let updatePostCurrentPromotionStyle = StyleClass(fontName: "CenturyGothic-Bold", fontSize: 16, textColor: #colorLiteral(red: 0.1411764706, green: 0.2117647059, blue: 0.3098039216, alpha: 1), backgroundColor: .white)
    
     let walletCardNoStyle = StyleClass(fontName: "CenturyGothic", fontSize: 15, textColor: #colorLiteral(red: 0.02532849461, green: 0.02533653937, blue: 0.02532595955, alpha: 1), backgroundColor: .white)
    
     let walletBankNoNoStyle = StyleClass(fontName: "CenturyGothic", fontSize: 16, textColor: #colorLiteral(red: 0.02532849461, green: 0.02533653937, blue: 0.02532595955, alpha: 1), backgroundColor: .white)
    
    let walletRechargeAmountStyle = StyleClass(fontName: "CenturyGothic", fontSize: 30, textColor: #colorLiteral(red: 0.02532849461, green: 0.02533653937, blue: 0.02532595955, alpha: 1), backgroundColor: .white)
    
    let rechargeSuccessPlaceHolderStyle = StyleClass(fontName: "CenturyGothic", fontSize: 16, textColor: #colorLiteral(red: 0.6039215686, green: 0.6039215686, blue: 0.6039215686, alpha: 1), backgroundColor: .white)
    
    let rechargeSuccessDetailPlaceHolderStyle = StyleClass(fontName: "CenturyGothic", fontSize: 14, textColor: #colorLiteral(red: 0.6039215686, green: 0.6039215686, blue: 0.6039215686, alpha: 1), backgroundColor: .white)
    
     let rechargeSuccessDetailStyle = StyleClass(fontName: "CenturyGothic", fontSize: 16, textColor: #colorLiteral(red: 0.2823529412, green: 0.2823529412, blue: 0.2823529412, alpha: 1), backgroundColor: .white)
    
    let walletTransactionButtonStyle = StyleClass(fontName: "CenturyGothic", fontSize: 14, textColor: #colorLiteral(red: 0.5098039216, green: 0.7411764706, blue: 0.9568627451, alpha: 1), backgroundColor: .white)
    
     let withdrawLabelStyle = StyleClass(fontName: "CenturyGothic", fontSize: 14, textColor: #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1), backgroundColor: .white)
    
    let withdrawAmountLabelStyle = StyleClass(fontName: "CenturyGothic-Bold", fontSize: 22, textColor: #colorLiteral(red: 0.2745098039, green: 0.2745098039, blue: 0.2745098039, alpha: 1), backgroundColor: .white)
    
     let withdrawMethodsLabelStyle = StyleClass(fontName: "CenturyGothic-Bold", fontSize: 16, textColor: #colorLiteral(red: 0.2823529412, green: 0.2823529412, blue: 0.2823529412, alpha: 1), backgroundColor: .white)
    
     let withdrawLogButtonStyle = StyleClass(fontName: "CenturyGothic", fontSize: 15, textColor: #colorLiteral(red: 0.2862745098, green: 0.6705882353, blue: 0.9529411765, alpha: 1), backgroundColor: .white)
    
    let withdrawLogIdStyle = StyleClass(fontName: "CenturyGothic", fontSize: 12, textColor: #colorLiteral(red: 0.6039215686, green: 0.6039215686, blue: 0.6039215686, alpha: 1), backgroundColor: .white)
    
     let withdrawLogTitleStyle = StyleClass(fontName: "CenturyGothic", fontSize: 14, textColor: #colorLiteral(red: 0.2823529412, green: 0.2823529412, blue: 0.2823529412, alpha: 1), backgroundColor: .white)
    
    let rechargeDetailsAmountLabelStyle = StyleClass(fontName: "CenturyGothic-Bold", fontSize: 30, textColor: #colorLiteral(red: 0.2901960784, green: 0.231372549, blue: 0.231372549, alpha: 1), backgroundColor: .white)
    
    let rechargeDetailsFromAndToNameStyle = StyleClass(fontName: "CenturyGothic", fontSize: 16, textColor: #colorLiteral(red: 0.6039215686, green: 0.6039215686, blue: 0.6039215686, alpha: 1), backgroundColor: .white)
    
    //profile screen user rating and review
    let topRatingLabelStyle = StyleClass(fontName: "CenturyGothic-Bold", fontSize: 35, textColor: .black, backgroundColor: .white)
    

    let staticLabelStyle = StyleClass(fontName: "CenturyGothic", fontSize: 16, textColor: #colorLiteral(red: 0.6039215686, green: 0.6039215686, blue: 0.6039215686, alpha: 1), backgroundColor: .white)
     
     let valuesLabelStyle = StyleClass(fontName: "CenturyGothic", fontSize: 16, textColor: UIColor.hexStringToUIColor(hex: "#333333"), backgroundColor: .white)
     
     let tableViewTitleLabelStyle = StyleClass(fontName: "CenturyGothic", fontSize: 16, textColor: #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1), backgroundColor: .white)
     
     let tableViewTimeStampLabelStyle = StyleClass(fontName: "CenturyGothic", fontSize: 14, textColor: #colorLiteral(red: 0.7176470588, green: 0.7176470588, blue: 0.7176470588, alpha: 1), backgroundColor: .white)
    
    let selectedButtonStyle = StyleClass(fontName: "CenturyGothic", fontSize: 13, textColor: UIColor.hexStringToUIColor(hex: "#49ABF3"), backgroundColor: .white)
                                            
    let notSelectedButtonStyle = StyleClass(fontName: "CenturyGothic", fontSize: 13, textColor: UIColor.hexStringToUIColor(hex: "#D6D6D6"), backgroundColor: .white)
    
    let ratingLabelStyle = StyleClass(fontName: "CenturyGothic-Bold", fontSize: 25, textColor: .black, backgroundColor: .white)
    
    let reviewCountLabelStyle = StyleClass(fontName: "CenturyGothic", fontSize: 11, textColor: UIColor.hexStringToUIColor(hex: "#495055"), backgroundColor: .white)
    
    let reviewLabelStyle = StyleClass(fontName: "CenturyGothic-Bold", fontSize: 14, textColor: .black, backgroundColor: .white)
    
    let sortButtonStyle = StyleClass(fontName: "CenturyGothic", fontSize: 12, textColor: UIColor.hexStringToUIColor(hex: "#49ABF3"), backgroundColor: .white)
    
    let categoryLabelStyle = StyleClass(fontName: "CenturyGothic", fontSize: 12, textColor: .black, backgroundColor: .white)
    
    let reviewNameLabelStyle = StyleClass(fontName: "CenturyGothic-Bold", fontSize: 14, textColor: UIColor.hexStringToUIColor(hex: "#484848"), backgroundColor: .white)
    
    let reviewTimeStampStyle = StyleClass(fontName: "CenturyGothic", fontSize: 10, textColor: UIColor.hexStringToUIColor(hex: "#B2B2B2"), backgroundColor: .white)
    
    let ratingCountLabelStyle = StyleClass(fontName: "CenturyGothic-Bold", fontSize: 15, textColor: UIColor.hexStringToUIColor(hex: "#484848"), backgroundColor: .white)
    
    let reviewtextStyle = StyleClass(fontName: "CenturyGothic", fontSize: 14, textColor: .black, backgroundColor: .white)
    
    //sorting screen
    let reviewSortFilterLabelStyle = StyleClass(fontName: "CenturyGothic", fontSize: 16, textColor: .hexStringToUIColor(hex: "#011F3FD1"), backgroundColor: .white)
    
    let dateTextFieldStyle = StyleClass(fontName: "CenturyGothic", fontSize: 16, textColor: .hexStringToUIColor(hex: "#011F3FD1"), backgroundColor: .white)
    
    let saveButtonStyle = StyleClass(fontName: "CenturyGothic", fontSize: 12, textColor: .white, backgroundColor: .hexStringToUIColor(hex: "#88D1FD"))
    
}


