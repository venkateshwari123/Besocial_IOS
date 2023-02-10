//
//  CommentTableViewCell.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 12/10/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

protocol CommentTableViewCellDelegate {
    func userNameGetClicked(name: String)
    func hasgtagGetClicked(hasgTag: String)
    func forYouviewmoreTapped(isViewed: Bool,index : Int)
}
/*
 Bug Name :- Add viewmore/viewless for comments
 Fix Date :- 23/06/2021
 Fixed By :- Jayaram G
 Description Of Fix :- Added viewmore with Active label
 */
class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageButton: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
//    @IBOutlet weak var userCommentLabel: UILabel!
    @IBOutlet weak var verifiedImageView: UIImageView!
    @IBOutlet weak var userCommentLabel: ActiveLabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var delegate: CommentTableViewCellDelegate?
    var index:Int = 0
    /*
     Bug Name :- Read more , read less
     Fix Date :- 26/04/2021
     Fixed By :- Jayaram G
     Description Of Fix :- Added required variables
     */
    var fullText = ""
    var truncatedText = ""
    var truncatedLength = 60
    var isTruncated = true
    /*
     Feat Name:- Readmore/Readless
     Feat Date:- 23/05/21
     Feat by  :- jayaram G
     Discription of Feat:- Added custom type as readmore/readless
     */
    let readMoreType = ActiveType.custom(pattern: "..." + "Read More".localized + "|..." + "Read Less".localized)

    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.userImageView.makeCornerRadious(readious: self.userImageView.frame.size.width / 2)
        self.userCommentLabel.enabledTypes = [.hashtag,.mention,.url,readMoreType]

