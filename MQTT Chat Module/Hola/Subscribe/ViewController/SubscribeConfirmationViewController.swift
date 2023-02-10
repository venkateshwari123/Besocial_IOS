//
//  SubscribeConfirmationViewController.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 08/02/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import UIKit
protocol SubscribeConfirmationVCDelegate{
    func inSufficientBalance(userName : String)
    func navigateToSubcribeSuccess(fullName :String,userId: String)
    func navigateToUnSubcribeSuccess(model: UserProfileModel)
}
class SubscribeConfirmationViewController: UIViewController {
    
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!

    @IBOutlet weak var cancelLabelText: UILabel!
    
    
    let profileViewModel = ProfileViewModel()
    var userDataModel:UserProfileModel?
    var isFromProfilePage:Bool = false
    var socialModelData:SocialModel?
    var delegate:SubscribeConfirmationVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageLabel.font = Utility.Font.SemiBold.ofSize(16)
        self.userImageView.makeCornerRadious(readious: self.userImageView.frame.width / 2)
        if isFromProfilePage {
            Helper.addedUserImage(profilePic: userDataModel?.profilePic, imageView: self.userImageView, fullName: (userDataModel?.firstName ?? "") + " " + (userDataModel?.lastName ?? ""))
            if let isSubscribe = userDataModel?.isSubscribe, isSubscribe == 0{
                let fullStringForSubscribe = NSMutableAttributedString(string: "Are you sure you want to start subscribing to \(self.userDataModel?.firstName ?? "") \(self.userDataModel?.lastName ?? "") for ")
                let image1AttachmentForSubscribe = NSTextAttachment()
                image1AttachmentForSubscribe.image = UIImage(named: "dollar")?.resizeImageUsingVImage(size: CGSize(width: 12, height: 12))
                let image1StringForSubscribe = NSAttributedString(attachment: image1AttachmentForSubscribe)
                fullStringForSubscribe.append(image1StringForSubscribe)
                fullStringForSubscribe.append(NSAttributedString(string: " \(self.userDataModel?.subscriptionAmount ?? 0.0) coins/month ?"))

                
                self.messageLabel.attributedText
                    = fullStringForSubscribe
            }else{
                self.messageLabel.text = "Are you sure you want to stop subscribing to \(self.userDataModel?.userName ?? "")?"

                if let timeStamp = self.userDataModel?.subscriptionValidate {
                    let Date:Date = Helper.getDateObj(fromTimeStamp: String(Int(timeStamp)))
                    self.cancelLabelText.text = "Your current billing cycle ends on \(Date.toString(dateFormat: "dd MMM yyyy")) , so your subscription to \(self.userDataModel?.userName ?? "") will remain active till then and it will stop there after."
                }
            }
        }else{
            Helper.addedUserImage(profilePic: socialModelData?.profilePic, imageView: self.userImageView, fullName: socialModelData?.fullNameWithSpace ?? "D")
            let fullStringForSubscribe = NSMutableAttributedString(string: "Are you sure you want to start subscribing to \(self.socialModelData?.fullNameWithSpace ?? "") for ")
                let image1AttachmentForSubscribe = NSTextAttachment()
                image1AttachmentForSubscribe.image = UIImage(named: "dollar")?.resizeImageUsingVImage(size: CGSize(width: 12, height: 12))
                let image1StringForSubscribe = NSAttributedString(attachment: image1AttachmentForSubscribe)
                fullStringForSubscribe.append(image1StringForSubscribe)
                fullStringForSubscribe.append(NSAttributedString(string: " \(self.socialModelData?.subscriptionAmount ?? 0.0) coins/month ?"))

                    
                self.messageLabel.attributedText
                    = fullStringForSubscribe
                
            

        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func confirmAction(_ sender: Any) {
        subscribeUserApi()
    }
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func subscribeUserApi() {
        
        if isFromProfilePage {
            if self.userDataModel?.isSubscribe == 0 {
                self.profileViewModel.subscribeAndUnSubscribeApiCall(isSubscribe:true, userId: self.userDataModel?.userId ?? "") { (success, error) in
                    print(success)
                    if success {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppConstants.notificationObserverKeys.refreshUserDetails), object: nil)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshHomeScreen"), object: nil)
                        DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: {
                            if let lastName = self.userDataModel?.lastName as? String {
                                self.delegate?.navigateToSubcribeSuccess(fullName: self.userDataModel?.firstName ?? "" + " " + lastName, userId: self.userDataModel?.userId ?? "")
                            }else{
                                self.delegate?.navigateToSubcribeSuccess(fullName: self.userDataModel?.firstName ?? "", userId: self.userDataModel?.userId ?? "")
                            }
                            
                        })
                        }
                    }else{
                        if error?.code == 403 {
                            DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: {
                                self.delegate?.inSufficientBalance(userName: self.userDataModel?.userName ?? "")
                            })
                            }
                        }else if error?.code == 405 {
                            Helper.showAlertViewOnWindow("Warning".localized, message: "You already subscribed this user".localized + ".")
                        }
                        DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                        }
                        
                    }
                }
            }else{
                self.profileViewModel.subscribeAndUnSubscribeApiCall(isSubscribe:false, userId: self.userDataModel?.userId ?? "") { (success, error) in
                    print(success)
                    if success {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppConstants.notificationObserverKeys.refreshUserDetails), object: nil)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshHomeScreen"), object: nil)
                        DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: {
                            if self.userDataModel != nil {
                                self.delegate?.navigateToUnSubcribeSuccess(model: self.userDataModel!)
                            }
                                        })
                        }
                    }else{
                        if error?.code == 403 {
                            DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: {
                                self.delegate?.inSufficientBalance(userName: self.userDataModel?.userName ?? "")
                            })
                            }
                        }else if error?.code == 405 {
                            Helper.showAlertViewOnWindow("Warning".localized, message: "You already subscribed this user".localized + ".")
                        }
                        DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                        }
                        
                    }
                }
            }
        }else{
                self.profileViewModel.subscribeAndUnSubscribeApiCall(isSubscribe:true, userId: self.socialModelData?.userId ?? "") { (success, error) in
                    print(success)
                    if success {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppConstants.notificationObserverKeys.refreshUserDetails), object: nil)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshHomeScreen"), object: nil)
                        DispatchQueue.main.async {
                         self.dismiss(animated: true, completion: {
                            self.delegate?.navigateToSubcribeSuccess(fullName: self.socialModelData?.fullNameWithSpace ?? "", userId: self.socialModelData?.userId ?? "")
                         })
                        }
                    }else{
                        if error?.code == 403 {
                            DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: {
                                self.delegate?.inSufficientBalance(userName: self.socialModelData?.userName ?? "")
                            })
                            }
                        }else if error?.code == 405 {
                            Helper.showAlertViewOnWindow("Warning".localized, message: "You already subscribed this user".localized + ".")
                        }
                        DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                        }
                        
                    }
                }
        }

    }
    
    func showInSufficientBalance(){
        if isFromProfilePage {
            
        }else{
            
        }
    }
}
