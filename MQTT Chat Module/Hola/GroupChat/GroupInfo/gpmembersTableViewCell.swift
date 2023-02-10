//
//  gpmembersTableViewCell.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 16/02/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher

class gpmembersTableViewCell: UITableViewCell {
    
    @IBOutlet weak var gpImageView: UIImageView!
    @IBOutlet weak var gpmemName: UILabel!
    @IBOutlet weak var gpmemStatus: UILabel!
    @IBOutlet weak var gpAdmin: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        gpAdmin.text = "Admin".localized
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    
    func setgroupMembersinfoIncell(info dict:[String:Any]){
        
        self.gpImageView.layer.cornerRadius = (self.gpImageView.frame.size.width)/2
   
        /*
         Bug Name:- status should be bio here
         Fix Date:- 17/06/21
         Fixed By:- Jayaram G
         Description of Fix:- Showing local status for self user
         */
        

        if let isAdmin = dict["memberIsAdmin"] as? Bool{
            if isAdmin == true {
                self.gpAdmin.text  = "Admin".localized
            }else {self.gpAdmin.text  = "" }
        }
        
        let favDatabase:[Contacts] =  Helper.getFavoriteDataFromDatabase1()

        guard  let  otherUserNum =  dict["memberIdentifier"] as? String else { return }
        var userName: String = otherUserNum
        if let name = dict["userName"] as? String{
            userName = name
        }
        self.gpmemName.text = userName
        if let gpImage = dict["memberImage"] as? String {
            Helper.addedUserImage(profilePic: gpImage, imageView: self.gpImageView, fullName: userName)
        }else{
            Helper.addedUserImage(profilePic: nil, imageView: self.gpImageView, fullName: userName)
        }
//        let predicate = NSPredicate.init(format:"registerNum == %@", otherUserNum)
//        let favArr =  favDatabase.filter({predicate.evaluate(with: $0)})
        let favArr = favDatabase.filter { (member) -> Bool in
            if let id = member.fullName, id == otherUserNum{
                return true
            }else{
                return false
            }
        }
        if favArr.count ==  0 {
//            self.gpmemName.text = otherUserNum
        }else{
            let contact = favArr[0]
//            self.gpmemName.text = contact.fullName
            if let userImageUrl =  contact.profilePic{
                Helper.addedUserImage(profilePic: userImageUrl, imageView: self.gpImageView, fullName: userName)
            }else{
                Helper.addedUserImage(profilePic: nil, imageView: self.gpImageView, fullName: userName)
            }
        }
        
        //check for Own number heree
        if  let userNum  = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.userName) as? String{
            if otherUserNum == userNum {
                self.gpmemName.text  = "You"
            }
        }
        
        
        print("*******Group Chat Details \(dict)")
        if  let userNum  = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.userName) as? String, otherUserNum == userNum{
            self.gpmemStatus.text = Utility.getUserStatus()
        }else{
            if let status  = dict["memberStatus"] as? String {
                self.gpmemStatus.text = status
                if status == ""  || status == " "{
                    self.gpmemStatus.text = AppConstants.defaultStatus
                }
            }else{
                self.gpmemStatus.text = AppConstants.defaultStatus
            }
        }
    }
}
