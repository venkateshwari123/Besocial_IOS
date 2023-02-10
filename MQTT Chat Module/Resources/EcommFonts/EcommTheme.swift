//
//  Theme.swift
//  Shoppd
//
//  Created by Rahul Sharma on 09/09/19.
//  Copyright © 2019 Nabeel Gulzar. All rights reserved.
//

import UIKit
import RxAlamofire
import RxSwift
import RxCocoa
import CoreLocation
import Locksmith

struct FontTheme {
    
    enum FontType {
        case installed(FontNames)
        case custom(String)
    }
    enum FontSize {
        case standard(StandardSize)
        case custom(Double)
        var value: Double {
            switch self {
            case .standard(let size):
                return size.rawValue
            case .custom(let customSize):
                return customSize
            }
        }
    }
    enum FontNames: String {
        
        ///Poppins
        case PoppinsBlack           = "Poppins-Black"
        case PoppinsBold            = "Poppins-Bold"
        case PoppinsExtraBold       = "Poppins-ExtraBold"
        case PoppinsExtraLight      = "Poppins-ExtraLight"
        case PoppinsLight           = "Poppins-Light"
        case PoppinsMedium          = "Poppins-Medium"
        case PoppinsRegular         = "Poppins-Regular"
        case PoppinsThin            = "Poppins-Thin"
        case PoppinsSemiBold        = "Poppins-SemiBold"
    }
    enum StandardSize: Double {
        case h1 = 25.0
        case h2 = 22.0
        case h3 = 20.0
        case h4 = 18.0
        case h5 = 16.0
        case h6 = 14.0
        case h7 = 12.0
        case h8 = 10.0
        case h9 = 8.0
    }
    
    var type: FontType
    var size: FontSize
    init(_ type: FontType, size: FontSize) {
        self.type = type
        self.size = size
    }
}

extension FontTheme {
    
    var instance: UIFont {
        
        var instanceFont: UIFont!
        switch type {
        case .custom(let fontName):
            guard let font =  UIFont(name: fontName, size: CGFloat(size.value)) else {
                fatalError("\(fontName) font is not installed, make sure it added in Info.plist and logged with Utility.logAllAvailableFonts()")
            }
            instanceFont = font
        case .installed(let fontName):
            guard let font =  UIFont(name: fontName.rawValue, size: CGFloat(size.value)) else {
                fatalError("\(fontName.rawValue) font is not installed, make sure it added in Info.plist and logged with Utility.logAllAvailableFonts()")
            }
            instanceFont = font
        }
        return instanceFont
    }
}


extension UIColor{
    static let blue                      = Utility.appColor()
    
    struct Light{
        static let black                 = Helper.getUIColor(color: "#040404")
        static let black1                = Helper.getUIColor(color: "#141414")
        static let black2                = Helper.getUIColor(color: "#3D4152")
        static let black3                = Helper.getUIColor(color: "#4A3B3B")
        static let black4                = Helper.getUIColor(color: "#242A4B")
        static let black5                = Helper.getUIColor(color: "#484848")
        static let blue                  =  #colorLiteral(red: 0.5764705882, green: 0.2980392157, blue: 0.9960784314, alpha: 0.5)
        static let blue1                 = Helper.getUIColor(color: "#F20000")
        static let blue2                 = Helper.getUIColor(color: "#F4F4FF")
        static let blue3                 = Helper.getUIColor(color: "#F20000")
        static let blue4                 = Helper.getUIColor(color: "#F20000")
        static let blue5                 = Helper.getUIColor(color: "#F20000")
        static let boarder_gray          = Helper.getUIColor(color: "#D6D5D5")
        static let dim_black             = Helper.getUIColor(color: "#2D2D2D")
        static let gray                  = Helper.getUIColor(color: "#9B9B9B")
        static let gray2                 = Helper.getUIColor(color: "#7B7B7B")
        static let gray3                 = Helper.getUIColor(color: "#A3A3A3")
        static let gray4                 = Helper.getUIColor(color: "#707070")
        static let gray5                 = Helper.getUIColor(color: "#ACACAC")
        static let gray6                 = Helper.getUIColor(color: "#EFF0F4")
        static let green                 = Helper.getUIColor(color: "#527D47")
        static let green2                = Helper.getUIColor(color: "#1C9B57")
        static let red                   = Helper.getUIColor(color: "#FF0000")
        static let red1                  = Helper.getUIColor(color: "#F21900")
        static let white                 = Helper.getUIColor(color: "#F5F5F5")
        static let white1                = Helper.getUIColor(color: "#F8F8F8")
        static let white3                = Helper.getUIColor(color: "#FCFCFC")
        static let white4                = Helper.getUIColor(color: "#FAFAFA")
        static let white5                = Helper.getUIColor(color: "#F9F9F9")
        static let white6                = Helper.getUIColor(color: "#F2F2F2")
        static let white7                = Helper.getUIColor(color: "#F7F7F7")
        static let dim_white             = Helper.getUIColor(color: "#F4F4F4")
        static let orange                = Helper.getUIColor(color: "#FF9402")
        static let green3                = Helper.getUIColor(color: "#D9F6F6")
        static let green4                = Helper.getUIColor(color: "#129601")
    }
    
