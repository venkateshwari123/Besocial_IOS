//
//  FriendRequestViewController.swift
//  Starchat
//
//  Created by 3Embed on 28/06/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher

class FriendRequestViewController: UIViewController {

    @IBOutlet weak var tvMessage: UITextView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblUserFullName: UILabel!
    @IBOutlet weak var imgUserProfile: UIImageView!
    var userProfile : UserProfile!
    var addContactsViewModel : AddContactsViewModel = AddContactsViewModel.init(api: AddContactsAPI())

    override func viewDidLoad() {
        super.viewDidLoad()
        lblUserFullName.text = userProfile.firstName + " " + userProfile.lastName
        lblUserName.text = userProfile.userName
        let userImageUrl = userProfile.profilePic
        /*
         Bug Name:- Show the intials for default profile pic
         Fix Date:- 12/05/21
         Fix By  :- Jayram G
         Description of Fix:- setting initials image when user not uploaded profile pic
         */
        Helper.addedUserImage(profilePic: userImageUrl, imageView: imgUserProfile, fullName: userProfile.firstName + " " + userProfile.lastName)
        
        let text = "Hi \(userProfile.userName), Im \(Utility.getLoggedInUserProfile()?.userName ?? "")"
        tvMessage.text = text
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.tintColor = .black
        Utility.navigationBarWithLeftRight("Friend Request", inViewController: self, rightButton: nil)
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
    
    @IBAction func btnSendRequest_Tapped(_ sender: Any) {
        self.addContactsViewModel.sendRequest(toUserId: userProfile.userId, andMessage: tvMessage.text!)
        self.addContactsViewModel.didUpdate = { response in
            print(response)
             NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshAddContacts"), object: nil)
            self.userProfile.friendStatusCode = 3
            self.navigationController?.popViewController(animated: true)
        }
        self.addContactsViewModel.didError = { error in
            print(error)
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
