//
//  CancelSubscriptionsTableViewCell.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 12/12/20.
//  Copyright © 2020 Rahul Sharma. All rights reserved.
//

import UIKit

class CancelSubscriptionsTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var amountBtn: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var renewBtnOutlet: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        descriptionLabel.font = Utility.Font.Regular.ofSize(11)
        userNameLabel.font = Utility.Font.SemiBold.ofSize(14)
        renewBtnOutlet.setTitle("Renew".localized, for: .normal)
        renewBtnOutlet.titleLabel?.font = Utility.Font.SemiBold.ofSize(14)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setCellData(data: SubscribersListModel){
        self.userImageView.makeCornerRadious(readious: self.userImageView.frame.width / 2)
        /*
         Bug Name:- Not showing subscription cancelled time
         Fix Date:- 8/06/21
         Fix By  :- Jayram G
         Description of Fix:- Handled data from response , and showing.
         */
        if let timeStamp = data.endDateTimeStamp, let cancelledDate = data.cancelledDate {
            let Date:Date = Helper.getDateObj(fromTimeStamp: String(Int(timeStamp)))
            let cancelledDate:Date = Helper.getDateObj(fromTimeStamp: String(Int(cancelledDate)))
            self.descriptionLabel.text = "Subscription cancelled on".localized + " \(cancelledDate.toString(dateFormat: "dd MMM yyyy")), " + "active till".localized + " \(Date.toString(dateFormat: "dd MMM yyyy"))"
        }
        
        self.amountBtn.setTitle(" \(data.subscriptionAmout ?? 0.0)", for: .normal)
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
