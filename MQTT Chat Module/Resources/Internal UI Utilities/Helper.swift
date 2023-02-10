//
//  Helper.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 19/07/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDynamicLinks
import PhoneNumberKit
import LatLongToTimezone
import CoreLocation
import Reachability
import Photos

struct AppColourStr {
    
    
    static let tickColor = UIColor.init(red: (211/255), green: (98/255), blue: (58/255), alpha: 1)
    static let mainColor = UIColor.init(red: 0.1, green: 0.42, blue: 0.95, alpha: 1)
    static let themeColor = UIColor.black
    static let appColor = AppConstants.appType == .picoadda ? "#FF0F56" : "#FF0F56"
    static let secondoryAPPColor = AppConstants.appType == .picoadda ? "#FF0F56" : "#FF0F56"
    static let followColor = AppConstants.appType == .picoadda ? "#FF0F56" : "#FF0F56"
    static let lightGrayColor = "#9A9A9A"
    static let darkGrayColor = "#555555"
    static let whiteColor = "#FFFFFF"
    static let gradientLeftColor = AppConstants.appType == .picoadda ? "#FF0F56" : "#FF0F56"
    static let gradientRightColor = AppConstants.appType == .picoadda ? "#FF0F56" : "#FF0F56"
    static let lightColor = "#8F8F8F"
    static let cardBackground = "#E2F4FF"
    static let descriptionLabel = "#292929"
    static let disableCard = "#D9D9D9"
    static let headerbackground = "#F8F6F6"
    static let inputToolBarBackground = "#EBEBEB"
    static let lightGray = "#9AA4B4"
    static let lightWhite = "#FAFAFA"
    static let loginTxtBackground = "#C6D1E3"
    static let picoaddaHeadingLabel = "#260B0B"
    static let settingTitlelabel = "#5F5F5F"
    static let textColor = "#10141C"
    static let blackColor = "#000000"
}

class Helper {
    static var navigationController:UINavigationController?
    static var toastView = UIView()
    static var toastViewLabel = UILabel()
    static var rxalmofire = RxAlmofireClass()
    
    static func measureHeightLabel(label:UILabel,width:CGFloat) -> CGFloat {
        label.numberOfLines = 0
        label.sizeToFit()
        return label.frame.height
    }
    
