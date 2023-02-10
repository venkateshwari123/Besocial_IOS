//
//  UIViewExtensions.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 02/08/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

//@IBDesignable
class CircleBackgroundView: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.size.height / 2;
        layer.masksToBounds = true;
    }
}

extension UIButton{
    
    func setImage(stuUrl: String?, defaultImage: UIImage){
        if let url = stuUrl{
            self.kf.setImage(with: URL(string:url), for: .normal, placeholder: nil, options: [.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: { (image, error, CacheType, url) in
            })
        }else{
            self.setImage(#imageLiteral(resourceName: "defaultImage"), for: .normal)
        }
    }
}


//Pan Gesture
public enum PanDirection: Int {
    case up, down, left, right
    public var isVertical: Bool { return [.up, .down].contains(self) }
    public var isHorizontal: Bool { return !isVertical }
}

public extension UIPanGestureRecognizer {
    
    public var direction: PanDirection? {
        let velocity = self.velocity(in: view)
        let isVertical = fabs(velocity.y) > fabs(velocity.x)
        switch (isVertical, velocity.x, velocity.y) {
        case (true, _, let y) where y < 0: return .up
        case (true, _, let y) where y > 0: return .down
        case (false, let x, _) where x > 0: return .right
        case (false, let x, _) where x < 0: return .left
        default: return nil
        }
    }
}


class PostGradientView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        guard let theLayer = self.layer as? CAGradientLayer else {
            return;
        }
        let colorTop =  UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.0)
        let colorBottom = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.5)
        theLayer.colors = [colorTop.cgColor, colorBottom.cgColor]
        theLayer.locations = [0.0, 1.0]
        theLayer.frame = self.bounds
    }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
}


extension UIView {
    // for borderColor and borderWidth
    func makeBorderColorAndBorderWidth(_ borderColor:CGColor,borderWidth:CGFloat)
    {
        self.layer.borderColor = borderColor
        self.layer.borderWidth = borderWidth
    }
    
    func makeImageCornerRadius(_ cornerRadius: CGFloat){
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = false
        self.clipsToBounds = true
    }
    
    func addShadowToText() {
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 0.5
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: -0.5)
    }
    
    /* Bug Name : make this rotate a bit slower please , it’s too fast at the moment
     Fix Date : 04-May-2021
     Fixed By : Jayaram G
     Description Of Fix : Reduced rotating duration 2 to 1.5
     */
    func startRotating(duration: Double = 2.0) {
        let kAnimationKey = "rotation"
         
        if self.layer.animation(forKey: kAnimationKey) == nil {
            let animate = CABasicAnimation(keyPath: "transform.rotation")
            animate.duration = duration
            animate.repeatCount = Float.infinity
            animate.fromValue = 0.0
            animate.toValue = CGFloat(Double.pi) * 2.0
            self.layer.add(animate, forKey: kAnimationKey)
        }
    }
    func stopRotating() {
        let kAnimationKey = "rotation"
         
        if self.layer.animation(forKey: kAnimationKey) != nil {
            self.layer.removeAnimation(forKey: kAnimationKey)
        }
    }
    
    func makeViewShadowInDownSide(_ shadowCOlor:CGColor,shadowRadius:CGFloat,shadowOffset:CGSize,shadowOpacity:Float){
        self.clipsToBounds = false
        self.layer.shadowColor = shadowCOlor
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowOpacity = shadowOpacity
    }
    
    func makeShadowOf(width:CGFloat, height:CGFloat){
        
        self.layer.cornerRadius = 4
        // Drop Shadow
        let squarePath = UIBezierPath(rect:CGRect.init(x: 0, y:0 , width: width, height: height)).cgPath
        
        self.layer.shadowPath = squarePath;
        //sender.layer.shadowRadius = 4
        self.layer.shadowOffset = CGSize(width: CGFloat(0.5), height: CGFloat(0.5))
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = false
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}


extension UIView{
    
    func setViewRadiusandShadow( cornerRadius : CGFloat = 0.0 , viewBoaderColor : UIColor , viewBoaderWidth : CGFloat = 0.0 , masksToBounds : Bool ){
        self.makeCornerRadious(readious: cornerRadius)
        self.layer.borderColor = viewBoaderColor.cgColor
        self.layer.borderWidth = viewBoaderWidth
        self.layer.masksToBounds = masksToBounds
    }
    
    
    func setViewRadiusandShadow( cornerRadius : CGFloat = 0.0  , isShadowEnable : Bool = false , shadowColor : UIColor = .gray ,viewBoaderWidth : CGFloat = 0.0 , viewBoaderColor : UIColor = .white , shadowOffSet : CGSize = CGSize.zero , shadowOpacity : Float = 0.0 , shadowRadius : CGFloat = 0.0 , masksToBounds : Bool   ){
       self.makeCornerRadious(readious: cornerRadius)
        self.layer.borderColor = viewBoaderColor.cgColor
        self.layer.borderWidth = viewBoaderWidth
        self.layer.masksToBounds = masksToBounds
        
        if isShadowEnable {
            
            setShadowToView( shadowColor : shadowColor  , shadowOffSet : shadowOffSet , shadowOpacity :shadowOpacity , shadowRadius : shadowRadius , masksToBounds : masksToBounds)
        }
    }
    
