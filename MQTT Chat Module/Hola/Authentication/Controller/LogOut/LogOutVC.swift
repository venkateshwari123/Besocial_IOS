//
//  LogOutVC.swift
//  Shoppd
//
//  Created by 3Embed on 5/5/20.
//  Copyright © 2020 Nabeel Gulzar. All rights reserved.
//

import UIKit

class LogOutVC: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var logoutTitle: UILabel!
    var titleDescription:String?
    var logoutTitleText:String?
    var canceTitle:String?
    var logOutAction:((Int)->Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func initialSetUp(){
        logoutTitle.text = titleDescription ?? ""
        logoutButton.setTitle(logoutTitleText ?? "", for: .normal)
        cancelButton.setTitle(canceTitle ?? "", for: .normal)
        Fonts.setFont(logoutTitle, fontFamiy: .primary(.Medium), size: .standard(.h16), color: UIColor.Dark.black)
        Fonts.setFont(cancelButton, fontFamiy: .primary(.SemiBold), size: .standard(.h14), color: .white)
        Fonts.setFont(logoutButton, fontFamiy: .primary(.SemiBold), size: .standard(.h14), color: UIColor.blue)
        logoutButton.layer.borderWidth = 0.8
        logoutButton.layer.cornerRadius = 2
        logoutButton.layer.borderColor = UIColor.blue.cgColor
        cancelButton.backgroundColor = UIColor.blue
        cancelButton.layer.cornerRadius = 2
    }
    
    @IBAction func logoutAction(_ sender: UIButton) {
        dismiss(animated: true) {
            if sender == self.logoutButton{
                self.logOutAction?(0)
            }
        }
    }

}