    class func isValidEmail(emailText: String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emailText)
    }
    
    class func GetCountryCallingCode(countryRegionCode:String) -> String {
        
        let prefixCodes = ["AF": "+93", "AE": "+971", "AL": "+355", "AN": "+599", "AS":"+1", "AD": "+376", "AO": "+244", "AI": "+1", "AG":"+1", "AR": "+54","AM": "+374", "AW": "+297", "AU":"+61", "AT": "+43","AZ": "+994", "BS": "+1", "BH":"+973", "BF": "+226","BI": "+257", "BD": "+880", "BB": "+1", "BY": "+375", "BE":"+32","BZ": "+501", "BJ": "+229", "BM": "+1", "BT":"+975", "BA": "+387", "BW": "+267", "BR": "+55", "BG": "+359", "BO": "+591", "BL": "+590", "BN": "+673", "CC": "+61", "CD":"+243","CI": "+225", "KH":"+855", "CM": "+237", "CA": "+1", "CV": "+238", "KY":"+345", "CF":"+236", "CH": "+41", "CL": "+56", "CN":"+86","CX": "+61", "CO": "+57", "KM": "+269", "CG":"+242", "CK": "+682", "CR": "+506", "CU":"+53", "CY":"+537","CZ": "+420", "DE": "+49", "DK": "+45", "DJ":"+253", "DM": "+1", "DO": "+1", "DZ": "+213", "EC": "+593", "EG":"+20", "ER": "+291", "EE":"+372","ES": "+34", "ET": "+251", "FM": "+691", "FK": "+500", "FO": "+298", "FJ": "+679", "FI":"+358", "FR": "+33", "GB":"+44", "GF": "+594", "GA":"+241", "GS": "+500", "GM":"+220", "GE":"+995","GH":"+233", "GI": "+350", "GQ": "+240", "GR": "+30", "GG": "+44", "GL": "+299", "GD":"+1", "GP": "+590", "GU": "+1", "GT": "+502", "GN":"+224","GW": "+245", "GY": "+595", "HT": "+509", "HR": "+385", "HN":"+504", "HU": "+36", "HK": "+852", "IR": "+98", "IM": "+44", "IL": "+972", "IO":"+246", "IS": "+354", "IN": "+91", "ID":"+62", "IQ":"+964", "IE": "+353","IT":"+39", "JM":"+1", "JP": "+81", "JO": "+962", "JE":"+44", "KP": "+850", "KR": "+82","KZ":"+77", "KE": "+254", "KI": "+686", "KW": "+965", "KG":"+996","KN":"+1", "LC": "+1", "LV": "+371", "LB": "+961", "LK":"+94", "LS": "+266", "LR":"+231", "LI": "+423", "LT": "+370", "LU": "+352", "LA": "+856", "LY":"+218", "MO": "+853", "MK": "389", "MG":"+261", "MW": "+265", "MY": "+60","MV": "+960", "ML":"+223", "MT": "+356", "MH": "+692", "MQ": "+596", "MR":"+222", "MU": "+230", "MX": "+52","MC": "+377", "MN": "+976", "ME": "+382", "MP": "+1", "MS": "+1", "MA":"+212", "MM": "+95", "MF": "+590", "MD":"+373", "MZ": "+258", "NA":"+264", "NR":"+674", "NP":"+977", "NL": "+31","NC": "+687", "NZ":"+64", "NI": "+505", "NE": "+227", "NG": "+234", "NU":"+683", "NF": "+672", "NO": "+47","OM": "+968", "PK": "+92", "PM": "+508", "PW": "+680", "PF": "+689", "PA": "+507", "PG":"+675", "PY": "+595", "PE": "+51", "PH": "+63", "PL":"+48", "PN": "+872","PT": "+351", "PR": "+1","PS": "+970", "QA": "+974", "RO":"+40", "RE":"+262", "RS": "+381", "RU": "+7", "RW": "+250", "SM": "+378", "SA":"+966", "SN": "+221", "SC": "+248", "SL":"+232","SG": "+65", "SK": "+421", "SI": "+386", "SB":"+677", "SH": "+290", "SD": "+249", "SR": "+597","SZ": "+268", "SE":"+46", "SV": "+503", "ST": "+239","SO": "+252", "SJ": "+47", "SY":"+963", "TW": "+886", "TZ": "+255", "TL": "+670", "TD": "+235", "TJ": "+992", "TH": "+66", "TG":"+228", "TK": "+690", "TO": "+676", "TT": "+1", "TN":"+216","TR": "+90", "TM": "+993", "TC": "+1", "TV":"+688", "UG": "+256", "UA": "+380", "US": "+1", "UY": "+598","UZ": "+998", "VA":"+379", "VE":"+58", "VN": "+84", "VG": "+1", "VI": "+1","VC":"+1", "VU":"+678", "WS": "+685", "WF": "+681", "YE": "+967", "YT": "+262","ZA": "+27" , "ZM": "+260", "ZW":"+263"]
        let countryDialingCode = prefixCodes[countryRegionCode.uppercased()]
        return countryDialingCode ?? ""
        
    }
    
    class func isValidWebsite(websiteText: String) -> Bool {
        // print("validate calendar: \(testStr)")
        let head     = "((http|https)://)?([(w|W)]{3}+\\.)?"
        let tail     = "\\.+[A-Za-z]{2,3}+(\\.)?+(/(.)*)?"
        let urlRegEx = head+"+(.)+"+tail
        
        let websiteTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        return websiteTest.evaluate(with: websiteText)
    }
    
    // Show with Default Message
    class func showPI() {
        let activityData = ActivityData(size: CGSize(width: 30,height: 30),
                                        message: "Loading".localized + "...",
                                        type: NVActivityIndicatorType(rawValue: 29),
                                        color: UIColor.white,
                                        padding: nil,
                                        displayTimeThreshold: nil,
                                        minimumDisplayTime: nil)
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
    }
    // Show with Your Message
    class func showPI(_message:  String) {
        
        let activityData = ActivityData(size: CGSize(width: 30,height: 30),
                                        message: _message,
                                        type: NVActivityIndicatorType(rawValue: 29),
                                        color: UIColor.white,
                                        padding: nil,
                                        displayTimeThreshold: nil,
                                        minimumDisplayTime: nil)
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
    }
    // Hide
    class func hidePI() {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
    
    
    class func encodeStringTo64(_ fromString: String?) -> String? {
        let plainData = fromString?.data(using: .utf8)
        var base64String: String?
        base64String = plainData?.base64EncodedString(options: [])
        return base64String
    }
    
    class func removeSpecialCharsFromString(text: String) -> String {
        //  let okayChars : Set<Character> =
        //      Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-*=(),.:!_".characters)
        //  return String(text.characters.filter {okayChars.contains($0) })
        
        let result = String(text.filter { "+01234567890.".contains($0) })
        
        return result
    }
    
    
    class func setDataInNSUser(_ object:AnyObject, key: String) -> Void
    {
        Defaults.archive(DefaultsKey<Any>(key), object)
    }
    
    class func getObjectFromNSUser(_ key: String) -> Any?
    {
        return Defaults.unarchive(DefaultsKey<Any>(key))
    }
    
    
    class func isValidNumber(_ phoneNumber : String) -> Bool{
        let phoneNumberKit = PhoneNumberKit()
        do {
            let _ = try phoneNumberKit.parse(phoneNumber)
            return true
        }
        catch {
            return false
        }
    }
    
    class func setBlurrEffect(imageView: UIImageView,imageUrl: String){
        imageView.setImageOn(imageUrl: imageUrl, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
        DispatchQueue.main.async {
            imageView.addBlurredViewOnImage(size: CGRect(x: 0, y:0, width: imageView.frame.width, height: imageView.frame.height))
        }
        

    }
    
    class func getValidPhoneNumber(number: String) -> String{
        var phoneNumber = number
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            let countryCode = VNHCountryPicker.dialCode(code: countryCode).dialCode
            if phoneNumber.first == "0"{
                phoneNumber.remove(at: number.startIndex)
                phoneNumber = countryCode + phoneNumber
            } else if phoneNumber.first == "+"{
                let phonUtil = NBPhoneNumberUtil()
                do {
                    let nbPhone : NBPhoneNumber = try phonUtil.parse(withPhoneCarrierRegion: phoneNumber)
                    let countryCode : NSNumber = nbPhone.countryCode
                    phoneNumber =  Helper.removeZeroInBetweenCountryCodeAndNumber(number: number, with: "+\(countryCode)")
                }catch{
                    //Phone Number Invalid!
                }
            }else{
                phoneNumber = countryCode + phoneNumber
            }
            return phoneNumber
        }
        return phoneNumber
    }
    
    class func removeZeroInBetweenCountryCodeAndNumber(number: String, with countryCode: String) ->String{
        var phoneNumber = number
        let count = countryCode.count
        let parsed = number.dropFirst(count)
        if parsed.first == "0"{
            phoneNumber = countryCode + parsed.dropFirst()
        }else{
            phoneNumber = countryCode + parsed
        }
        return phoneNumber
    }
    
    
    static func showAlertFromTop(showOnView:UIView,message:String) {
        
//        let window = UIApplication.shared.keyWindow!
//        let topPadding: CGFloat = 0
//        if #available(iOS 11.0, *) {
//            topPadding = window.safeAreaInsets.top + 44
//        }
//        let labelForMessage = UILabel(frame:CGRect(x: 0, y:topPadding, width:showOnView.frame.size.width, height: 0))
        let labelForMessage = UILabel(frame:CGRect(x: 0, y:0, width:showOnView.frame.size.width, height: 0))
        labelForMessage.text = message
        labelForMessage.textColor = UIColor.white
        labelForMessage.textAlignment = .center
        labelForMessage.backgroundColor = Utility.appColor()
        labelForMessage.numberOfLines = 0
        labelForMessage.minimumScaleFactor = 0.5
        labelForMessage.font = UIFont.systemFont(ofSize: 15)
        labelForMessage.drawText(in: CGRect(x: 20, y: 0, width:showOnView.frame.size.width-40, height:50))
        showOnView.bringSubviewToFront(labelForMessage)
        showOnView.addSubview(labelForMessage)
        labelForMessage.layoutIfNeeded()
        
        UIView.animate(withDuration:0.6 , animations: {
            let newFrame  = CGRect(x: 0, y:0, width:showOnView.frame.size.width, height:40)
            labelForMessage.frame = newFrame
        }, completion: {
            (finshed) in
            if(finshed) {
                // change to desired number of seconds (in this case 1 seconds)
                let when = DispatchTime.now() + 2
                DispatchQueue.main.asyncAfter(deadline: when){
                    // your code with delay
                    UIView.animate(withDuration:0.6, animations: {
                        let newFrame  = CGRect(x: 0, y:0, width:showOnView.frame.size.width, height:0)
                        labelForMessage.frame = newFrame
                    }, completion:{ (finished) in
                        if(finished) {
                            labelForMessage.removeFromSuperview()
                        }
                    })
                }
            }
        })
    }
    
    /// Remove null from Objects
    ///
    /// - Returns: Object without Null
    class func nullKeyRemoval(data:[String:Any]) -> [String:Any] {
        var dict = data
        let keysToRemove = Array(dict.keys).filter { dict[$0] is NSNull }
        for key in keysToRemove {
            dict.removeValue(forKey: key)
        }
        var keysToUpdate = Array(dict.keys).filter { dict[$0] is [String:Any] }
        for key in keysToUpdate {
            dict.updateValue(nullKeyRemoval(data: dict[key] as! [String : Any]), forKey: key)
        }
        keysToUpdate = Array(dict.keys).filter { dict[$0] is [Any] }
        for key in keysToUpdate {
            let dataArray = dict[key] as! [Any]
            var temp:[Any] = []
            for item in dataArray {
                if item is NSNull {
                    
                }else{
                    if ((item as? [String:Any]) != nil){
                        temp.append(nullKeyRemoval(data: item as! [String:Any]))
                    }else{
                        temp.append(item)
                    }
                }
            }
            dict.updateValue(temp, forKey: key)
        }
        return dict
    }
    
    /*feature Name :- add toast message for create or update channel
      Fix Date :- 22/03/2021
      Fixed By :- Nikunj C
      Description Of bug :- add viewController parameters to dismiss respective viewcontroller after complete animation*/
    /*feature Name :- not able to click on save to collection
      Fix Date :- 09/07/2021
      Fixed By :- Jayaram G
      Description Of bug :- updated dubly code
     */
    class  func toastView(messsage : String, view: UIView , isFromBookMark:Bool = false, controller:ShareMediaOptionsVC? = nil, isSaveToCollection :Bool? = false){
        
        /* Bug Name : Toast label text not showing properly
         Fix Date : 01-04-2021
         Fixed By : Jayaram G
         Description Of Fix : changed height of the toast label and set number of lines zero
         */
        DispatchQueue.main.async {
            var topMargin : CGFloat = 0
            if #available(iOS 13.0, *) {
                if let height = view.window?.windowScene?.statusBarManager?.statusBarFrame.height {
                    topMargin = height
                }else if let height = (UIApplication.shared.delegate as! AppDelegate).window?.windowScene?.statusBarManager?.statusBarFrame.height{
                    topMargin = height
                }
            } else {
                topMargin = 20
            }
            let conatinerView = UIView(frame: CGRect(x: 0, y: topMargin ,width: view.bounds.width, height : 0))
            conatinerView.backgroundColor =  Helper.hexStringToUIColor(hex: AppColourStr.appColor)
            let toastLabel = UILabel(frame: CGRect(x: 20, y: 5 ,width: view.bounds.width - 40, height : 0))
            toastLabel.textAlignment = NSTextAlignment.left;
            Fonts.setFont(toastLabel, fontFamiy: .primary(.Regular), size: .standard(.h12), color: UIColor.white)
            toastLabel.text = messsage
            toastLabel.alpha = 1.0
            toastLabel.numberOfLines = 0
            toastLabel.clipsToBounds  =  true
            conatinerView.addSubview(toastLabel)
            
            let rightLabel = UILabel(frame: CGRect(x: view.bounds.width - 100, y: 10 ,width: 80, height : 0))
            var viewButton = UIButton(frame: CGRect(x: 0, y: topMargin ,width: view.bounds.width, height : 50))
            view.addSubview(conatinerView)
            if isFromBookMark{
                Fonts.setFont(rightLabel, fontFamiy: .primary(.Regular), size: .standard(.h14), color: UIColor.white)
                rightLabel.text = "View".localized
                viewButton.titleLabel?.text = ""
                viewButton.tintColor = .clear
                viewButton.backgroundColor = .clear
                if let check = isSaveToCollection, check{
                    viewButton.tag = 1
                }else{
                    viewButton.tag =  0
                }
                viewButton.addTarget(controller.self, action: #selector(controller?.toastAction), for: .touchUpInside)
                rightLabel.textAlignment = NSTextAlignment.right
                conatinerView.addSubview(rightLabel)
                view.addSubview(viewButton)
            }
            
            UIView.animate(withDuration: 0.3,delay:0,options: .curveLinear,
                           animations: {
                            conatinerView.frame =  CGRect(x: 0, y: topMargin ,width: view.bounds.width, height : 50)
                            toastLabel.frame =  CGRect(x: 20, y: 5 ,width: view.bounds.width - 40, height : 50)
                            rightLabel.frame = CGRect(x: view.bounds.width - 100, y: 10 ,width: 80, height : 20)
                            viewButton = UIButton(frame: CGRect(x: 0, y: topMargin ,width: view.bounds.width, height : 50))
                            
                           }) { (Bool) in
                UIView.animate(withDuration: 0.3,delay:3,options: .curveLinear,
                               animations: {
                                conatinerView.frame =  CGRect(x: 0, y: topMargin ,width: view.bounds.width, height : 0)
                                toastLabel.frame =  CGRect(x: 20, y: 10 ,width: view.bounds.width - 40, height : 0)
                                rightLabel.frame = CGRect(x: view.bounds.width - 100, y: 10 ,width: 80, height : 0)
                                viewButton = UIButton(frame: CGRect(x: 0, y: topMargin ,width: view.bounds.width, height : 0))
                               }) { (Bool) in
                    conatinerView.removeFromSuperview()
                    viewButton.removeFromSuperview()
                }
                           }
            
        }
    }
    
    
   class func decimalValidation(txtAfterUpdate: String) -> Bool {
        let numberOfDots = txtAfterUpdate.components(separatedBy: ".").count - 1
        let isNumeric = txtAfterUpdate.isEmpty || (Double(txtAfterUpdate) != nil)
        let numberOfDecimalDigits: Int
           if let dotIndex = txtAfterUpdate.index(of: ".") {
               numberOfDecimalDigits = txtAfterUpdate.distance(from: dotIndex, to: txtAfterUpdate.endIndex) - 1
           } else {
               numberOfDecimalDigits = 0
           }
        return isNumeric && numberOfDots <= 1 && numberOfDecimalDigits <= 2
    }
    
    
    /*
     Bug Name:- network handling
     Fix Date:- 20/04/21
     Fix By  :- Nikunj C
     Description of Fix:- hide toast after 3 sec
     */
    
    /*
     Bug Name:- toast not appear sometime
     Fix Date:- 16/04/21
     Fix By  :- Nikunj C
     Description of Fix:- hide toast after 3 sec
     */
    
    class  func toastViewForReachability(messsage : String,fromHome: Bool? = false, view: UIView){
        
            toastView.removeFromSuperview()
        
        DispatchQueue.main.async {

            let y = view.safeAreaLayoutGuide.layoutFrame.minY
            toastView.frame = CGRect(x: 0, y: y ,width: view.bounds.width, height : 0)
            toastViewLabel.frame = CGRect(x: 20, y: 0 ,width: view.bounds.width - 40, height : 0)
            Fonts.setFont(toastViewLabel, fontFamiy: .primary(.Regular), size: .standard(.h14), color: .white)
            toastViewLabel.textAlignment = NSTextAlignment.center;
            toastViewLabel.alpha = 1.0
            toastViewLabel.text = messsage
            toastViewLabel.numberOfLines = 0
            toastViewLabel.clipsToBounds  =  true
            
            if !toastView.isDescendant(of: view){
                toastView.addSubview(toastViewLabel)
                view.addSubview(toastView)
            }
            toastViewLabel.layer.removeAllAnimations()
            toastView.layer.removeAllAnimations()
            
            UIView.animate(withDuration: 0.3,delay:0,options: .curveLinear,
                           animations: {
                            toastView.frame =  CGRect(x: 0, y: y ,width: view.bounds.width, height : 30)
                            if fromHome ?? false {
                                toastView.backgroundColor =  Utility.appColor()
                            }else{
                                toastView.backgroundColor =  #colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1)
                            }
                            
                            toastViewLabel.frame =  CGRect(x: 20, y: 0 ,width: view.bounds.width - 40, height : 30)
                           }){ (Bool) in
                UIView.animate(withDuration: 0.3,delay:3,options: .curveLinear,
                                          animations: {
                                            toastView.frame =  CGRect(x: 0, y: y ,width: view.bounds.width, height : 0)
                                            toastViewLabel.frame =  CGRect(x: 20, y: 10 ,width: view.bounds.width - 40, height : 0)
                           }) { (Bool) in
                    toastView.removeFromSuperview()
                           }
              }
            
        }
        
    }
    
    
    /*
     Bug Name:- toast not appear sometime
     Fix Date:- 16/04/21
     Fix By  :- Nikunj C
     Description of Fix:- hide toast after 3 sec
     */
    class  func toastViewForNavigationBar(messsage : String,fromHome: Bool? = false, view: UIView){
        toastView.removeFromSuperview()
        DispatchQueue.main.async {
            let y = view.safeAreaLayoutGuide.layoutFrame.minY
            toastView.frame = CGRect(x: 0, y: y ,width: view.bounds.width, height : 0)
            toastViewLabel.frame = CGRect(x: 20, y: 0 ,width: view.bounds.width - 40, height : 0)
            Fonts.setFont(toastViewLabel, fontFamiy: .primary(.Regular), size: .standard(.h14), color: .white)
            toastViewLabel.textAlignment = NSTextAlignment.center;
            toastViewLabel.alpha = 1.0
            toastViewLabel.text = messsage
            toastViewLabel.numberOfLines = 0
            toastViewLabel.clipsToBounds  =  true
            
            if !toastView.isDescendant(of: view){
                toastView.addSubview(toastViewLabel)
                view.addSubview(toastView)
            }
            toastViewLabel.layer.removeAllAnimations()
            toastView.layer.removeAllAnimations()
            
            UIView.animate(withDuration: 0.3,delay:0,options: .curveLinear,
                           animations: {
                            toastView.frame =  CGRect(x: 0, y: y ,width: view.bounds.width, height : 30)
                            toastView.backgroundColor =  Utility.appColor()
                            toastViewLabel.frame =  CGRect(x: 20, y: 0 ,width: view.bounds.width - 40, height : 30)
                           }){ (Bool) in
                UIView.animate(withDuration: 0.3,delay:3,options: .curveLinear,
                                          animations: {
                                            toastView.frame =  CGRect(x: 0, y: y ,width: view.bounds.width, height : 0)
                                            toastViewLabel.frame =  CGRect(x: 20, y: 10 ,width: view.bounds.width - 40, height : 0)
                           }) { (Bool) in
                    toastView.removeFromSuperview()
                           }
              }
            
        }
        
    }
    
    
    class func checkConnectionAvaibility(view:UIView,isNetworkAvailable:((Bool) -> ())? = nil){
        DispatchQueue.main.async {
            Helper.rxalmofire.checkForReachability { (status) in
                    if !status{
                        DispatchQueue.main.async {
                            Helper.toastViewForReachability(messsage: "No internet connection".localized, view: view)
                            if isNetworkAvailable != nil{
                                isNetworkAvailable!(false)
                            }
                        }
                        
                    }else{
                        if isNetworkAvailable != nil{
                            isNetworkAvailable!(true)
                        }
                    }
                
                
            }
        }
    }
    
    class func generateVideoFromImages(image:UIImage, completion: @escaping(URL)->()){
        if let audioURL1 = Bundle.main.url(forResource: "silence_no_sound", withExtension: "mp3") {

            VideoGenerator.fileName = "userProfile"
            VideoGenerator.shouldOptimiseImageForVideo = false
            VideoGenerator.current.generate(withImages: [image,image], andAudios: [audioURL1], andType: .singleAudioMultipleImage) { progress in
                print(progress)
            } outcome: { result in
                switch result{
                case .success(let url):
                    print(url)
                    completion(url)
                case .failure(let err):
                    print(err)
                }
            }

        }
    }
    
    /*
     Feat Name:- add download option with watermark
     Feat Date:- 22/04/21
     Feat   By:- Nikunj C
     Description of Feat:- function use to download media 
     */
    
    class func downloadVideoLinkAndCreateAsset(_ videoLink: String,fileName: String, isVideo:Bool = false, messageTag:String) {
        guard let rootView =  (UIApplication.shared.delegate as! AppDelegate).window else{
            return
        }
        if messageTag != "Gif"{
            DispatchQueue.main.async {
                Helper.toastView(messsage: "Download Will be available in your device gallery shortly".localized + ".", view: rootView)
            }
        }
        DispatchQueue.global(qos: .background).async {
            // use guard to make sure you have a valid url
            guard let videoURL = URL(string: videoLink) else { return }
            
            guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            
            if FileManager.default.fileExists(atPath: videoLink) {
                do {
                    try FileManager.default.removeItem(atPath: videoLink.path!)
                } catch {
                }
                
            }
            do{
                if !isVideo {
                    URLSession.shared.downloadTask(with: videoURL) { (location, response, error) -> Void in

                        // use guard to unwrap your optional url
                        guard let location = location else { return }
                        // create a deatination url with the server response suggested file name
            
                        let destinationURL = documentsDirectoryURL.appendingPathComponent(response?.suggestedFilename ?? videoURL.lastPathComponent)

                        do {

                            try FileManager.default.moveItem(at: location, to: destinationURL)

                            PHPhotoLibrary.requestAuthorization({ (authorizationStatus: PHAuthorizationStatus) -> Void in

                                // check if user authorized access photos for your app
                                if authorizationStatus == .authorized {
                                    PHPhotoLibrary.shared().performChanges({
                                        if isVideo{
                                          PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: destinationURL)
                                        }else{
                                            PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: destinationURL)
                                        }
                                        
                                    }) { completed, error in
                                            if completed {

                                                Helper.toastView(messsage: "\(messageTag) download completed.", view: rootView )
                                                print("Video asset created")
                                            
                                            } else {
                                            Helper.toastView(messsage: "\(messageTag) download failed.", view: rootView)
                                            }
                                    }
                                }
                            })

                        } catch {
                            print(error)
                            
                        }

                    }.resume()
                }else{
                    PHPhotoLibrary.requestAuthorization({ (authorizationStatus: PHAuthorizationStatus) -> Void in

                        // check if user authorized access photos for your app
                        if authorizationStatus == .authorized {
                            PHPhotoLibrary.shared().performChanges({
                                if isVideo{
                                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
                                }else{
                                    PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: videoURL)
                                }

                            }) { completed, error in
                                if completed {

                                    Helper.toastView(messsage: "\(messageTag) " + "download completed".localized + ".", view: rootView )
                                    print("Video asset created")

                                } else {
                                    Helper.toastView(messsage: "\(messageTag) " + "download failed".localized + ".", view: rootView)
                                }
                            }
                        }
                    })
                }
                
            } catch {
                print(error)
                
            }
        }
    }
    
    /*
     Feature Name:- Added share posts to social media
     Feature Date:- 28/07/21
     Featured By:- Jayaram G
     Description of Feature:- Added download assets for sharing
     */
    
    class func downloadVideoLinkAndCreateAssetForSocialShare(_ videoLink: String,fileName: String, isVideo:Bool = false, messageTag:String, complitation: @escaping(Bool)->Void) {
       guard let rootView =  (UIApplication.shared.delegate as! AppDelegate).window else{
           return
       }
       if messageTag != "Gif"{
         
       }
        DispatchQueue.global(qos: .background).async {
            // use guard to make sure you have a valid url
            guard let videoURL = URL(string: videoLink) else { return }
            
            guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            
            if FileManager.default.fileExists(atPath: videoLink) {
                do {
                    try FileManager.default.removeItem(atPath: videoLink.path!)
                } catch {
                }
                
            }
            do{
                if !isVideo {
                    URLSession.shared.downloadTask(with: videoURL) { (location, response, error) -> Void in

                        // use guard to unwrap your optional url
                        guard let location = location else { return }
                        // create a deatination url with the server response suggested file name
            
                        let destinationURL = documentsDirectoryURL.appendingPathComponent(response?.suggestedFilename ?? videoURL.lastPathComponent)

                        do {

                            try FileManager.default.moveItem(at: location, to: destinationURL)

                            PHPhotoLibrary.requestAuthorization({ (authorizationStatus: PHAuthorizationStatus) -> Void in

                                // check if user authorized access photos for your app
                                if authorizationStatus == .authorized {
                                    PHPhotoLibrary.shared().performChanges({
                                        if isVideo{
                                          PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: destinationURL)
                                        }else{
                                            PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: destinationURL)
                                        }
                                        
                                    }) { completed, error in
                                            if completed {

                                                Helper.toastView(messsage: "\(messageTag) download completed.", view: rootView )
                                                print("Video asset created")
                                            
                                            } else {
                                            Helper.toastView(messsage: "\(messageTag) download failed.", view: rootView)
                                            }
                                    }
                                }
                            })

                        } catch {
                            print(error)
                            
                        }

                    }.resume()
                }else{
                    PHPhotoLibrary.requestAuthorization({ (authorizationStatus: PHAuthorizationStatus) -> Void in

                        // check if user authorized access photos for your app
                        if authorizationStatus == .authorized {
                            PHPhotoLibrary.shared().performChanges({
                                if isVideo{
                                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
                                }else{
                                    PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: videoURL)
                                }

                            }) { completed, error in
                                if completed {
                                    complitation(true)
                                    print("Video asset created")

                                } else {
                                    complitation(false)
                                }
                            }
                        }
                    })
                }
                
            } catch {
                print(error)
                
            }
        }
    }
    
    
    
    class func getDeviceDetailsParams() -> [String:Any]{
        let deviceID = UIDevice.current.identifierForVendor?.uuidString
        let deviceName = UIDevice.current.name
        let deviceOs = UIDevice.current.systemVersion
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        let modelNumber = UIDevice.modelName
        let params = [
            "deviceId" : deviceID ?? "",
            "deviceName" : deviceName ,
            "deviceOs" : deviceOs ,
            "modelNumber" : modelNumber ,
            "deviceType" : "1",
            "appVersion" : appVersion ?? ""] as [String : Any]
        return params
        
    }
    
    class func getDefaultHeader()->[String:String]{
       var basicAuth: String = "\(AppConstants.BasicAuth.userName):\(AppConstants.BasicAuth.passWord)"
       basicAuth = Helper.encodeStringTo64(basicAuth) ?? ""
       basicAuth = "Basic \(basicAuth)"
       let headers = ["Authorization": "\(basicAuth)"]
        return headers
    }
    
    
    class func downloadImage(from url: URL) {
        print("Download Started")
        self.getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            /* Bug Name : Add profile pic in tabbar
             Fix Date : 08-apr-2021
             Fixed By : Jayaram G
             Description Of Fix : Storing profile pic in userdefaults.
             */
            UserDefaults.standard.set(data, forKey: AppConstants.UserDefaults.userImageData)
        }
    }
    
    class func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
         URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
     }
    
    class func resizeProfilePicForHomeScreen(url: String?) -> UIImage? {
        let imageView = UIImageView()
        imageView.setImageOn(imageUrl: url, defaultImage: #imageLiteral(resourceName: "defaultImage"))
        let updatedImage = imageView.image?.resizeImageUsingVImage(size: CGSize(width: 40, height: 40))
        
            return updatedImage
            
    }
    
    class func resizedDefaultImage() -> UIImage {
        let imageView = UIImageView()
        imageView.image =  #imageLiteral(resourceName: "defaultImage")
        let updatedImage = imageView.image?.resizeImageUsingVImage(size: CGSize(width: 40, height: 40))
        return updatedImage ?? UIImage()
    }
    
    class func showAlertViewOnWindow(_ title: String , message: String) {
        
        let alertController = UIAlertController(title: title, message:message, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK".localized, style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
            
        }
        alertController.addAction(okAction)
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            DispatchQueue.main.async {
                topController.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    class func showAlertViewOnWindowWithCompletionHandler(_ title: String , message: String,complicationHndler:@escaping(Bool)-> Void) {
        
        let alertController = UIAlertController(title: title, message:message, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK".localized, style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
            complicationHndler(true)
        }
        alertController.addAction(okAction)
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            DispatchQueue.main.async {
                topController.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    
    class func showAlertViewWithTwoOption(_ title: String , message: String, complicationHndler:@escaping(Bool)-> Void) {
        
        let alertController = UIAlertController(title: title, message:message, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: Strings.settings.localized, style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
            complicationHndler(true)
        }
        let cancel = UIAlertAction(title: Strings.cancel.localized, style: .cancel) { (action) in
            complicationHndler(false)
        }
        alertController.addAction(okAction)
        alertController.addAction(cancel)
        
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            DispatchQueue.main.async {
                topController.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    class func showAlertViewOnTableViewController(_ title: String, message: String, controller: UITableViewController){
        
        let alertController = UIAlertController(title: title, message:message, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK".localized, style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
        }
        alertController.addAction(okAction)
        controller.present(alertController, animated: true, completion: nil)
    }
    class func showAlertViewOnViewController(_ title: String, message: String, controller: UIViewController){
        
        let alertController = UIAlertController(title: title, message:message, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK".localized, style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
        }
        alertController.addAction(okAction)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    class func getFavoriteDataFromDatabase1() -> [Contacts] {
        
        let documentID = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.contactDocumentID) as? String
        var dbContactsArr = NSArray()
        if documentID !=  nil{
            dbContactsArr = Contacts.getContactsArrayFormDatabase(database: Couchbase.sharedInstance) as NSArray
        }
        
        let predicate = NSPredicate.init(format: "isFavorite == %@","isFavorite")
        let favArr =  dbContactsArr.filtered(using: predicate)
        if favArr.count > 0  {
            return Contacts.getAllUserDetail(withuserData: favArr )
        }
        return []
    }

    
   class func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
    class func  checkCallGoingOn() -> Bool{
        if  let isCallgoingOn = UserDefaults.standard.object(forKey:"iscallgoingOn") as? Bool {
            return isCallgoingOn
        }
        return false
    }
    
    
    class func getcurrentDataAndtime()-> String{

        let todayDate:Date = Date()
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        let dateInStrFormate:String = dateFormatter.string(from: todayDate )
        return dateInStrFormate
    }
    
    
    class func getcurrentDataAndtimeForSave()-> String{
        let todayDate:Date = Date()
        return todayDate.millisecondsSince1970
    }
    
    //Actionsheet object
    class func initActionSheet(title:String? , message:String?) -> UIAlertController{
        let actionController = UIAlertController.init(title: title, message: message, preferredStyle: .actionSheet)
        
        let action2 = UIAlertAction.init(title: "Cancel".localized, style: .cancel, handler: { (action) in
        })
        
        actionController.addAction(action2)
        return actionController
    }
    
    
    
    class func getNameFormDatabase(num:String) -> String{
        
        let favArr  = Helper.getFavoriteDataFromDatabase1()
        
        let favmutable = favArr
        //        let predicate = NSPredicate.init(format:"registerNum == %@", num)
        //        let fArr =  favmutable.filter({predicate.evaluate(with: $0)})
        let fArr = favmutable.filter { (contact) -> Bool in
            contact.registerNum == num
        }
        
        if fArr.count ==  0 {
            if let nummm =   UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userNumber) as? String {
                return nummm == num ? "You".localized : num
            }
            return num
        }else{
            let contact = fArr[0]
            if contact.fullName == "" || contact.fullName?.count == 0 {
                return num
            }
            return contact.fullName!
        }
    }
    
    
    /// To get user name from group member list
    ///
    /// - Parameters:
    ///   - num: user number
    ///   - memberList: member list
    /// - Returns: member number if user is in list otherwise user number
    class func getUserNameFromMemberList(num: String, memberList: [[String : Any]]?)-> String{
        guard let myNumber = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userName) as? String else{return num}
        if myNumber.contains(num) || num.contains(myNumber){
            return "You".localized
        }
        guard let memberArr = memberList else {return num}
        let predicate = NSPredicate.init(format:"memberIdentifier CONTAINS [cd] %@", num)
        let fArr =  memberArr.filter({predicate.evaluate(with: $0)})
        if fArr.count > 0{
            let userData = fArr[0]
            guard let userName = userData["userName"] as? String else {return num}
            return userName
        }else{
            return num
        }
    }
    
    
class func makeFiltersForWhiteBackGroud(image: UIImage) -> UIImage {
            let beginImage = CIImage(image: image)
            let edgeDetectFilter = CIFilter(name: "CIVignetteEffect")!
            edgeDetectFilter.setValue(beginImage, forKey: kCIInputImageKey)
            edgeDetectFilter.setValue(0.3, forKey: "inputIntensity")
            edgeDetectFilter.setValue(0.2, forKey: "inputRadius")
            let filteredImage = UIImage(ciImage: edgeDetectFilter.outputImage!)
        return filteredImage
    }
    
    
    /// To get user image from group member list
    ///
    /// - Parameters:
    ///   - userNumber: user number to get image
    ///   - memberList: group member list
    /// - Returns: user image if there otherwise nil
    class func getUserImage(userNumber: String?, memberList: [[String : Any]]?)-> String?{
        guard let memberArr = memberList else {return nil}
        guard let number = userNumber else{return nil}
        let predicate = NSPredicate.init(format:"memberIdentifier CONTAINS [cd] %@", number)
        let fArr =  memberArr.filter({predicate.evaluate(with: $0)})
        if fArr.count > 0{
            let userData = fArr[0]
            return userData["memberImage"] as? String
        }else{
            return nil
        }
    }
    
    
    
   class func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }

    
    
    class func defaultTimerArr() -> [String] {
        return ["off".localized,"1".localized + " " + "Second".localized,"2".localized + " " + "Seconds".localized,"3".localized + " " + "Seconds".localized,"4".localized + " " + "Seconds".localized,"5".localized + " " + "Seconds".localized,"6".localized + " " + "Seconds".localized,"7".localized + " " + "Seconds".localized,"8".localized + " " + "Seconds".localized,"9".localized + " " + "Seconds".localized,"10".localized + " " + "Seconds".localized,"15".localized + " " + "Seconds".localized,"30".localized + " " + "Seconds".localized,"1".localized + " " + "Minute".localized,"1".localized + " " + "Hour".localized,"1".localized + " " + "Day".localized,"1".localized + " " + "Week".localized]
    }
    
    class func timeInsecArr() -> [Int]{
        return [0,1,2,3,4,5,6,7,8,9,10,15,30,60,3600,86400,604800]
    }
    
    
   class func getDefaultCurrentTimeStamp() -> String {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddhhmmssa"
        formatter.locale = Locale.current
        let result = formatter.string(from: date)
        return result
    }
    
    /// Current time stamp
    static var currentTimeStamp: String {
        return String(format: "%0.0f", Date().timeIntervalSince1970 * 1000)
    }
    
    /// Current time stamp
    static var getCurrentTimeStamp: Int64 {
        return  Int64(Date().timeIntervalSince1970 * 1000)
    }
    
    /// To make attributed string starting from # and @
    ///
    /// - Parameter title: string to make attributed
    /// - Returns: attributed string
    class func makeAttributedString(title: String, font: UIFont) -> NSMutableAttributedString{
        let wordArray = title.components(separatedBy: " ")
        var attributedString: NSMutableAttributedString = NSMutableAttributedString(string: "")
        var isFirst: Bool = true
        for word in wordArray{
            var wordToAdd: NSMutableAttributedString = NSMutableAttributedString(string: "")
            if word.hasPrefix("#") || word.hasPrefix("@"){
                let attributed = [ convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]
                var attrWord: String = word
                if word.hasSuffix("\n"){
                    attrWord = "\(word.dropLast())"
                }
                wordToAdd = NSMutableAttributedString(string: attrWord, attributes: convertToOptionalNSAttributedStringKeyDictionary(attributed))
                let range = NSMakeRange(0, wordToAdd.length)
                let linkAttribute = [convertFromNSAttributedStringKey(NSAttributedString.Key.link): attrWord]
                wordToAdd.addAttributes(convertToNSAttributedStringKeyDictionary(linkAttribute), range: range)
//                let attributeColor : [String : Any] = [NSForegroundColorAttributeName : UIColor.black]
//                wordToAdd.addAttributes(attributeColor, range: range)
            }else{
                wordToAdd = NSMutableAttributedString(string: word)
            }
            if isFirst{
                 attributedString = wordToAdd
                isFirst = false
            }else{
                attributedString = attributedString + NSMutableAttributedString(string: " ") + wordToAdd as! NSMutableAttributedString
            }
        }
        return attributedString
    }
    
    
    
    /// To get time past from current time
    ///
    /// - Parameter timeStamp: time stamp
    /// - Returns: time in string
    class func getTimeStamp(timeStamp: Double)->String{        
        let timeIntervalFormator = TTTTimeIntervalFormatter()
        /*
         Bug Name:- Time stamps not showing correctly in activity
         Fix Date:- 21/01/2021
         Fix By  :- Nikunj C
         Description of Fix:- more then 10 digit make issue so provide only 10 digit
         */
        if String(Int(timeStamp)).count > 10 {
            let string = String(timeStamp).prefix(10)
            let actvityTime: Date = Date(timeIntervalSince1970: Double(string)!)
            let interval: TimeInterval  = actvityTime.timeIntervalSinceNow
            let timeStampDate: String = timeIntervalFormator.string(forTimeInterval: interval)
            return timeStampDate
        }else{
            let actvityTime: Date = Date(timeIntervalSince1970: timeStamp)
            let interval: TimeInterval  = actvityTime.timeIntervalSinceNow
            let timeStampDate: String = timeIntervalFormator.string(forTimeInterval: interval)
            return timeStampDate

        }
    }
    
    class func getDateTime(timestamp: Double,format:String = "dd MMM yyyy hh:mm a",isLocal:Bool = false) -> String {
          var strDate = ""
          
          //        if let unixTime = Double(timestamp) {
          let date = Date(timeIntervalSince1970: timestamp)
          let dateFormatter = DateFormatter()
          let timezone = TimeZone.current.abbreviation() ?? "UTC"  // get current TimeZone abbreviation or set to CET
  //        timeZone = TimeZone(secondsFromGMT: 0)
          dateFormatter.timeZone = isLocal ? TimeZone(secondsFromGMT: 0) : TimeZone(abbreviation: timezone) //Set timezone that you want
          dateFormatter.locale = NSLocale.current
          dateFormatter.dateFormat = format //Specify your format that you want
          strDate = dateFormatter.string(from: date)
          //        }
          
          return strDate
      }
    
    /// To get time past from current time
    ///
    /// - Parameter timeStamp: time stamp
    /// - Returns: time in string
    class func getTimeStampForLowTime(timeStamp: Double)->String{
        let timeIntervalFormator = TTTTimeIntervalFormatter()
        let actvityTime: Date = Date(timeIntervalSince1970: timeStamp)
        let interval: TimeInterval  = actvityTime.timeIntervalSinceNow
        let timeStampDate: String = timeIntervalFormator.string(forTimeInterval: interval)
        return timeStampDate
    }
    
    class func getselfUserId() -> String{
        guard let userId = Utility.getUserid() else { return "" }
        return userId
    }
    
    class func getImageStringUrl(url: String?) -> String?{
        if let strUrl = url{
            let endIndex = strUrl.index(strUrl.endIndex, offsetBy: -3)
            var truncated = strUrl.substring(to: endIndex)
            truncated = truncated + "jpg"
            return truncated
        }
        return nil
    }
    
    /*
     Feat Name::- DP PlaceHolder with first character of firstname and lastname
     Feat Date:- 10/05/21
     Feat By  :- Nikunj C
     Description of Feat:- create default placeholder
     */
    
    //MARK: - Get Custom Image
    class func getCustomImage(imageDisplayName: String?, imageView: UIImageView!)->UIImage{
        let fontSize = imageView.frame.width / 2
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white,
                          NSAttributedString.Key.font: Utility.Font.Bold.ofSize(fontSize)]
        if let name = imageDisplayName, !name.isEmpty {
            imageView.setImage(string:name, color: UIColor.colorHash(name: name), circular: true, stroke: false,textAttributes:attributes)
            return imageView.image ?? #imageLiteral(resourceName: "defaultImage")
        }else{
            imageView.setImage(string:"Display Picture", color: UIColor.colorHash(name: "Display Picture"), circular: true, stroke: false,textAttributes:attributes)
            return imageView.image ?? #imageLiteral(resourceName: "defaultImage")
        }
    }
    
    /*
     Feat Name::- DP PlaceHolder with first character of firstname and lastname
     Feat Date:- 03/04/21
     Feat By  :- Nikunj C
     Description of Feat:- save created default placeholder to local
     */
    
    class func saveImage(image: UIImage,name:String)  {
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return
        }
        do {
            try data.write(to: directory.appendingPathComponent(name)!)
            return
        } catch {
            print(error.localizedDescription)
            return 
        }
    }
    
    /*
     Feat Name::- DP PlaceHolder with first character of firstname and lastname
     Feat Date:- 03/04/21
     Feat By  :- Nikunj C
     Description of Feat:- return url from created placeholder
     */
    
    class func getSavedImage(name:String) -> URL {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            let url = dir.absoluteURL.appendingPathComponent(name)
            return url
        }
        return URL(string: "www.google.in")!
    }
    //To create deep link through firebase
    class func createDeepLink(isFromProfile: Bool? = false,profileModel: UserProfileModel? = nil ,forPost: Bool,postModel: SocialModel? = nil, onResult: @escaping (Bool, URL?) -> Void){
        /* Feature Name : Share Profile
         Feature Date : 12-Apr-2021
         Feature Added By : jayaram G
         Description Of Feature : Added more params and handling for post and profile.
         */
        var linkString = ""
        if isFromProfile ?? false{
            linkString = AppConstants.DynamicLinkUrlForProfile + (profileModel?.userId)!
        }else{
            if forPost {
                linkString = AppConstants.DynamicLinkUrlForPost + (postModel?.postId ?? "")
            }else{
                linkString = AppConstants.DynamicLinkUrlForProfile + (postModel?.userId)!
            }
        }
       
        guard let link = URL(string: linkString) else { return }
        let dynamicLinksDomain = AppConstants.DeepLinking.CUSTOM_URL_SCHEME
        let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomain)
        linkBuilder?.iOSParameters = DynamicLinkIOSParameters(bundleID: AppConstants.iOSBundleId)
        linkBuilder?.androidParameters = DynamicLinkAndroidParameters(packageName: AppConstants.AndroidPackageName)
        linkBuilder?.iOSParameters?.fallbackURL = URL.init(string: AppConstants.AppUrl)
        if isFromProfile ?? false {
            linkBuilder?.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
            linkBuilder?.socialMetaTagParameters!.title = profileModel?.userName
            let imageUrl = URL(string: (profileModel?.profilePic) ?? "")
            linkBuilder?.socialMetaTagParameters!.imageURL = imageUrl
        }else{
            if forPost {
                linkBuilder?.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
                linkBuilder?.socialMetaTagParameters!.title = postModel?.title
                let imageUrl = URL(string: Helper.getPostImage(socialModel: postModel))!
                linkBuilder?.socialMetaTagParameters!.imageURL = imageUrl
            }else{
                linkBuilder?.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
                linkBuilder?.socialMetaTagParameters!.title = postModel?.userName
                let imageUrl = URL(string: (postModel?.profilePic) ?? "")
                linkBuilder?.socialMetaTagParameters!.imageURL = imageUrl

            }
        }
        guard let longDynamicLink = linkBuilder?.url else {
            onResult(false, nil)
            return }
        print("The long URL is: \(longDynamicLink)")
//        onResult(true,longDynamicLink)
        linkBuilder?.shorten() { url, warnings, error in
            if error == nil{
                guard let url = url else{
                    onResult(false, nil)
                    return}
                print("The short URL is: \(url)")
                onResult(true,url)
            }else{
                onResult(false, nil)
            }
        }
    }
    
    class func getPostImage(socialModel: SocialModel?) ->String{
        if socialModel?.mediaType == 1{
            if let url = socialModel?.thumbnailUrl{
                let endIndex = url.index(url.endIndex, offsetBy: -3)
                var truncated = url.substring(to: endIndex)
                truncated = truncated + "jpg"
                return truncated
            }
        }else{
            return (socialModel?.imageUrl!)!
        }
        return ""
    }
    
    
    class func getAmountShortForm(amount: String) -> String {
           guard let amt = Double(amount) else {return ""}
           if amt > 999 && amt < 10000 {
               let convertedAmount = String(amt)
               var newChar = String(convertedAmount[convertedAmount.startIndex])
               newChar.insert(contentsOf: "K", at: newChar.endIndex)
               return newChar
            }else if amt > 9999 && amt  < 100000 {
               var convertedAmount = String(amt)
               let range = convertedAmount.index(convertedAmount.startIndex, offsetBy: 2)..<convertedAmount.endIndex
               convertedAmount.removeSubrange(range)
               return convertedAmount + "K"
           }else if amt > 99999 && amt < 1000000 {
               var convertedAmount = String(amt)
               let range = convertedAmount.index(convertedAmount.startIndex, offsetBy: 3)..<convertedAmount.endIndex
               convertedAmount.removeSubrange(range)
               return convertedAmount + "K"
           }else if amt > 999999 && amt < 10000000 {
               let convertedAmount = String(amt)
               var newChar = String(convertedAmount[convertedAmount.startIndex])
               newChar.insert(contentsOf: "M", at: newChar.endIndex)
               return newChar
           }else if amt > 9999999 && amt < 100000000 {
               var convertedAmount = String(amt)
               let range = convertedAmount.index(convertedAmount.startIndex, offsetBy: 2)..<convertedAmount.endIndex
               convertedAmount.removeSubrange(range)
               return convertedAmount + "M"
           }else if amt > 99999999 && amt < 1000000000 {
               var convertedAmount = String(amt)
               let range = convertedAmount.index(convertedAmount.startIndex, offsetBy: 3)..<convertedAmount.endIndex
               convertedAmount.removeSubrange(range)
               return convertedAmount + "M"
           }else if amt > 999999999 && amt < 10000000000 {
               let convertedAmount = String(amt)
               var newChar = String(convertedAmount[convertedAmount.startIndex])
               newChar.insert(contentsOf: "T", at: newChar.endIndex)
               return newChar
           }else {
               let convertedAmount = String(amt)
               return convertedAmount
           }
           return ""
       }
       
       
       class func UIColorFromRGB(rgbValue: UInt) -> UIColor {
           return UIColor(
               red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
               green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
               blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
               alpha: CGFloat(1.0)
           )
       }
       
       class func change(_ date: String) -> String {
                  
                  let dateFormatter = DateFormatter()
                  dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                  let oldDate = dateFormatter.date(from: date)
                  
       //           let indianLocale = Locale(identifier: "en_US")
       //        dateFormatter.locale = indianLocale as Locale?
               
                dateFormatter.timeZone = TimeZone.current
                  
                  dateFormatter.dateFormat = "dd MMM yyyy HH:mm:ss"
                  return dateFormatter.string(from: oldDate!)
              }
    
    
 
    
    
    //Provide Cornor Readius And BoderWidth
    class func provideCorenerRadiusandBoderWith(btn:UIButton,cornerRadius:CGFloat,borderWidth:CGFloat,borderColor:UInt){
        btn.layer.cornerRadius = cornerRadius
        btn.layer.borderWidth = borderWidth
        btn.layer.borderColor = Helper.UIColorFromRGB(rgbValue: borderColor).cgColor
    }
    
    class func provideBoderAndCornerReadiusForView(view:UIView,radius:CGFloat,borderColor:UInt,backgroundColor:UInt){
          view.layer.cornerRadius = radius
          view.layer.borderColor = Helper.UIColorFromRGB(rgbValue: borderColor).cgColor
          view.layer.backgroundColor = Helper.UIColorFromRGB(rgbValue: backgroundColor).cgColor
          view.layer.borderWidth = 2
      }
      
      class func provideBoderInView(_ view:UIView){
            view.layer.cornerRadius = 4
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.init(red: 180/255, green: 219/255, blue: 255/255, alpha: 1).cgColor
        }
      
      class func getDateObj(fromTimeStamp timeStamp: String) -> Date {
              let timeStampInt = UInt64(UInt64(timeStamp)!/1000)
              let msgDate = Date(timeIntervalSince1970: TimeInterval(timeStampInt))
              return msgDate
          
      }
    
    //ProvideNavigationBar Colour
    class func provideNaviationBarColour(controller:UINavigationController){
        controller.navigationBar.tintColor = Helper.UIColorFromRGB(rgbValue: 0xffffff)
        controller.navigationBar.barTintColor = Helper.UIColorFromRGB(rgbValue: 0xFFFFFF)
    }
    
    //Function Used For provideShadowForBtn
    class func provideShadowForBtn(btn:UIButton,rgbValue:UInt,radius:CGFloat, width:CGFloat){
       btn.layer.shadowColor = Helper.UIColorFromRGB(rgbValue: rgbValue).cgColor
       btn.layer.shadowOffset = CGSize(width: 0, height: 5)
       btn.layer.shadowOpacity = 0.3
       btn.layer.shadowRadius = 2.0
       btn.layer.masksToBounds = false
       btn.layer.cornerRadius = radius
       btn.layer.borderColor = Helper.UIColorFromRGB(rgbValue: rgbValue).cgColor
       btn.layer.borderWidth = width
    }
    
    class func convertDateFormatter(date: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"//this your string date format
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
    dateFormatter.locale = Locale(identifier: "your_loc_id")
    let convertedDate = dateFormatter.date(from: date)
    guard dateFormatter.date(from: date) != nil else {
    assert(false, "no date from string")
    return ""
    }
    dateFormatter.dateFormat = "dd-MM-yyyy HH:mm a"///this is what you want to convert format
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
    let timeStamp = dateFormatter.string(from: convertedDate!)
    print(timeStamp)
    return timeStamp
    }
    
    
    class func removeNavigationSeparator(controller:UINavigationController) {
           controller.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
           controller.navigationBar.shadowImage = UIImage()
       }
    
    
    //Transparent navigation
       class func transparentNavigation(controller:UINavigationController) {
           controller.navigationBar.backgroundColor = UIColor.clear
           controller.navigationBar.isTranslucent = true
           Helper.removeNavigationSeparator(controller: controller)
       }
       
       //NonTransparent navigation
       class func nonTransparentNavigation(controller:UINavigationController) {
           controller.navigationBar.backgroundColor = .white
           controller.navigationBar.isTranslucent = false
           controller.navigationBar.tintColor = Helper.getUIColor(color: Colors.PrimaryText)
           controller.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Helper.getUIColor(color: Colors.PrimaryText)]
       }
    
    
    /*
     Bug Name:- Show the intials for default profile pic
     Fix Date:- 12/05/21
     Fix By  :- Jayram G
     Description of Fix:- Added unique func to create initials and adding image
     */
    class func addedUserImage(profilePic: String?,imageView: UIImageView,fullName:String) {
        /*
         Bug Name:- characters not showing for example for vaibhav sharan, VS should show
         Fix Date:- 17/06/21
         Fix By  :- Jayram G
         Description of Fix:- Added intials pic for default image
         */
        DispatchQueue.main.async {
            if let profilePic = profilePic, profilePic != "",profilePic != " "  {
                imageView.setImageOn(imageUrl: profilePic, defaultImage: Helper.getCustomImage(imageDisplayName: fullName.uppercased(), imageView: imageView))
            }else{
                imageView.image = Helper.getCustomImage(imageDisplayName: fullName.uppercased(), imageView: imageView)
            }
        }
    }
    
    /*
     Feat Name::- DP PlaceHolder with first character of firstname and lastname
     Feat Date:- 03/04/21
     Feat By  :- Nikunj C
     Description of Feat:- create default placeholder
     */

    
    
    
    //Show Alert
     class func showAlert(head:String, message:String ) {
         
         let alert = UIAlertController(title: head, message: message, preferredStyle: UIAlertController.Style.alert)
         
        alert.addAction(UIAlertAction(title: "OK".localized, style: .default))
         if  UIApplication.getTopMostViewController()!.isKind(of: UIAlertController.self) {
             print("UIAlertController is already presented")
         }else{
            DispatchQueue.main.async {
                UIApplication.getTopMostViewController()?.present(alert, animated: true, completion: nil)
            }
         }
     }
    
    //Get UIColor from HexColorCode
       class func getUIColor(color:String) -> UIColor {
           var cString:String = color.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
           if (cString.hasPrefix("#")) {
               cString.remove(at: cString.startIndex)
           }
           if ((cString.sorted().count) != 6) {
               return UIColor.gray
           }
           var rgbValue:UInt32 = 0
           Scanner(string: cString).scanHexInt32(&rgbValue)
           return UIColor(
               red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
               green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
               blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
               alpha: CGFloat(1.0)
           )
       }
    
    class func convertGMTDateToLocalFromDate(gmtDate:Date) -> Date {
          let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = "MMM dd, yyyy hh:mm a"
          dateFormatter.timeZone = Helper.getTimeZoneFromPickUpLoaction()
          let newDateStr = dateFormatter.string(from: gmtDate)
          return dateFormatter.date(from: newDateStr)!
      }
    
    class func getTimeZoneFromPickUpLoaction() -> TimeZone? {
        let ud = UserDefaults.standard
        var lat = 24.774265
        var log = 46.738586
        if ud.object(forKey: UserDefaultConstants.getInstance().currentLatitude) != nil{
            lat  = ud.object(forKey: UserDefaultConstants.getInstance().currentLatitude) as! CLLocationDegrees
            log  = ud.object(forKey: UserDefaultConstants.getInstance().currentLongitude)  as! CLLocationDegrees
        }
        let location =   CLLocationCoordinate2D.init(latitude: lat, longitude: log)
        return TimezoneMapper.latLngToTimezone(location)
    }
    
    //Handling Progress Indicator
       class func showPI(string:String , showLabel: Bool = false) {
        Helper.showPI()
       }
       
    
    class func fetchIpDetails() {
        if let url = URL(string: "http://www.geoplugin.net/json.gp") {
            do {
                let contents = try String(contentsOf: url)
                
                if let data = contents.data(using: String.Encoding.utf8) {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]{
                          
                            if let ip = json["geoplugin_request"] as? String {
                                UserDefaults.standard.set(ip, forKey: UserDefaultConstants.getInstance().ipAddress)
                            }
                            
                            if let currentCity = json["geoplugin_city"] as? String{
                                 UserDefaults.standard.set(currentCity, forKey: UserDefaultConstants.getInstance().city)
                            }
                            
                            if let long = json["geoplugin_longitude"] as? String {
                                 UserDefaults.standard.set(long, forKey: UserDefaultConstants.getInstance().long)
                            }
                            
                            if let lat = json["geoplugin_latitude"] as? String {
                                 UserDefaults.standard.set(lat, forKey: UserDefaultConstants.getInstance().lat)
                            }
                            
                            if let country = json["geoplugin_countryName"] as? String {
                                 UserDefaults.standard.set(country, forKey: UserDefaultConstants.getInstance().country)
                            }
                         }
                    } catch {
                        print("Something went wrong")
                    }
                }
            } catch {
                // contents could not be loaded
            }
        } else {
            // the URL was bad!
        }
    }
    
    class func openUrl(string: URL) {
        if !string.absoluteString.contains("http://") && !string.absoluteString.contains("https://"){
            let updatedURL = "http://" + string.absoluteString
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: updatedURL)! , options: [:]) { success in
                    if !success {
                    }
                }
            } else {
                UIApplication.shared.openURL(URL(string: updatedURL)!)
            }

        }else{
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(string, options: [:]) { success in
                    if !success {
                    }
                }
            } else {
                UIApplication.shared.openURL(string)
            }
        }
    }
    
}


