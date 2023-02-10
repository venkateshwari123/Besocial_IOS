//
//  UnSubscribedSuccessfullyViewController.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 01/03/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import UIKit

class UnSubscribedSuccessfullyViewController: UIViewController {
    
        @IBOutlet weak var messageLabel: UILabel!
    

    
    
    let profileViewModel = ProfileViewModel()
    var userDataModel:UserProfileModel?
    var isFromProfilePage:Bool = false
    var socialModelData:SocialModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageLabel.font = Utility.Font.SemiBold.ofSize(15)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            self.dismiss(animated: true, completion: nil)
        }
        // Do any additional setup after loading the view.
    }
    

    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
  
}
