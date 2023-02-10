//
//  TipSentSuccessfullyViewController.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 17/12/20.
//  Copyright © 2020 Rahul Sharma. All rights reserved.
//

import UIKit
protocol TipSentVCDelegate{
    func updateWallet()
}
class TipSentSuccessfullyViewController: UIViewController {

    @IBOutlet weak var successFullMessageLabel: UILabel!
    var delegate:TipSentVCDelegate? = nil
    var isFromPurchase:Bool = false
    var isFromSendTip:Bool = false
    var isFromSubscribe:Bool = false
    var isFromUnSubscribe:Bool = false
    var fullName = ""
    var userName = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.successFullMessageLabel.font = Utility.Font.SemiBold.ofSize(16)
        if isFromSendTip {
            self.successFullMessageLabel.text = "Tip sent to".localized + " \(userName) " + "Successfully".localized
        }else if isFromPurchase {
            self.successFullMessageLabel.text = "You have successfully purchased this post".localized
        }else if isFromSubscribe {
            self.successFullMessageLabel.text = "Thank you for subscribing to".localized + " \(fullName)"
        }else if isFromUnSubscribe {
            self.successFullMessageLabel.text = "Thank you for subscribing to".localized + " \(fullName)"
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            self.dismiss(animated: true) {
                self.delegate?.updateWallet()
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
