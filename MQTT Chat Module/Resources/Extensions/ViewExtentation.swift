//
//  ViewExtentation.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 16/08/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import Foundation

public extension UIView {
    
    
    //MARK:- View setups
    
    /// To make corner radious to a view
    ///
    /// - Parameter readious: radious of that view
    func makeCornerRadious(readious: CGFloat){
        self.layer.cornerRadius = readious
        self.clipsToBounds = true
    }
    
    func addBlurredViewOnImage(size: CGRect){
        let view = UIView()
        view.frame = size
        view.isOpaque = true
        self.isOpaque = true
        let image = UIImage(named: "Lock")
        let imageView = UIImageView()
        imageView.image = image
        if AppConstants.appType == .picoadda {
            imageView.frame = CGRect(x: view.frame.width / 2 - ((view.frame.width / 2) / 2), y: view.frame.width / 2 - ((view.frame.width / 2) / 2), width: view.frame.width / 2, height: view.frame.height / 2)
        }else{
            imageView.frame = CGRect(x: view.frame.origin.x + (((view.frame.width) / 2) / 2) - 7, y: view.frame.height / 2 - ((view.frame.height / 2) / 2), width: view.frame.height / 2, height: view.frame.height / 2)
        }
        
        view.addSubview(imageView)
        self.addSubview(view)
    }
    
    /// To make border width of a view
    ///
    /// - Parameters:
    ///   - width: width of border
    ///   - color: color of border
    func makeBorderWidth(width: CGFloat, color: UIColor){
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }
    
    /// To make shadow to a view
    ///
    /// - Parameter color: color of shadow
    func makeShadowEffect(color: UIColor){
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = CGSize(width: 3, height: 3)
        self.layer.shadowOpacity = 0.7
        self.layer.shadowRadius = 3
    }
    
    func makeShadowForSearchView(){
        let shadowSize : CGFloat = 5.0
        let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2,
                                                   y: -shadowSize / 2,
                                                   width: self.frame.size.width + shadowSize,
                                                   height: self.frame.size.height + shadowSize))
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowOpacity = 0.5
        self.layer.cornerRadius = 5.0
        self.layer.shadowRadius = 5.0
        self.layer.shadowPath = shadowPath.cgPath
    }
    
    /// To make gradient background of a view
    func setGradientBackground() {
        let colorTop =  UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.0).cgColor
        let colorBottom = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.5).cgColor
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.bounds
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    //To make gradient color on a view
    func makeGradiantColor(topColor: UIColor, bottomColor: UIColor){
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.bounds
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    /// To make left to right gradient to a user view
    func makeGradientToUserView(){
        let leftColor = Helper.hexStringToUIColor(hex: AppColourStr.gradientLeftColor)
        let rightColor = Helper.hexStringToUIColor(hex: AppColourStr.gradientRightColor)
        self.makeLeftToRightGeadient(leftColor: leftColor, rightColor: rightColor)
    }
    
    /// To make gradient to a view from left to right
    ///
    /// - Parameters:
    ///   - leftColor: left color
    ///   - rightColor: right color
    func makeLeftToRightGeadient(leftColor: UIColor, rightColor: UIColor){
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [leftColor.cgColor, rightColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.frame = self.bounds
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func makeTopToBottomGeadient(topColor: UIColor, bottomColor: UIColor){
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [topColor.withAlphaComponent(0.4).cgColor, bottomColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.frame = self.bounds
        self.layer.insertSublayer(gradientLayer, at: 0)
    }

    
    //MARK:- Animations
    //To make popup animation
    func popUpAnimation(){
        self.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { (finished) in
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                self.backgroundColor = UIColor.black.withAlphaComponent(0.2)
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: { (finished) in
                
            })
        }
    }
    
    
    //To pop down animation and remover view from superview
    func popDownAnimation(animationDone: @escaping (Bool) -> ()){
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
            self.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { (finished) in
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
                self.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            }, completion: { (finished) in
                self.removeFromSuperview()
                animationDone(finished)
            })
        }
    }
    
    
    /// To make animation for favourite or like button
    func popUpDoubletapFavouritAnimation() {
//        let animation = CABasicAnimation(keyPath: "transform.scale")
//        animation.duration = 0.3
//        animation.repeatCount = 1
//        animation.fromValue = 1.0
//        animation.toValue = 0.5
//        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//        self.layer.add(animation, forKey: "zoom")
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {() -> Void in
            self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.alpha = 1.0
        }, completion: {(_ finished: Bool) -> Void in
            UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: {() -> Void in
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: {(_ finished: Bool) -> Void in
                UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {() -> Void in
                    self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                    self.alpha = 0.0
                }, completion: {(_ finished: Bool) -> Void in
                    self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                })
            })
        })
    }
    
    
    /// view animation for single tap to like a post
    ///
    /// - Parameters:
    ///   - changeImage: image to change
    ///   - view: image view on which image view change
    func singleTapLikeButtonAnimation(changeImage: UIImage, view: UIImageView){
        UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .curveEaseIn], animations: {() -> Void in
            self.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }, completion: {(_ finished: Bool) -> Void in
            view.image = changeImage
            UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .curveEaseOut], animations: {() -> Void in
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: {(_ finished: Bool) -> Void in
                
            })
        })
    }
    
    /// view animation for single tap to like a post
    ///
    /// - Parameters:
    ///   - changeImage: image to change
    ///   - view: button on which image view change
    func changeImageOnButton(changeImage: UIImage, view: UIButton){
        UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .curveEaseIn], animations: {() -> Void in
            self.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }, completion: {(_ finished: Bool) -> Void in
//            view.image = changeImage
            view.setImage(changeImage, for: UIControl.State.normal)
            UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .curveEaseOut], animations: {() -> Void in
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: {(_ finished: Bool) -> Void in
                
            })
        })
    }
}

extension UIView {
    
    // In order to create computed properties for extensions, we need a key to
    // store and access the stored property
    fileprivate struct AssociatedObjectKeys {
        static var tapGestureRecognizer = "MediaViewerAssociatedObjectKey_mediaViewer"
    }
    
    fileprivate typealias Action = (() -> Void)?
    
    // Set our computed property type to a closure
    fileprivate var tapGestureRecognizerAction: Action? {
        set {
            if let newValue = newValue {
                // Computed properties get stored as associated objects
                objc_setAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let tapGestureRecognizerActionInstance = objc_getAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer) as? Action
            return tapGestureRecognizerActionInstance
        }
    }
    
    // This is the meat of the sauce, here we create the tap gesture recognizer and
    // store the closure the user passed to us in the associated object we declared above
    public func addTapGestureRecognizer(action: (() -> Void)?) {
        self.isUserInteractionEnabled = true
        self.tapGestureRecognizerAction = action
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // Every time the user taps on the UIImageView, this function gets called,
    // which triggers the closure we stored
    @objc fileprivate func handleTapGesture(sender: UITapGestureRecognizer) {
        if let action = self.tapGestureRecognizerAction {
            action?()
        } else {
            print("no action")
        }
    }
    
}
