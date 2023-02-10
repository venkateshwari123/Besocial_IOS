//
//  WalletKycViewController.swift
//  DoChat
//
//  Created by A.SENTHILMURUGAN on 1/3/1399 AP.
//  Copyright © 1399 Rahul Sharma. All rights reserved.
//

import UIKit

class WalletKycViewController: UIViewController {

  
    @IBOutlet weak var iAgreeBtn: UIButton!
    @IBOutlet weak var welcomelbl: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tapAgreeLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpUI()
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
    
    func setUpUI(){
        self.navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: "\(AppConstants.AppName) " + "Wallet".localized)
        iAgreeBtn.layer.cornerRadius = 5
        welcomelbl.text = "Welcome to the".localized + " \(AppConstants.AppName) " + "wallet".localized
        tapAgreeLbl.text = "Tap Agree to active your wallet".localized + ". " + "Use your wallet balance to spend and send your cash securely using your".localized + " \(AppConstants.AppName) " + "wallet".localized + "."
        iAgreeBtn.setTitle("I Agree".localized, for: .normal)
    
    }
    

    @IBAction func agreeAction(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: AppConstants.StoryBoardIds.WalletKyc, bundle: nil)
               guard let resultViewController = storyBoard.instantiateViewController(withIdentifier: String.init(describing: CompleteIdentificationViewController.self)) as? CompleteIdentificationViewController else {return}
               self.navigationController?.pushViewController(resultViewController, animated: true)
    }
}


 