    struct Dark{
        static let dark_black            = Helper.getUIColor(color: "#1D1A1A")
        static let black                 = Helper.getUIColor(color: "#000000")
        static let gray                  = Helper.getUIColor(color: "#515C6F")
        static let gray2                 = Helper.getUIColor(color: "#858AA8")
        static let gray1                 = Helper.getUIColor(color: "#DEDEDE")
        static let blue                  = Helper.getUIColor(color: "#F20000")
        static let maroon                = Helper.getUIColor(color: "#541871")
        static let orange                = Helper.getUIColor(color: "#FD5E5E")
        static let yellow                = Helper.getUIColor(color: "#FFCD00")
        static let green                 = Helper.getUIColor(color: "#1FAF6D")
        static let green2                = Helper.getUIColor(color: "#2C8F92")
    }
    
    struct Pink{
        static let one = Helper.getUIColor(color: "#B812F2")
        static let two = Helper.getUIColor(color: "#E941CA")
    }
    
    struct Gray{
        static let one      = Helper.getUIColor(color: "#E8E8E8")
        static let two      = Helper.getUIColor(color: "#D5D5D5")
        static let three    = Helper.getUIColor(color: "#919191")
        static let four     = Helper.getUIColor(color: "#AEAEAE")
        static let five     = Helper.getUIColor(color: "#868686")
        static let six      = Helper.getUIColor(color: "#B2B2B2")
        static let seven    = Helper.getUIColor(color: "#7E808C")
        static let eight    = Helper.getUIColor(color: "#EDEDED")
        static let nine     = Helper.getUIColor(color: "#D3D3D3")
        static let ten      = Helper.getUIColor(color: "#F5F4F4")
        static let twelve   = Helper.getUIColor(color: "#E3E3E3")
        static let thirteen = Helper.getUIColor(color: "#BCBFD1")
        static let forteen  = Helper.getUIColor(color: "#9F9F9F")
        static let fifteen  = Helper.getUIColor(color: "#DCDEEA")
        static let sixteen  = Helper.getUIColor(color: "#5E6696")
        static let seventen = Helper.getUIColor(color: "#797979")
        static let eighteen = Helper.getUIColor(color: "#767676")
        static let ninteen  = Helper.getUIColor(color: "#DDDDDD")
    }
}

extension UIView{
    /// Add shadow and radius effect to any view (subclass of UIView)
    func setShadowWithCornerRadius(cornerRadius:CGFloat = 0,shadowColor:UIColor = UIColor.white,shadowOpacity:Float = 0, shadowRadius:CGFloat = 0,shadowOffset:CGSize = .zero){
        self.layer.cornerRadius = cornerRadius
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOffset = shadowOffset
    }
    
    func setColor(colors:(r:Double,g:Double,b:Double,a:Double))->UIColor{
        return UIColor(red: CGFloat(colors.r/255.0), green: CGFloat(colors.g/255.0), blue: CGFloat(colors.b/255.0), alpha: CGFloat(colors.a))
    }
    
    func setCornerRadius(cornerRadius:CGFloat = 5){
        self.layer.cornerRadius = cornerRadius
    }
    
