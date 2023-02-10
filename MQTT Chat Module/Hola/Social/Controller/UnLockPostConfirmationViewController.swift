//
//  UnLockPostConfirmationViewController.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 05/11/20.
//  Copyright © 2020 Rahul Sharma. All rights reserved.
//

import UIKit
protocol UnLockPostConfirmationViewControllerDelegate {
    func updateData(index: Int)
    func showSuccessScreen()
    func moveToInSufficientVc()
}
class UnLockPostConfirmationViewController: UIViewController {

        @IBOutlet weak var confirmButton: UIButton!
        @IBOutlet weak var messageLabel: UILabel!
        @IBOutlet weak var cancelButton: UIButton!
    
    let unLockPostVm = UnLockPostViewModel()
    var socialModelData:SocialModel?
    var delegate:UnLockPostConfirmationViewControllerDelegate?
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        confirmButton.titleLabel?.font = Utility.Font.Bold.ofSize(16)
        cancelButton.titleLabel?.font = Utility.Font.Bold.ofSize(16)
        self.messageLabel.font = Utility.Font.SemiBold.ofSize(17)
        if let amount = socialModelData?.postAmount {
            let fullString = NSMutableAttributedString(string: "Please confirm you want to purchase this post for ")
            let image1Attachment = NSTextAttachment()
            image1Attachment.image = UIImage(named: "dollar")?.resizeImageUsingVImage(size: CGSize(width: 15, height: 15))
            let image1String = NSAttributedString(attachment: image1Attachment)
            
            fullString.append(image1String)
            fullString.append(NSAttributedString(string: " \(amount) Coins ?"))
            
            self.messageLabel.attributedText = fullString
        }
        
        cancelButton.makeBorderColorAndBorderWidth(Utility.appColor().cgColor, borderWidth: 1)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func confirmAction(_ sender: Any) {
        unLockPaidPostApi()
     }
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
     }
    

    func unLockPaidPostApi() {
        guard let postId = self.socialModelData?.postId else {return}
        self.unLockPostVm.buyPost(strUrl: AppConstants.buyPost, postId: postId) { (success, error) in
            Helper.hidePI()
            if success {
                Utility.updateWalletBalance()
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshHomeScreen"), object: nil)

                self.dismiss(animated: true, completion: {
                    self.delegate?.showSuccessScreen()
                })
                self.delegate?.updateData(index: self.index)
            }else {
                /* Bug Name :- Handle Backend error
                                  Fix Date :- 09/06/2021
                                  Fixed By :- Jayaram G
                                  Description Of Fix :- Handling 403 code
                 */

                if error?.code == 403 {
                    self.delegate?.moveToInSufficientVc()
                }
            }
        }
    }
}

