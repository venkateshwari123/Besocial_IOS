//
//  WalletActivatedViewController.swift
//  PicoAdda
//
//  Created by A.SENTHILMURUGAN on 1/11/1399 AP.
//  Copyright © 1399 Rahul Sharma. All rights reserved.
//

import UIKit
protocol NavigateDelegate {
    func donePressed()
}
class WalletActivatedViewController: UIViewController {

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var walletActivatedLbl: UILabel!
    
    
    var delegate: NavigateDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.layer.cornerRadius = 5
        self.navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: "KYC Verification".localized)
        walletActivatedLbl.text = "Pending KYC verification".localized
        doneButton.setTitle("Okay".localized, for: .normal)
        contentLabel.text = "KYC application submitted and pending review, we will let you know the status of your KYC via email and notification".localized + "."
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
     
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
        self.dismiss(animated: true) {
            self.delegate?.donePressed()
        }
   }
    
}
