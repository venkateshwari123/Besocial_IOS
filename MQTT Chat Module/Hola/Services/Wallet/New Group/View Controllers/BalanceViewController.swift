
//
//  BalanceViewController.swift
//  Citysmart Life
//
//  Created by Rahul Sharma on 4/20/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class BalanceViewController: UIViewController {
    
    //MARK:- All Outlets 
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topUpbtn: UIButton!
    @IBOutlet weak var withDrawBtn: UIButton!
    
    //MARK:- view cylce
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        uiDesign()
    }
    
    //MARK:-UI Design
    func uiDesign(){
        topView.makeBorderColorAndBorderWidth(UIColor.black.cgColor, borderWidth: 0.4)
        topUpbtn.makeCornerRadious(readious: 23)
        withDrawBtn.makeBorderColorAndBorderWidth(UIColor.black.cgColor, borderWidth: 0.7)
        withDrawBtn.makeCornerRadious(readious: 23)
    }
    
    //MARK:- Button Actions
    @IBAction func backToWalletVc(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