    func setShadowToView( shadowColor : UIColor  , shadowOffSet : CGSize = CGSize.zero , shadowOpacity : Float = 0.0 , shadowRadius : CGFloat = 0.0 , masksToBounds : Bool){
        self.layer.masksToBounds = masksToBounds
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOffset = shadowOffSet
    }
    
    func radiusForSpecificCorner(corners:UIRectCorner,cornerRadius:CGFloat){
        let size = CGSize(width: cornerRadius, height: cornerRadius)
        let bezierPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: size)
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = self.bounds
        shapeLayer.path = bezierPath.cgPath
        self.layer.mask = shapeLayer
    }
}


extension UILabel{
    
    func addMandatoryStar(){
        if var title = self.text{
            title = title + "*"
             let attributedString = NSMutableAttributedString(string:title)
            attributedString.setColorForText(textForAttribute: title, withColor: self.textColor, fonts: self.font)
             attributedString.setColorForText(textForAttribute: "*", withColor: .red , fontSize: 14 )
            self.attributedText = attributedString
        }
    }
}


extension UITextField{

    @IBInspectable var doneAccessory: Bool{
        get{
            return self.doneAccessory
        }
        set (hasDone) {
            if hasDone{
                addDoneButtonOnKeyboard()
            }
        }
    }

    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
         done.tintColor = .darkGray
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        self.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction() {
        self.resignFirstResponder()
    }

}


// MARK: - NSMutableAttributedString
extension NSMutableAttributedString {
    
    /// function to create NSMutableAttributedString , just pass the text , color & font size , used for create multicolored text
    ///
    /// - Parameters:
    ///   - textForAttribute: string to modify
    ///   - color: color
    ///   - fontSize: font size
    func setColorForText(textForAttribute: String, withColor color: UIColor , fontSize : CGFloat = 24 , fonts : UIFont = UIFont.boldSystemFont(ofSize: 15) ) {
        let range: NSRange = self.mutableString.range(of: textForAttribute, options: .caseInsensitive)
        
        
        // Swift 4.2 and above
//        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        
        // Swift 4.1 and below
//        self.addAttribute(  NSAttributedString.Key.foregroundColor, value: color, range: range)
        
        
        
        self.addAttributes([NSAttributedString.Key.font  : fonts  , NSAttributedString.Key.foregroundColor : color ], range: range)
    }

}