    ///SetBoarder{}
    func setStrikeText(text:String){
        guard let self = self as? UILabel,!text.isEmpty else{return}
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string:text)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))
        self.attributedText = attributeString
    }
    
    func addshadow(top: Bool,
                   left: Bool,
                   bottom: Bool,
                   right: Bool,
                   shadowRadius: CGFloat = 2.0) {
        
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = 1.0
        
        let path = UIBezierPath()
        var x: CGFloat = 0
        var y: CGFloat = 0
        var viewWidth = self.frame.width
        var viewHeight = self.frame.height
        
        // here x, y, viewWidth, and viewHeight can be changed in
        // order to play around with the shadow paths.
        if (!top) {
            y+=(shadowRadius+1)
        }
        if (!bottom) {
            viewHeight-=(shadowRadius+1)
        }
        if (!left) {
            x+=(shadowRadius+1)
        }
        if (!right) {
            viewWidth-=(shadowRadius+1)
        }
        // selecting top most point
        path.move(to: CGPoint(x: x, y: y))
        // Move to the Bottom Left Corner, this will cover left edges
        /*
         |☐
         */
        path.addLine(to: CGPoint(x: x, y: viewHeight))
        // Move to the Bottom Right Corner, this will cover bottom edge
        /*
         ☐
         -
         */
        path.addLine(to: CGPoint(x: viewWidth, y: viewHeight))
        // Move to the Top Right Corner, this will cover right edge
        /*
         ☐|
         */
        path.addLine(to: CGPoint(x: viewWidth, y: y))
        // Move back to the initial point, this will cover the top edge
        /*
         _
         ☐
         */
        path.close()
        self.layer.shadowPath = path.cgPath
    }
    
    func createDottedLine(color: CGColor) {
        let caShapeLayer = CAShapeLayer()
        caShapeLayer.strokeColor = color
        caShapeLayer.lineWidth = 1
        caShapeLayer.lineDashPattern = [5,5] // [dashedwidth, gapwidth]
        let cgPath = CGMutablePath()
        let cgPoint = [CGPoint(x: 0, y: 0), CGPoint(x: self.frame.width, y: 0)]
        cgPath.addLines(between: cgPoint)
        caShapeLayer.path = cgPath
        layer.addSublayer(caShapeLayer)
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func gradientColor(colors:[UIColor],startPoint:CGPoint = CGPoint(x: 0.0, y: 0.5),endPoint:CGPoint = CGPoint(x: 1.0, y: 0.5),cornerRadius:CGFloat = 7,gradientLayer:CAGradientLayer){
        gradientLayer.frame = self.bounds
        
        // Set colors.
        gradientLayer.colors = colors.map{$0.cgColor}

        // Set start point.
        gradientLayer.startPoint = startPoint

        // Set end point.
        gradientLayer.cornerRadius = cornerRadius
        gradientLayer.endPoint = endPoint
        // Insert gradient layer into view's layer heirarchy.
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
}
extension Dictionary{
    static func += (lhs: inout [Key: Value], rhs: [Key: Value]) {
        rhs.forEach { lhs[$0] = $1}
    }
}

extension Encodable {
  var dictionary: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
  }
}

extension String {
    var doubleValue: Double? {
        if self.length == 0 {
            return 0
        }
        return Double(self)
    }
    var floatValue: Float? {
        if self.length == 0 {
            return 0
        }
        return Float(self)
    }
    var integerValue: Int? {
        if self.length == 0 {
            return 0
        }
        return Int(self)
    }
    
    var length: Int {
        return self.sorted().count
    }
    
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!,
                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                          documentAttributes: nil)
        } catch let error as NSError{
            print("error: ", error)
            return nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? self
    }
    
     func format(strings: [String],
                    boldFont: UIFont = UIFont.boldSystemFont(ofSize: 14),
                    boldColor: UIColor = UIColor.blue,
                    inString string: String,
                    font: UIFont = UIFont.systemFont(ofSize: 14),
                    color: UIColor = UIColor.black) -> NSAttributedString {
        let attributedString =
            NSMutableAttributedString(string: string,
                                    attributes: [
                                        NSAttributedString.Key.font: font,
                                        NSAttributedString.Key.foregroundColor: color])
        let boldFontAttribute = [NSAttributedString.Key.font: boldFont, NSAttributedString.Key.foregroundColor: boldColor]
        for bold in strings {
            attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: bold))
        }
        return attributedString
    }
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

