//
//  TransferAlertViewController.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 26/06/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import UIKit

class TransferAlertViewController: UIViewController {

    @IBOutlet weak var sendingAmount: UILabel!
    @IBOutlet weak var processingAmount: UILabel!
    @IBOutlet weak var receivingAmount: UILabel!
    @IBOutlet weak var receiverDescriptionLabel: UILabel!
    
    var receiverName:String = ""
    var receiverCurrency:String = ""
    var receiverAmount:String = ""
    var processingFee:String = ""
    var sendAmount:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.processingAmount.text = "\(receiverCurrency) \(self.processingFee)"
        self.receiverDescriptionLabel.text = "\(self.receiverName) will receive"
        self.receivingAmount.text = "\(receiverCurrency) \(self.receiverAmount)"
        self.sendingAmount.text = "\(Utility.getWalletCurrenySymbol()) \(sendAmount)"
        // Do any additional setup after loading the view.
    }
    

    @IBAction func dismissBtnAction(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
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
