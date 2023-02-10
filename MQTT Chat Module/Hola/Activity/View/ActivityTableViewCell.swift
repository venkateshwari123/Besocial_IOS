//
//  ActivityTableViewCell.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 10/09/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

protocol ActivityTableViewCellDelegate {
    func userNameClicked(name: String)
    func hashTagClicked(tag: String)
    func userImagetap(activityType: ActivityType, index: Int)
}

class ActivityTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var userImageContainerView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: ActiveLabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var imageContainerHeightConstarint: NSLayoutConstraint!
    
    @IBOutlet weak var postImageButtonOutlet: UIButton!
    
    @IBOutlet weak var followCountLabel: UILabel!
    
    var isRequestCell: Bool = false
    var Index: Int = 0
    var activityType: ActivityType = .Follow
    
    var delegate: ActivityTableViewCellDelegate?
    
    var isLodedOnce: Bool = false
    
    //MARK:- View life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isLodedOnce{
            self.isLodedOnce = true
            self.userImageContainerView.makeCornerRadious(readious: self.userImageContainerView.frame.size.width / 2)
            self.userImageView.makeCornerRadious(readious: self.userImageView.frame.size.width / 2)
            self.userImageContainerView.makeGradientToUserView()
        }
    }
    
    /// to set cell data for activity table view cell
    func setCellDataFor(data: Any){
        if let modelData = data as? ActivityCommentModel{
            self.setCommentAndLikeModel(modelData: modelData)
        }else if let modelData = data as? ActivityFollowModel{
            self.setFollowModel(modelData: modelData)
        }
//        self.handleUserNameAndHashTag()
    }
    //set data for comment and like data
    func setCommentAndLikeModel(modelData: ActivityCommentModel){
        
        self.followCountLabel.isHidden = true
        self.imageContainerHeightConstarint.constant = 55.0
        self.imageContainerView.isHidden = false
        self.layoutIfNeeded()
        let fullName = modelData.firstName + " " + modelData.lastName
        Helper.addedUserImage(profilePic: modelData.profilePic, imageView: self.userImageView, fullName: fullName)
        
        var detailText: String
        /*Bug Name :- Not showing payments in activity
         Fix Date :- 19/07/2021
         Fixed By :- Jayaram G
         Description Of fix :- handled type 10
         */
        switch modelData.type {
        case 7:
            /*Bug Name :- Show post image for tip sent
             Fix Date :- 22/09/2021
             Fixed By :- Jayaram G
             Description Of fix :- removed hideImageView code
             */
            
            /*Bug Name :- Changed tip sent message
             Fix Date :- 27/09/2021
             Fixed By :- Jayaram G
             Description Of fix :- removed extra to message
             */
            detailText = modelData.message
        case 8:
            detailText = modelData.message + "@\(modelData.userName)"
            self.hideImageView()
        case 9:
            detailText = modelData.message 
        case 10:
            detailText = modelData.message
            self.hideImageView()
        default:
            if modelData.targetUserName == ""{
                detailText = modelData.message
            }else{
                detailText = "@\(modelData.userName)" + " \(modelData.message) " + "@\(modelData.targetUserName)"
            }
        }
        
        self.userNameLabel.text = detailText
        /*
         Bug Name:- Time stamps not showing correctly in activity
         Fix Date:- 14/06/21
         Fix By  :- Jayram G
         Description of Fix:- Handling 10 and 13 letters timestamp
         */
        if String(Int(modelData.timeStamp)).count > 10 {
            let time = Helper.getTimeStamp(timeStamp: modelData.timeStamp)
            let timeArr = time.components(separatedBy: " ")
            var timeString = ""
            for item in timeArr{
                timeString.append(item.localized + " ")
            }
            self.detailsLabel.text = timeString
        }else {
            let time = Helper.getTimeStamp(timeStamp: modelData.timeStamp)
            let timeArr = time.components(separatedBy: " ")
            var timeString = ""
            for item in timeArr{
                timeString.append(item.localized + " ")
            }
            self.detailsLabel.text = timeString
        }
        
        
        if modelData.postData?.mediaType == 1{
            if let url = modelData.postData?.imageUrl{
                let endIndex = url.index(url.endIndex, offsetBy: -3)
                var truncated = url.substring(to: endIndex)
                truncated = truncated + "jpg"
                self.postImageView.setImageOn(imageUrl: truncated, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
            }else{
                self.postImageView.image = #imageLiteral(resourceName: "defaultPicture")
            }
        }else{
            self.postImageView.setImageOn(imageUrl: modelData.postData?.imageUrl, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
        }
        self.handleUserNameAndHashTag()
    }
    
    func getDateObj(fromTimeStamp timeStamp: String) -> Date {
        let tStamp =  UInt64(timeStamp)!
        let timeStampInt = tStamp/1000
        let msgDate = Date(timeIntervalSince1970: TimeInterval(timeStampInt))
        return msgDate
    }
    
    func lastMessageTime(date: Date)->String {
        let dateFormatter = DateFormatter()
        let today = NSCalendar.current.isDateInToday(date)
        if(today) {
            return "Today".localized
        }
        else if(NSCalendar.current.isDateInYesterday(date)){
            return "Yesterday".localized
        }
        else{
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            let dateString = dateFormatter.string(from: date)
            return dateString
        }
    }
    
    /// to set cell data for follow
    func setFollowModel(modelData: ActivityFollowModel){
        
        hideImageView()
        self.followCountLabel.isHidden = true
        let fullName = modelData.firstName + " " + modelData.lastName
        Helper.addedUserImage(profilePic: modelData.profilePic, imageView: self.userImageView, fullName: fullName)
        self.userNameLabel.text = "@\(String(describing: modelData.userName)) " + "\(String(describing: modelData.message)) " + "@\(String(describing: modelData.targetUserName))"
        
        let time = Helper.getTimeStamp(timeStamp: modelData.timeStamp)
        let timeArr = time.components(separatedBy: " ")
        var timeString = ""
        for item in timeArr{
            timeString.append(item.localized + " ")
        }
        let timeStamp = timeString
        self.detailsLabel.text = timeStamp
        self.handleUserNameAndHashTag()
    }
    
    
    /// To handle @ and # tap
    func handleUserNameAndHashTag(){
        
        // Attach block for handling taps on hashtag
        self.userNameLabel.handleHashtagTap { (tag) in
            print(tag)
            if let delegate = self.delegate{
                delegate.hashTagClicked(tag: tag)
            }
        }
        
        // Attach block for handling taps on usenames
        self.userNameLabel.handleMentionTap { (name) in
            print(name)
            if let delegate = self.delegate{
                delegate.userNameClicked(name: name)
            }
        }
    }
    
    //to set data in user requested cell
    func setCellDataForUserRequest(modelData: FollowRequestModel, count: Int){
        
        hideImageView()
        self.isRequestCell = true
        self.followCountLabel.isHidden = false
        self.userNameLabel.text = "Follow Requests".localized
        self.detailsLabel.text = "Accept or deny requests".localized
        let fullName = modelData.firstName + " " + modelData.lastName
        Helper.addedUserImage(profilePic: modelData.profilePic, imageView: self.userImageView, fullName: fullName)
        self.followCountLabel.text = "\(count)"
    }
    
    ///To set data in channel requested cell
    func setCellDataForChannleRequest(modelData: RequestedChannelModel, count: Int){
        
        hideImageView()
        self.isRequestCell = true
        self.followCountLabel.isHidden = false
        self.userNameLabel.text = "Subscription Request".localized
        self.detailsLabel.text = "Approve or ignore requests".localized
        self.userImageView.setImageOn(imageUrl: modelData.channelImageUrl, defaultImage: #imageLiteral(resourceName: "defaultImage"))
        self.followCountLabel.text = "\(count)"
    }
    
    ///To hide image view for follow
    func hideImageView(){
        self.imageContainerHeightConstarint.constant = 0.0
        self.imageContainerView.isHidden = true
        self.layoutIfNeeded()
    }
    
    
    //MARK:- Button Action
    @IBAction func userImageButtonAction(_ sender: Any) {
        if !self.isRequestCell{
            self.delegate?.userImagetap(activityType: activityType, index: Index)
        }
    }
    
}