extension Double {
    var formattedWithSeparator: String {
        let number = Int(self)
        let val = String(format: "%.2f", self)
        return "\(number.formattedWithInt).\(val.suffix(2))"
    }
}

extension Int{
    fileprivate var formattedWithInt: String {
        return Formatter.withSeparator.string(for: self) ?? ""
    }
}
extension Formatter {
    fileprivate static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.numberStyle = .decimal
        formatter.groupingSize = 3
        formatter.secondaryGroupingSize = 2
        return formatter
    }()
}

extension Notification{
    var keyboardFrame:CGRect?{
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
    }
}

extension Date {
    
 
    func add(_ unit: Calendar.Component, value: Int) -> Date? {
        return Calendar.current.date(byAdding: unit, value: value, to: self)
    }

    var stringDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MMMM/yyyy hh:mm "
        return formatter.string(from: self)
    }
    
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    var month:String{
        let dateFromatter = DateFormatter()
        dateFromatter.dateFormat = "MMM"
        return dateFromatter.string(from: self)
    }
    
    var fullMonth:String{
        let dateFromatter = DateFormatter()
        dateFromatter.dateFormat = "MMMM"
        return dateFromatter.string(from: self)
    }
    

    var weekDay:String{
        return DateFormatter().shortWeekdaySymbols[Calendar.current.component(.weekday, from: self) - 1]
    }
    func near(days: Int) -> [Date] {
        return days == 0 ? [Date()] : (1...abs(days)).map {
            adding(days: $0 * (days < 0 ? -1 : 1) )
        }
    }
    
    func getStringDate(format:String = "dd/MMMM/yyyy hh:mm ")->String{
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
}


extension UISearchBar {
    
    func configureSearchTextfied(color: UIColor,backgroundColor:UIColor,fontName:String = Primary.Regular.rawValue ,size:CGFloat = 12,placeholdertext:String = "",pHFont:String = Primary.Regular.rawValue,pHsize:CGFloat = 12,pHColor:UIColor = UIColor.Gray.four) {
        var textField:UITextField = UITextField()
        let clrChange1 = subviews.flatMap { $0.subviews }
        
        let clrChange = subviews.flatMap { $0.subviews.flatMap{
            $0.subviews
            }}
        clrChange.forEach{
            $0.backgroundColor = backgroundColor
        }
        clrChange1.forEach{
            $0.backgroundColor = backgroundColor
        }
        //UISearchBarTextField
        if let sc = (clrChange.filter { $0 is UITextField }).first as? UITextField{
            textField = sc
        }else if let sc = (clrChange1.filter { $0 is UITextField }).first as? UITextField{
            textField = sc
        }
        textField.backgroundColor = .clear
        textField.font = UIFont(name: fontName, size: size)
        textField.attributedPlaceholder = NSAttributedString(string: placeholdertext, attributes: [NSAttributedString.Key.font:UIFont(name: pHFont, size: pHsize)!,NSAttributedString.Key.foregroundColor:pHColor])
        textField.tintColor = color
        textField.textColor = color
        textField.addAccessoryView()
    }
    

    
    var textField: UITextField? {
        let subViews = self.subviews.flatMap { $0.subviews }
        if #available(iOS 13, *) {
            if let _subViews = subViews.last?.subviews {
                return (_subViews.filter { $0 is UITextField }).first as? UITextField
            }else{
                return nil
            }
            
        } else {
            return (subViews.filter { $0 is UITextField }).first as? UITextField
        }
    }
}

extension UITextView{
    func addAccessoryView(){
        let bar = UIToolbar()
        let reset = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(done))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        bar.items = [flexibleSpace,reset]
        bar.sizeToFit()
        self.inputAccessoryView = bar
    }
    @objc func done(){
        self.resignFirstResponder()
    }
}

