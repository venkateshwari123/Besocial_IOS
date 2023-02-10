//
//  InSufficientCoinsViewController.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 07/01/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import UIKit
protocol InSufficientCoinsViewControllerDelegate {
    func dismissToNavigateWallet()
}
class InSufficientCoinsViewController: UIViewController {

    @IBOutlet weak var insufficientMessage: UILabel!
    @IBOutlet weak var addCoinsBtn: UIButton!
    @IBOutlet weak var popUpView: UIView!
    var delegate:InSufficientCoinsViewControllerDelegate?
    var isFromSubscribe:Bool = false
    @IBOutlet weak var detailsLabel: UILabel!
    var userName:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCoinsBtn.titleLabel?.font = Utility.Font.Bold.ofSize(16)
        insufficientMessage.font = Utility.Font.Bold.ofSize(15)
        insufficientMessage.text = "Insufficient coins".localized + ", " + "please recharge".localized
        addCoinsBtn.setTitle("Add Coins".localized, for: .normal)
        if #available(iOS 13.0, *) {
            popUpView.makeBorderWidth(width: 0.5, color: UIColor.label)
        } else {
            popUpView.makeBorderWidth(width: 0.5, color: UIColor.black)
            // Fallback on earlier versions
        }
        popUpView.makeShadowEffect(color: .darkGray)
        /*
         Bug Name:- If subscription fails due to lack of coins a push needs to be sent out - "Subscription to "known as" failed due to lack of coin balance , you will not be able to enjoy unlimited access to all of "know as"'s content". You will have to subscribe to "known as" again to gain access to their content"
         Fix Date:- 25/06/21
         Fix By  :- Jayaram G
         Description of Fix:- Showing text for subscription alert
         */
        if isFromSubscribe {
            detailsLabel.text = "Subscription to".localized + " \(userName) " + "failed due to lack of coin balance".localized + " , " + "you will not be able to enjoy unlimited access to all of".localized + " \(userName)'s" + " " + "content".localized + ". " + "You will have to subscribe to".localized + " \(userName) " + "again to gain access to their content".localized
        }else{
            detailsLabel.text = ""
        }
        // Do any additional setup after loading the view.
    }
    
    /*
     Bug Name:- network handling
     Fix Date:- 20/04/21
     Fix By  :- Nikunj C
     Description of Fix:- check connectivity and show popup for no internet
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Helper.checkConnectionAvaibility(view: self.view)

    }
    

    @IBAction func dismissScreen(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func addCoinsBtnAction(_ sender: UIButton) {
        self.dismiss(animated: false) {
            self.delegate?.dismissToNavigateWallet()
        }
        self.navigationController?.popViewController(self, animated: false, completion: {
            self.delegate?.dismissToNavigateWallet()
        })
    }
}
