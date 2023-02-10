//
//  EmailSentVC.swift
//  Do Chat
//
//  Created by Rahul Sharma on 14/05/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import UIKit
protocol EmailSentVCDelegate {
    func navigateToLoginVc()
}
class EmailSentVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var doneBtn: UIButton!
    var delegateObj: EmailSentVCDelegate? = nil
    var message : String?
    var titleText : String?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let message = self.message {
            messageLabel.text = message
        }
        if let titleText = self.titleText {
            titleLabel.text = titleText
        }
        titleLabel.text = "Check Your Mail".localized
        messageLabel.text = "We have sent you an email with the instructions to set a new password".localized + ", " + "please look out for this email".localized + ", " + "the link will be valid only 60 minutes".localized + "."
        self.doneBtn.setTitle("Ok".localized, for: .normal)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            self.delegateObj?.navigateToLoginVc()
        })
    }
}