extension UITextField{
    func addAccessoryView(){
        let bar = UIToolbar()
        let reset = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneAction))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        bar.items = [flexibleSpace,reset]
        bar.sizeToFit()
        self.inputAccessoryView = bar
    }
    @objc func doneAction(){
        self.resignFirstResponder()
    }
    
    func clear(){
        self.text = ""
    }
    
    func addRightImageToTF(image:String){
        //        rightView = nil
        var y:CGFloat = 0
//        if let tf = self as? HoshiTextField{
//            y = tf.frame.height/3
//        }else{
//            y = 0
//        }
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.height/2, height: self.frame.height))
        let imageView = UIImageView()
        imageView.image = UIImage(named: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        rightView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: rightView.topAnchor, constant: y),
            imageView.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: 0),
            imageView.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: 0),
            imageView.heightAnchor.constraint(equalToConstant: self.frame.height)
        ])
        self.rightView = rightView
        self.rightViewMode = .always
    }
    
    func removeRightView(){
        self.rightView = nil
        self.rightViewMode = .never
    }
    
    
}

class SSBadgeButton: UIButton {
    
    var badgeLabel = UILabel()
    
    var badge: String? {
        didSet {
            addBadgeToButon(badge: badge)
        }
    }
    
    public var badgeBackgroundColor = UIColor.red {
        didSet {
            badgeLabel.backgroundColor = badgeBackgroundColor
        }
    }
    
    public var badgeTextColor = UIColor.white {
        didSet {
            badgeLabel.textColor = badgeTextColor
        }
    }
    
    public var badgeFont = UIFont.systemFont(ofSize: 12.0) {
        didSet {
            badgeLabel.font = badgeFont
        }
    }
    
    public var badgeEdgeInsets: UIEdgeInsets? {
        didSet {
            addBadgeToButon(badge: badge)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addBadgeToButon(badge: nil)
    }
    
    func addBadgeToButon(badge: String?) {
        badgeLabel.text = badge
        badgeLabel.textColor = badgeTextColor
        badgeLabel.backgroundColor = badgeBackgroundColor
        badgeLabel.font = badgeFont
        badgeLabel.sizeToFit()
        badgeLabel.textAlignment = .center
        let badgeSize = badgeLabel.frame.size
        
        let height = max(18, Double(badgeSize.height) + 5.0)
        let width = max(height, Double(badgeSize.width) + 10.0)
        
        var vertical: Double?, horizontal: Double?
        if let badgeInset = self.badgeEdgeInsets {
            vertical = Double(badgeInset.top) - Double(badgeInset.bottom)
            horizontal = Double(badgeInset.left) - Double(badgeInset.right)
            
            let x = (Double(bounds.size.width) - 10 + horizontal!)
            let y = -(Double(badgeSize.height) / 2) - 10 + vertical!
            badgeLabel.frame = CGRect(x: x, y: y, width: width, height: height)
        } else {
            let x = self.frame.width - CGFloat((width / 2.0))
            let y = CGFloat(-(height / 2.0))
            badgeLabel.frame = CGRect(x: x, y: y, width: CGFloat(width), height: CGFloat(height))
        }
        
        badgeLabel.layer.cornerRadius = badgeLabel.frame.height/2
        badgeLabel.layer.masksToBounds = true
        addSubview(badgeLabel)
        badgeLabel.isHidden = badge != nil ? false : true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addBadgeToButon(badge: nil)
        fatalError("init(coder:) has not been implemented")
    }
}

extension UILabel{
    func indexOfAttributedTextCharacterAtPoint(point: CGPoint) -> Int {
        //        assert(self.attributedText != nil, "This method is developed for attributed string")
        let textStorage = NSTextStorage(attributedString: self.attributedText!)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: self.frame.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = self.numberOfLines
        textContainer.lineBreakMode = self.lineBreakMode
        layoutManager.addTextContainer(textContainer)
        
        let index = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return index
    }
}
extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}

extension Helper{
    static private(set) var publicIpAddress:String = "27.59.13.228"
    static let keychain = KeychainSwift()
     static let disposeBag = DisposeBag()
    
    class func getAuthToken()->String?{
         Utility.getUserToken()
      }
    