extension Double {
    func getDateStringFromUnixTime(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> Date {
        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = dateStyle
//        dateFormatter.timeStyle = timeStyle
        return Date(timeIntervalSince1970: self)
    }
}

extension UIView {
    func applyCoinsAnimation(indexAt:Int,fromView:UIView,coins:String, image: UIImage?) {
        if image != nil {
            let bubbleImageView = UIImageView(image: image)
            let size: CGSize = CGSize(width: image!.size.width, height: image!.size.height)
            bubbleImageView.frame = CGRect(x: self.frame.size.width - 45,
                                           y: self.frame.size.height - 20,
                                           width: size.width, height: size.height)
            self.addSubview(bubbleImageView)
            
            let zigzagPath = UIBezierPath()
            let oX: CGFloat = bubbleImageView.frame.origin.x
            let oY: CGFloat = bubbleImageView.frame.origin.y
            
            // the moveToPoint method sets the starting point of the line
            zigzagPath.move(to: CGPoint(x: oX, y: oY))
            var ey: CGFloat = 0
            var ex: CGFloat = 0
            
            switch indexAt {
            case 6:
                ex = oX + 27
                ey = oY - 56 * 2
            case 5:
                ex = oX + 20
                ey = oY - 60 * 2
            case 4:
                ex = oX + 3
                ey = oY - 80 * 2
            case 3:
                ex = oX - 34
                ey = oY - 70 * 2
            case 2:
                ex = oX - 20
                ey = oY - 100 * 2
            case 1:
                ex = oX - 3
                ey = oY - 40 * 2
            default:
                break
            }
            
            let coinsText = UILabel()
            if indexAt == 5 {
                coinsText.text = coins
                coinsText.font = Utility.Font.Regular.ofSize(0.1)
                coinsText.textColor = Helper.getUIColor(color:"efd101")
                var frameForCoins: CGRect = bubbleImageView.frame
                frameForCoins.origin.x = frameForCoins.origin.x + 100
                frameForCoins.size.width = 120
                frameForCoins.size.height = 40
                coinsText.frame = frameForCoins
                self.addSubview(coinsText)
            }
            
    //        // add the end point and the control points
           zigzagPath.addLine(to: CGPoint(x: ex, y: ey))
    //
           CATransaction.begin()
            CATransaction.setCompletionBlock({
                // transform the image to be 1.3 sizes larger to
                // give the impression that it is popping
                bubbleImageView.removeFromSuperview()
                coinsText.removeFromSuperview()
            })
            
            var animationTime = 0.5
            if indexAt == 5 {
                animationTime = 0.8
                coinsText.font = Utility.Font.Regular.ofSize(0.2)
                coinsText.alpha = 0.2
                UIView.animate(withDuration:0.5, animations: {
                    coinsText.alpha = 1.0
                    coinsText.font = Utility.Font.Bold.ofSize(40)
                })
            }
            
            
            let pathAnimation = CAKeyframeAnimation(keyPath: "position")
            pathAnimation.duration = animationTime
            pathAnimation.path = zigzagPath.cgPath
            pathAnimation.fillMode = CAMediaTimingFillMode.forwards
            pathAnimation.isRemovedOnCompletion = false
            bubbleImageView.layer.add(pathAnimation, forKey: "movingAnimation")
            coinsText.layer.add(pathAnimation, forKey: "movingAnimation")
            CATransaction.commit()
        } else {
            let bubbleImageView = UIImageView(image: UIImage(named:"coin2"))
            let size: CGFloat = 20
            bubbleImageView.frame = CGRect(x: self.frame.size.width - 70, y: fromView.frame.origin.y, width: size, height: size)
            self.addSubview(bubbleImageView)
            
            let zigzagPath = UIBezierPath()
            let oX: CGFloat = bubbleImageView.frame.origin.x
            let oY: CGFloat = bubbleImageView.frame.origin.y
            
            // the moveToPoint method sets the starting point of the line
            zigzagPath.move(to: CGPoint(x: oX, y: oY))
            var ey: CGFloat = 0
            var ex: CGFloat = 0
            
            switch indexAt {
            case 6:
                ex = oX + 27
                ey = oY - 56 * 2
            case 5:
                ex = oX + 20
                ey = oY - 60 * 2
            case 4:
                ex = oX + 3
                ey = oY - 80 * 2
            case 3:
                ex = oX - 34
                ey = oY - 70 * 2
            case 2:
                ex = oX - 20
                ey = oY - 100 * 2
            case 1:
                ex = oX - 3
                ey = oY - 40 * 2
            default:
                break
            }
            
            let coinsText = UILabel()
            if indexAt == 5 {
                coinsText.text = coins
                coinsText.font = Utility.Font.Regular.ofSize(0.1)
                coinsText.textColor = Helper.getUIColor(color:"efd101")
                var frameForCoins: CGRect = bubbleImageView.frame
                frameForCoins.origin.x = frameForCoins.origin.x + 100
                frameForCoins.size.width = 120
                frameForCoins.size.height = 40
                coinsText.frame = frameForCoins
                self.addSubview(coinsText)
            }
            
    //        // add the end point and the control points
           zigzagPath.addLine(to: CGPoint(x: ex, y: ey))
    //
           CATransaction.begin()
            CATransaction.setCompletionBlock({
                // transform the image to be 1.3 sizes larger to
                // give the impression that it is popping
                bubbleImageView.removeFromSuperview()
                coinsText.removeFromSuperview()
            })
            
            var animationTime = 0.5
            if indexAt == 5 {
                animationTime = 0.8
                coinsText.font = Utility.Font.Regular.ofSize(0.2)
                coinsText.alpha = 0.2
                UIView.animate(withDuration:0.5, animations: {
                    coinsText.alpha = 1.0
                    coinsText.font = Utility.Font.Bold.ofSize(40)
                })
            }
            
            
            let pathAnimation = CAKeyframeAnimation(keyPath: "position")
            pathAnimation.duration = animationTime
            pathAnimation.path = zigzagPath.cgPath
            pathAnimation.fillMode = CAMediaTimingFillMode.forwards
            pathAnimation.isRemovedOnCompletion = false
            bubbleImageView.layer.add(pathAnimation, forKey: "movingAnimation")
            coinsText.layer.add(pathAnimation, forKey: "movingAnimation")
            CATransaction.commit()
        }
    }
}

