//
//  GroupChatDeliveryStatusCVCell.swift
//  Infra.Market Messenger
//
//  Created by 3Embed Software Tech Pvt Ltd on 30/04/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class GroupChatDeliveryStatusCVCell: UICollectionViewCell {
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var mainView: UIView!
    
    
    @IBOutlet weak var readOrDeliverdStatusLabel: UILabel!
    @IBOutlet weak var readStatusLabel: UILabel!
    @IBOutlet weak var userListTableView: UITableView!
    @IBOutlet weak var remainingUserCountOutlet: UILabel!
    
    var isRead: Bool = false
    var userListWithStatus = [MessageDeliveryStatus]()
    
    var isLoadedFirst: Bool = false
    
    //MARK:- view life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.userListTableView.register(UINib(nibName: "UserStatusDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "UserStatusDetailsTableViewCell")
        self.remainingUserCountOutlet.text = ""
    }
    
    override func layoutSubviews(){
        super.layoutSubviews()
        if !self.isLoadedFirst{
            self.isLoadedFirst = true
//            self.shadowView.layer.masksToBounds = false
//            self.shadowView.layer.shadowColor = UIColor.lightGray.cgColor
//            self.shadowView.layer.shadowPath = UIBezierPath(roundedRect: self.shadowView.bounds, cornerRadius: 5).cgPath
//            self.shadowView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
//            self.shadowView.layer.shadowOpacity = 0.5
//            self.shadowView.layer.shadowRadius = 1.0
            
            self.mainView.layer.borderWidth = 0.2
            self.mainView.layer.borderColor = UIColor.lightGray.cgColor
            self.mainView.layer.cornerRadius = 5
            self.mainView.layer.masksToBounds = true
            
        }
    }
    
    func setGroupChatStatusData(status: [MessageDeliveryStatus], isRead: Bool, remaining: Int){
        self.userListWithStatus = status
        self.isRead = isRead
        self.userListTableView.reloadData()
        if remaining > 0{
            self.remainingUserCountOutlet.text = "\(remaining) " + "remaining".localized
        }
        if isRead{
            let attribute = [convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : AppColourStr.tickColor]
            self.readStatusLabel.attributedText = NSAttributedString(string: "✔︎✔︎", attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
            self.readOrDeliverdStatusLabel.text = "Read by".localized
        }else{
            let attribute = [convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.black]
            self.readStatusLabel.attributedText = NSAttributedString(string: "✔︎✔︎", attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
            self.readOrDeliverdStatusLabel.text = "Delivered to".localized
        }
    }
    
}

extension GroupChatDeliveryStatusCVCell: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userListWithStatus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserStatusDetailsTableViewCell") as? UserStatusDetailsTableViewCell else{fatalError()}
        let data = self.userListWithStatus[indexPath.row]
        cell.setUserStatusDataInCell(msgStatus: data, isRead: self.isRead)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