    class func addLoader(){
        LoaderView.shared.addSpinner()
    }
    
    class func hideLoader(){
        LoaderView.shared.removeSpinner()
    }
    
    class func StoreType()->StoreCategories{
         
        return StoreCategories(rawValue: 8)!
      }
    
    class func setImage(imageView:UIImageView,url:String,defaultImage:UIImage) {
         imageView.image = nil
         imageView.kf.indicatorType = .activity
         let trimmedString = url.trimmingCharacters(in: .whitespaces)
         
         if let encodedHost = trimmedString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed){
             imageView.kf.setImage(with: URL(string: encodedHost), placeholder: defaultImage)
         }
     }
      
    //Set Button Title
    class func setButtonTitle(normal:String,highlighted:String,selected:String,button:UIButton) {
        button.setTitle(normal, for: .normal)
        button.setTitle(highlighted, for: .highlighted)
        button.setTitle(selected, for: .selected)
    }
    class func getHeaderWithAuthorization()->[String:String]{
         
        
         return [
             EComm.ParameterConstants.authorization:Utility.getUserToken(),
             "language":Utility.getSelectedLanguegeCode(),
             EComm.ParameterConstants.platform:"1",
            EComm.ParameterConstants.currencysymbol:Utility.getWalletCurrenySymbol(),
            EComm.ParameterConstants.currencyCode:Utility.getWalletCurreny()
         ]
     }
    
    
    class func getPublicIPAddress(completion: @escaping (Bool)->Void){
        let apiCall = HomeAPICalls()
        apiCall.requestData(url: EComm.BaseURL.PublicIP,header: [ EComm.ParameterConstants.platform:"1"], method:.get)
            _ = apiCall.subject_response_ecom.subscribe(onNext: { responseData in
               if responseData.error == nil{
                   Helper.publicIpAddress = String(data: responseData.data, encoding: .utf8)!
                   completion(true)
               }
           }, onError: { error in
               print(error)
           }, onCompleted: nil, onDisposed: nil).disposed(by: Helper.disposeBag)
       }
    
    class func addBoarderToView(separatorView:UIView,colour:UIColor){
           let shapeLayer:CAShapeLayer = CAShapeLayer()
           let frameSize = separatorView.bounds
           let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: 0)
           shapeLayer.bounds = shapeRect
           shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height)
           shapeLayer.fillColor = UIColor.clear.cgColor
           shapeLayer.strokeColor = colour.cgColor
           shapeLayer.lineWidth = 1.0
           shapeLayer.lineDashPhase = 2.0
           shapeLayer.lineJoin = CAShapeLayerLineJoin.round
           shapeLayer.lineDashPattern = [2,4,2,4]
           shapeLayer.path = UIBezierPath(roundedRect: CGRect(x: frameSize.origin.x, y: shapeRect.height, width: frameSize.size.width, height: 0), cornerRadius: 0).cgPath
           separatorView.layer.addSublayer(shapeLayer)
       }
    
    class func getDateTime(timestamp: Double,format:String = "dd MMM yyyy hh:mm a") -> String {
            var strDate = ""
                
    //        if let unixTime = Double(timestamp) {
                let date = Date(timeIntervalSince1970: timestamp)
                let dateFormatter = DateFormatter()
                let timezone = TimeZone.current.abbreviation() ?? "UTC"  // get current TimeZone abbreviation or set to CET
                dateFormatter.timeZone = TimeZone(abbreviation: timezone) //Set timezone that you want
                dateFormatter.locale = NSLocale.current
                dateFormatter.dateFormat = format //Specify your format that you want
                strDate = dateFormatter.string(from: date)
    //        }
                
            return strDate
        }
    class func addShadowToCustomView(view:UIView,radius:CGFloat = 5,opacity:Float = 1,color:UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.103515625)){
           view.layer.masksToBounds = false
           view.layer.shadowColor = color.cgColor
           view.layer.shadowOpacity = opacity
           view.layer.shadowOffset = CGSize(width: 0, height: 2.0)
           view.layer.shadowRadius = radius
       }
    /// Remove null from Objects
    ///
    /// - Returns: Object without Null
    
    
    class func PullToClose(scrollView:UIScrollView) {
      //  Helper.pullToDismiss = PullToDismiss(scrollView: scrollView)
    }
    //Add shadow to NavigationController
      class func addShadowToNavigationBar(controller:UINavigationController){
          controller.navigationBar.layer.masksToBounds = false
          controller.navigationBar.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.103515625)
          controller.navigationBar.layer.shadowOpacity = 0.8
          controller.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2.0)
          controller.navigationBar.layer.shadowRadius = 2
      }
      
      class func removeShadowToNavigationBar(controller:UINavigationController){
          controller.navigationBar.layer.masksToBounds = true
          controller.navigationBar.layer.shadowColor = UIColor.white.cgColor
          controller.navigationBar.layer.shadowOpacity = 0
          controller.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 0)
          controller.navigationBar.layer.shadowRadius = 0
      }
    class func getHeaderWithLanguage(isPlatform:Bool = false)->[String:String]{
          
          var header = [
              EComm.ParameterConstants.authorization:Helper.getAuthToken()!,
              EComm.ParameterConstants.language:Utility.getSelectedLanguegeCode()
          ]
          if isPlatform{
              header += [
                  EComm.ParameterConstants.platform:"",
              ]
          }
          return header
      }
      
    class func WalletData(walletData:Data){
    
           keychain.set(walletData, forKey: EComm.ParameterConstants.walletData)
       }
       
