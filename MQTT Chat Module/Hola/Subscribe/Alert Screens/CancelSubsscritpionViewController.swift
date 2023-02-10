//
//  CancelSubsscritpionViewController.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 18/01/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import UIKit
protocol CancelSubsscritpionViewControllerDelegate {
    func confirmNavigation()
}
class CancelSubsscritpionViewController: UIViewController {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var msgLabel: UILabel!
    
    
    var delegate:CancelSubsscritpionViewControllerDelegate?
    var data:SubscribersListModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        msgLabel.font = Utility.Font.Bold.ofSize(16)
        cancelBtn.titleLabel?.font = Utility.Font.Bold.ofSize(16)
        confirmBtn.titleLabel?.font = Utility.Font.Bold.ofSize(16)
        
        self.userImageView.makeCornerRadious(readious: self.userImageView.frame.width / 2)
        cancelBtn.makeBorderColorAndBorderWidth(Utility.appColor().cgColor, borderWidth: 1)
        if self.data != nil {
            guard let dataObj = data else {return}
            let fullName = dataObj.firstName + " " + dataObj.lastName
            /*
             Bug Name:- Show the intials for default profile pic
             Fix Date:- 12/05/21
             Fix By  :- Jayram G
             Description of Fix:- setting initials image when user not uploaded profile pic
             */
            Helper.addedUserImage(profilePic: dataObj.profilePic, imageView: self.userImageView, fullName: fullName)
            self.usernameLabel.text = dataObj.userName
            self.msgLabel.text = "Are you sure you want to stop subscribing to \(dataObj.userName ?? "user") ?".localized
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancelBtnAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmBtnAction(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.confirmNavigation()
        }
    }
    
}
