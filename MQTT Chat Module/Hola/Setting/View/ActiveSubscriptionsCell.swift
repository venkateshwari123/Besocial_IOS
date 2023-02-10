//
//  ActiveSubscriptionsCell.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 12/12/20.
//  Copyright © 2020 Rahul Sharma. All rights reserved.
//

import UIKit

class ActiveSubscriptionsCell: UITableViewCell {

    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var removeButtonOutlet: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        descriptionLabel.font = Utility.Font.Regular.ofSize(11)
        userNameLabel.font = Utility.Font.SemiBold.ofSize(14)
        removeButtonOutlet.setTitle("Cancel".localized, for: .normal)
        removeButtonOutlet.titleLabel?.font = Utility.Font.SemiBold.ofSize(14)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setCellData(data: SubscribersListModel){
        self.userImageView.makeCornerRadious(readious: self.userImageView.frame.width / 2)
        if data.isSubscriptionCancelled == 1 {
            self.removeButtonOutlet.setTitle("Cancelled".localized, for: .normal)
        }else{
            self.removeButtonOutlet.setTitle("Cancel".localized, for: .normal)
        }
        if let timeStamp = data.startDateTimeStamp {
            
            let Date:Date = Helper.getDateObj(fromTimeStamp: String(Int(timeStamp)))
            if var date = Date.toString(dateFormat: "dd") as? String{
                switch date {
                case "01","21","31":
                    date = date + "st"
                case "02","22":
                    date = date + "nd"
                case "03","23":
                    date = date + "rd"
                default:
                    date = date + "th"
                }
                self.descriptionLabel.text = "\(data.subscriptionAmout ?? 0.0) " + "coins charged on the".localized + " \(date) ".localized + "of every month".localized
            }
        }
        
        /*
         Bug Name:- Show the intials for default profile pic
         Fix Date:- 17/05/21
         Fix By  :- Jayram G
         Description of Fix:- setting initials image when user not uploaded profile pic
         */
        let fullName = data.firstName + " " + data.lastName
        Helper.addedUserImage(profilePic: data.profilePic, imageView: self.userImageView, fullName: fullName)
        self.userNameLabel.text = data.userName
        
    }
    
}