//       class func WalletData()->WalletTransactionModel?{
//       //    guard let data = keychain.getData(EComm.ParameterConstants.walletData) else{return nil}
//        //   return try? JSONDecoder().decode(WalletTransactionModel.self, from: data)
//        return nil
//       }
       
       class func deleteWallet(){
          // keychain.delete(EComm.ParameterConstants.walletData)
       }
    class func setStarImage(imageView:UIImageView,forRating rating: Double,on:String = "StarOn",off:String = "StarOff",half:String = "Star_half"){
        let starNum:Double = Double(imageView.tag)
        if rating >= starNum {
            imageView.image = UIImage(named: on)!
        } else if rating + 0.5 >= starNum {
            imageView.image = UIImage(named: half)!
        } else {
            imageView.image = UIImage(named: off)!
        }
    }
    
    class func getDateString(value:Date,format:String,zone:Bool) -> String {
           let formatter = DateFormatter()
           formatter.dateFormat = format
           formatter.locale = Locale.init(identifier: "en_US_POSIX")// for 24 hours format
           if zone {
            formatter.timeZone = .current
           }
           let myString = formatter.string(from: value)
           return myString
       }
    
    class func searchCountryCode(countryCode:String)->CountryPicker?{
           return CountryPickerVM.countries.filter{ $0.countryCode == countryCode}.first
       }
    
    /// To Set The Country Flag
      class func countryFlagImage(code: String) -> UIImage {
          let bundle = "assets.bundle/"
          return UIImage(named: bundle + code.lowercased() + ".png") ?? UIImage()
      }
    class func getDateFromISO(isoDate:String) -> String{
          var strDate = ""
          let formatter = DateFormatter()
          formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
          if let date = formatter.date(from: isoDate) {
              strDate = date.stringDate //"dd/MMMM/yyyy hh:mm "
          }
          return strDate
      }
    /// validate phone number
    ///
    /// - Parameters:
    ///   - phoneNumber: phoneNumber
    ///   - code: countryCode
    /// - Returns: true or false
    class func isPhoneNumValid(phoneNumber: String , code:String) -> Bool{
//        let phoneUtil = NBPhoneNumberUtil()
//        do {
//            ///mobileNumber Validation
//            let phoneNumber = try phoneUtil.parse(phoneNumber, defaultRegion: VNHCountryPicker.dialCode(code:code).code)
//            let validPhoneNumber: Bool = phoneUtil.isValidNumber(phoneNumber)
//            print(validPhoneNumber)
//            return validPhoneNumber
//        }
//        catch let error as NSError {
//            print(error.localizedDescription)
//            return false
//        }
        if phoneNumber.count < 15 {
            return true
        }else{
            return false
        }
    }
    
    //Handling Alert Messages
      class func showAlert(message:String, head:String, type:Int) {
          //        Helper.hidePI()
          //        let alert:CommonAlertView = CommonAlertView.shared
          //        alert.showAlert(message: message, head: head, type: type)
//          Helper.hidePI()
//          alertPopup?.dismiss(animated: false, completion: nil)
//          alertPopup = UIAlertController(title:head, message:message, preferredStyle: UIAlertController.Style.alert)
//          alertPopup?.addAction(UIAlertAction(title: StringConstants.OK(), style: UIAlertAction.Style.cancel, handler: nil))
//          if UIApplication.shared.delegate?.window != nil {
//              let vc = Helper.finalController()
//              vc.present(alertPopup!, animated: true, completion: nil)
//          }
//
          
          
      }
    

    
    /// Header for Social API's
    /// - Returns: header parameters
    class func getHeaderForSocial()->[String:String]{
        
        return ["lang":Utility.getSelectedLanguegeCode(),
            "authorization" :Utility.getUserToken()]
    }
    
    
    
    
    
    //Text is Name
    class func isValidName(textName:String) -> Bool {
        
        var returnValue = true
        
        let text = textName.replacingOccurrences(of: " ", with: "")
        let mobileRegEx = "^[a-zA-Z]+$"               //"[A-Za-z]{3}"  // {3} -> at least 3 alphabet are compulsory.
        
        do {
            let regex = try NSRegularExpression(pattern: mobileRegEx)
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
    }
    
    
}