//        self.userCommentLabel.sizeToFit()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellData(modelData: FullCommentModel){

        /*
         Bug Name:- Show the intials for default profile pic
         Fix Date:- 17/05/21
         Fix By  :- Jayram G
         Description of Fix:- setting initials image when user not uploaded profile pic
         */
        let fullName = modelData.commentedByFirstName + " " + modelData.commentedByLastName
        Helper.addedUserImage(profilePic: modelData.profilePic, imageView: self.userImageView, fullName: fullName)
        let time = Helper.getTimeStamp(timeStamp: modelData.timeStamp)
        let timeArr = time.components(separatedBy: " ")
        var timeString = ""
        for item in timeArr{
            timeString.append(item.localized + " ")
        }
        self.timeLabel.text = timeString
        if modelData.comment?.count ?? 0 > 60 {
            self.userCommentLabel.numberOfLines = 0
        }else {
            self.userCommentLabel.numberOfLines = 2
        }
        self.handleUserNameAndHashTag(modelData: modelData)
    }

    
    func labelAction(modelData: FullCommentModel){
        if modelData.isExpand {
            modelData.isExpand = false
            delegate?.forYouviewmoreTapped(isViewed: false, index: self.index)
        }else{
            delegate?.forYouviewmoreTapped(isViewed: true, index: self.index)
            modelData.isExpand = true
        }
        
        let userName = NSAttributedString(string: "@" + (modelData.commentedBy ?? ""))
        let attrString = NSAttributedString(string: " ")
        if let comment = expandOrCollapse(modelData: modelData) {
            self.userCommentLabel.attributedText = userName + attrString + comment
        }
        //            self.delegate?.forYoureloadTableView(index: self.index)
        self.reloadInputViews()
    }
    
    private func handleUserNameAndHashTag(modelData: FullCommentModel){
        userCommentLabel.customize { label in
            /*
             Bug Name :- hash tag and user tag is to be made bold white
             Fix Date :- 29/04/2021
             Fixed By :- Jayaram G
             Description Of Fix :- Added configureLinkAttribute for label
             */
            label.configureLinkAttribute = { (type, attributes, isSelected) in
                var atts = attributes
                switch type {
                case .hashtag,.email,.url:
                    atts[NSAttributedString.Key.font] = Utility.Font.SemiBold.ofSize(14)
                    atts[NSAttributedString.Key.foregroundColor] = Utility.appColor() //UIColor.textBlackColor
                /*
                 Feat Name:- Readmore/Readless
                 Feat Date:- 23/05/21
                 Feat by  :- jayaram G
                 Discription of Feat:- added attributes for readmore/readless text
                 */
                case .mention:
                    atts[NSAttributedString.Key.font] = Utility.Font.SemiBold.ofSize(14)
                    if #available(iOS 13.0, *) {
                        atts[NSAttributedString.Key.foregroundColor] = UIColor.label
                    } else {
                        atts[NSAttributedString.Key.foregroundColor] = UIColor.black
                    }

                case .custom(pattern: "..." + "Read More".localized + "|..." + "Read Less".localized):
                    atts[NSAttributedString.Key.font] = Utility.Font.SemiBold.ofSize(14)
                    atts[NSAttributedString.Key.foregroundColor] = Utility.appColor()
                default: ()
                }
                return atts
            }
            
            self.truncatedText = getText(fullText: modelData.comment ?? "")
            label.attributedText = Helper.makeAttributedString(title: modelData.comment ?? "", font: Utility.Font.Regular.ofSize(14))
            label.attributedText = Helper.makeAttributedString(title: "@" + (modelData.commentedBy ?? ""), font: Utility.Font.SemiBold.ofSize(14))
        
            let attrString = NSAttributedString(string: " ")
            let userName = NSAttributedString(string: "@" + (modelData.commentedBy ?? ""))
            if let comment = self.expandOrCollapse(modelData: modelData) {
                label.attributedText = userName + attrString + comment
            }

            /*
             Feat Name:- Readmore/Readless
             Feat Date:- 23/05/21
             Feat by  :- jayaram G
             Discription of Feat:- added action
             */
            label.handleCustomTap(for: readMoreType) { (str) in
                self.labelAction(modelData: modelData)
            }
            label.handleMentionTap {
                if let delegate = self.delegate{
                    delegate.userNameGetClicked(name: "@" + $0)
                }
            }
            
            label.handleHashtagTap {
                if let delegate = self.delegate{
                    delegate.hasgtagGetClicked(hasgTag: "#" + $0)
                }
            }

            label.handleURLTap { url in
                Helper.openUrl(string: url)
            }
        }
    }
    
    /*
     Bug Name :- read more , read less
     Fix Date :- 26/04/2021
     Fixed By :- Jayaram G
     Description Of Fix :- To get dynamic text of the title
     */
    func expandOrCollapse(modelData: FullCommentModel) -> NSMutableAttributedString? {
    
        
        if self.fullText.count < truncatedLength{
            let myString:NSString = (modelData.comment)! as NSString
            var myMutableString = NSMutableAttributedString()
            myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSAttributedString.Key.font: Utility.Font.Regular.ofSize(14)])
            return myMutableString
        }else{
            if modelData.isExpand {
//                self.readMoreBtnOutlet.setTitle(" view less", for: .normal)
                let myString:NSString = (self.fullText + "..." + "Read Less".localized) as NSString
                var myMutableString = NSMutableAttributedString()
                myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSAttributedString.Key.font:Utility.Font.Regular.ofSize(14)])
                myMutableString.addAttribute(NSAttributedString.Key.strokeColor, value: UIColor.red, range: NSRange(location:myString.length-9,length:8))
                return myMutableString
                
            }
            else{
//                self.readMoreBtnOutlet.setTitle(" view more", for: .normal)
                let myString:NSString = (self.truncatedText + "..." + "Read More".localized) as NSString
                var myMutableString = NSMutableAttributedString()
                myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSAttributedString.Key.font:Utility.Font.Regular.ofSize(14)])
                myMutableString.addAttribute(NSAttributedString.Key.strokeColor, value: UIColor.red, range: NSRange(location:myString.length-9,length:8))
                return myMutableString
            }
        }
    }

    
    /*
     Bug Name :- read more , read less
     Fix Date :- 26/04/2021
     Fixed By :- Jayaram G
     Description Of Fix :- To get full title of the post
     */
    func getText(fullText: String) -> String{
        
        self.fullText = fullText
        
        if fullText.count < truncatedLength{
            return self.fullText
        }
        else{
            let index = fullText.index(fullText.startIndex, offsetBy: truncatedLength - 1)
            self.truncatedText = fullText[...index].description
            return self.truncatedText
        }
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