extension String{
    
    static func addImageToString(text: String ,image: UIImage) -> NSAttributedString{

        let attributedString = NSMutableAttributedString(string: text)
        let textAttach =  NSTextAttachment()
        textAttach.image = image
        textAttach.bounds = CGRect.init(x: 0, y: -3, width: 20, height: 20)
        let attrStringWithImage = NSAttributedString(attachment: textAttach)
        attributedString.replaceCharacters(in: NSMakeRange(0,0), with: attrStringWithImage)
        return  attributedString
    }
}

//MARK:- Date Extension
extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSAttributedStringKeyDictionary(_ input: [String: Any]) -> [NSAttributedString.Key: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}


//class LoadingProgress: UIView {
//
//    @IBOutlet weak var progressImage: UIImageView!
//    private static var obj: LoadingProgress? = nil
//    static var flagClose    = false
//
//    static var shared: LoadingProgress {
//        if obj == nil {
//            obj = UINib(nibName: "LoadingProgress", bundle: Bundle.main).instantiate(withOwner: nil, options: nil)[0] as? LoadingProgress
//            obj?.frame = UIScreen.main.bounds
//        }
//        return obj!
//    }
//
//    @IBOutlet weak var loadingHead: UILabel!
//
//    private func setup() {
//        DispatchQueue.main.async {
//            self.loadingHead.textColor = .black
//            self.loadingHead.font = Utility.Font.Regular.ofSize(15)
//            let window:UIWindow = UIApplication.shared.delegate!.window!!
//            window.windowLevel = UIWindow.Level.alert
//            window.addSubview(self)
//            self.transform = CGAffineTransform.identity.scaledBy(x: 0.0, y: 0.0)
//
//            UIView.animate(withDuration: 0.01, delay: 0.01, options: .beginFromCurrentState, animations: {() -> Void in
//                self.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
//            }, completion: {(_ finished: Bool) -> Void in
//            })
//        }
//    }
//
//    func showPI(message: String ,showLabel: Bool) {
//        setup()
////         Fonts.setPrimaryMedium(loadingHead)
//        DispatchQueue.main.async {
//            self.loadingHead.text = message
//            let jeremyGif = UIImage.gifImageWithName("loading_orange")
//            self.progressImage.image = jeremyGif
//            self.loadingHead.isHidden = !showLabel
//        }
//
//        let when = DispatchTime.now() + 30
//        DispatchQueue.main.asyncAfter(deadline: when){
//            self.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
//            UIView.animate(withDuration: 0.01, delay: 0.01, options: .beginFromCurrentState, animations: {() -> Void in
//                self.transform = CGAffineTransform.identity.scaledBy(x: 0.0, y: 0.0)
//            }, completion: {(_ finished: Bool) -> Void in
//                if (LoadingProgress.obj != nil) {
//                    self.removeFromSuperview()
//                }
//            })
//        }
//    }
//
//    func _hide() {
//        if (LoadingProgress.obj != nil) {
//            DispatchQueue.main.async {
//                 self.removeFromSuperview()
//            }
//        }
//    }
//
//    func setLabel(text:String) {
//        loadingHead.text = text
//    }
//}

