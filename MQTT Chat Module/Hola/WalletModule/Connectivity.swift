//
//  Connectivity.swift
//  Yelo
//
//  Created by 3Embed on 09/08/19.
//  Copyright © 2019 rahulSharma. All rights reserved.
//

import Foundation
import Alamofire

class Connectivity1 {
    
    static let sharedInstance = Connectivity1()
    let net = Alamofire.NetworkReachabilityManager(host: "www.google.com")
    
    class func isConnectedToInternet() ->Bool {
        if NetworkReachabilityManager()!.isReachable {
            return true
        }else {
            DispatchQueue.main.async {
                Helper.showAlert(head: StringConstants.getInstance().connect(), message: StringConstants.getInstance().noInternet() )
            }
            return false
        }
    }
    
        func startListening(completion: @escaping (Bool) -> ()) {
            net?.startListening()
            net?.listener = { status in
                switch status {
                    
                case .reachable(.ethernetOrWiFi),.reachable(.wwan):
    //                MQTT.sharedInstance.createConnection()
                    Toast.hideMessage()
    //                ReachabilityView.instance.hide()
                    print("The network is reachable over the WiFi connection")
                    completion(true)
                    
                    //            case ):
                    //                Toast.hideMessage()
                    //                print("The network is reachable over the WWAN connection")
                //
                case .notReachable:
                    print("The network is not reachable")
    //                Toast.showNegativeMessage(message: StringConstants.noIntern())
    //                ReachabilityView.instance.show()
    //                MQTT.sharedInstance.disconnectMQTTConnection()
                    completion(false)
                    
                case .unknown:
    //                ReachabilityView.instance.show()
    //                MQTT.sharedInstance.disconnectMQTTConnection()
                    completion(false)
                    
                    //            case  :
                    //                Toast.hideMessage()
                    //                print("It is unknown whether the network is reachable")
                    
                }
            }
        }
    
    func  stopListening() {
        net?.stopListening()
    }
}


class Toast {
    class private func showAlert(backgroundColor:UIColor, textColor:UIColor, message:String)
    {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let label = UILabel(frame: CGRect.zero)
        label.tag = 98765462342
        label.textAlignment = NSTextAlignment.center
        label.text = message
        label.font = UIFont(name: Roboto.Bold, size: 15)
        label.adjustsFontSizeToFitWidth = true
        
        label.backgroundColor =  backgroundColor //UIColor.whiteColor()
        label.textColor = textColor //TEXT COLOR
        
        label.sizeToFit()
        label.numberOfLines = 4
        label.layer.shadowColor = UIColor.gray.cgColor
        label.layer.shadowOffset = CGSize(width: 4, height: 3)
        label.layer.shadowOpacity = 0.3
        label.frame = CGRect(x: 0, y: appDelegate.window!.frame.maxY, width: appDelegate.window!.frame.size.width, height: 50)
        
        label.alpha = 1
        let window = appDelegate.window
        window?.windowLevel = UIWindow.Level.statusBar
        window?.addSubview(label)
        
        var basketTopFrame: CGRect = label.frame;
        basketTopFrame.origin.y = appDelegate.window!.frame.maxY - 50;
        
//        UIView.animate(withDuration
//            :1, delay: 0.0, usingSpringWithDamping: 0.1, initialSpringVelocity: 0.1, options: UIView.AnimationOptions.curveEaseOut, animations: { () -> Void in
//                label.frame = basketTopFrame
//        }
        UIView.animate(withDuration: 0.5, animations: {
             label.frame = basketTopFrame
            })
    }
    
    class func showPositiveMessage(message:String)
    {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        if let subviews = appDelegate.window?.subviews{
            for view in subviews{
                if view.tag == 98765462342{
                    view.removeFromSuperview()
                }
            }
        }
        
        showAlert(backgroundColor: UIColor.systemGreen, textColor: UIColor.white, message: message)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            hideMessage()
        }
    }
    
    class func showNegativeMessage(message:String)
    {
//        if NetworkReachabilityManager()!.isReachable {
//            return
//        }
        showAlert(backgroundColor: UIColor.black, textColor: UIColor.white, message: message)
    }
    
    class func hideMessage() {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        if let label = appDelegate.window?.viewWithTag(98765462342) {
//            UIView.animate(withDuration:0.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: UIView.AnimationOptions.curveEaseIn, animations: { () -> Void in
//                label.alpha = 0
//            },  completion: {
//                (value: Bool) in
//                label.removeFromSuperview()
//            })
//
            UIView.animate(withDuration: 0.5, animations: {
                 label.alpha = 0
            }) { (_) in
                label.removeFromSuperview()
            }
        }
    }
}