extension Utility{

    class func getCurrency() -> (String,String,String) {
        
           return ("USD","$","1")//1 miles or km
       }
       
       class func getProfileCurrency() -> (currency:String,symbol:String,metric:String) {
    
           return ("INR","₹","1")
       }
    
    ///Saving selected Location
    class func saveAddress(location:[String:Any]) {
        let dict = Helper.nullKeyRemoval(data: location)
        UserDefaults.standard.set(dict, forKey: "SaveAddress")
        UserDefaults.standard.synchronize()

       // UtilityResponse.onNext(true)
    }
    //Getting Saved Location
//    class func getAddress() -> Location {
//        if let data = UserDefaults.standard.object(forKey:"") as? [String : Any] {
//            let location = Location.init(data: data)
//            if let titleTemp = data[""] as? Float, let titleTemp2 = data[""] as? Float{
//                let locationin = CLLocation(latitude: CLLocationDegrees(titleTemp), longitude: CLLocationDegrees(titleTemp2))
//                location.update(data: data, location: locationin)
//            }
//            return location
//        }
//        return Location.init(data: [:])
//    }
    ///Getting Language
       class func getLanguage() -> Language {
           var language = Language([:])
           language.Name = "English"
           language.Code = "en"
           if UserDefaults.standard.string(forKey: "") != nil {
               language.Name = UserDefaults.standard.string(forKey: "")!
               language.Code = UserDefaults.standard.string(forKey: "")!
           }
           return language
       }
    ///Device Details
       static var DeviceId: String {
           
           if let ID: String = UIDevice.current.identifierForVendor?.uuidString {
               return ID
           }
           else {
               return "iPhone_Simulator"
           }
       }
       
       static var DeviceType: Int {
           return 1//"iOS"
       }
}


extension UIViewController {
    
    
    /// Observer for keyboard
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
     /// remove Observer
    func removeObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        /*
         Bug Name:- post uploaded multiple time in Picoadda
         Fix Date:- 26th july 2021
         Fixed By:- Nikunj C
         Description of Fix:- remove createNewPost observer
         */
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "createNewPost"), object: nil)
    }
    
    //Mark:- Keyboard ANimation
    @objc func keyboardWillShow(_ notification: Notification){

    }
    
    @objc func keyboardDidShow(_ notification:Notification){
        
    }
    
    @objc func keyboardWillHide(_ notification: Notification){

    }
}

struct Language {
    
    var Name = ""
    var Code = ""
    init(_ data:[String:Any]) {
        if let dataFrom = data["langCode"] as? String {
            Code = dataFrom
        }
        if let dataFrom = data["lan_name"] as? String {
            Name = dataFrom
        }
    }
}
