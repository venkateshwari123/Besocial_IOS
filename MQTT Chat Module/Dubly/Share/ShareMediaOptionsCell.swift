//
//  ShareMediaOptionsCell.swift
//  Do Chat
//
//  Created by Rahul Sharma on 24/08/20.
//  Copyright © 2020 Rahul Sharma. All rights reserved.
//

import UIKit

class ShareMediaOptionsCell: UICollectionViewCell {
    
    @IBOutlet weak var optionName: UILabel!
    @IBOutlet weak var optionImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    var bookmarkStatus = "Bookmark".localized
    override func awakeFromNib(){
        super.awakeFromNib()
    }


    func setView(value:String){
    switch MediaOptions.init(rawValue: value) {
    case .Duet:
        optionImageView.image = UIImage.init(named: "home_duet")
        optionName.text = "Duet".localized
        containerView.backgroundColor = #colorLiteral(red: 0.3647058824, green: 0.8549019608, blue: 1, alpha: 0.2)
        containerView.layer.borderColor = Helper.getUIColor(color: "#5DDAFF").cgColor
    case .Bookmark:
        optionImageView.image = UIImage.init(named: "home_bookmark")
             optionName.text = bookmarkStatus
        containerView.backgroundColor =  #colorLiteral(red: 0.5529411765, green: 0.968627451, blue: 0.7607843137, alpha: 0.2)
        containerView.layer.borderColor = Helper.getUIColor(color: "#8DF7C2").cgColor
    break
    case .Forward:
        optionImageView.image = UIImage.init(named: "home_forward")
        optionName.text = "Share".localized
              containerView.backgroundColor =  #colorLiteral(red: 0.6352941176, green: 0.4549019608, blue: 0.9725490196, alpha: 0.2)
              containerView.layer.borderColor = Helper.getUIColor(color: "#A274F8").cgColor
    case .Download:
        optionImageView.image = UIImage.init(named: "home_download")
        optionName.text = "Download".localized
         containerView.backgroundColor = #colorLiteral(red: 0.6901960784, green: 0.9098039216, blue: 0.2745098039, alpha: 0.2)
        containerView.layer.borderColor = Helper.getUIColor(color: "#B0E846").cgColor
    break
    case .Gif:
        optionImageView.image = UIImage.init(named: "home_gif")
        optionName.text = "Gif".localized
         containerView.backgroundColor = #colorLiteral(red: 1, green: 0.6901960784, blue: 0, alpha: 0.2)
        containerView.layer.borderColor = Helper.getUIColor(color: "#FFB000").cgColor
    break
    case .CopyLink:
        optionImageView.image = UIImage.init(named: "home_copy")
        optionName.text = "Copy Link".localized
         containerView.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.4980392157, blue: 0.6078431373, alpha: 0.2)
        containerView.layer.borderColor = Helper.getUIColor(color: "#F87F9B").cgColor
    break
    case .Record:
        optionImageView.image = UIImage.init(named: "home_dot")
        optionName.text = "Record".localized
         containerView.backgroundColor = #colorLiteral(red: 0.5529411765, green: 0.968627451, blue: 0.7607843137, alpha: 0.2)
        containerView.layer.borderColor = Helper.getUIColor(color: "#8DF7C2").cgColor
    break
    /* Feature Name : Share Profile
     Feature Date : 7-Apr-2021
     Feature Added By : jayaram G
     Description Of Feature : added anither option for share profile
     */
    case .SharePost :
        optionImageView.tintColor = .black
        optionImageView.image = UIImage.init(named: "share")
        optionName.text = "Share Post".localized
         containerView.backgroundColor = #colorLiteral(red: 0.9098039216, green: 0.5176470588, blue: 0.9411764706, alpha: 0.2)
        containerView.layer.borderColor = Helper.getUIColor(color: "#E884F0").cgColor
    case .ShareProfile :
        optionImageView.tintColor = .black
        optionImageView.image = UIImage.init(named: "Group 51503")
        optionName.text = "Share Profile".localized
         containerView.backgroundColor = #colorLiteral(red: 0.9098039216, green: 0.5176470588, blue: 0.9411764706, alpha: 0.2)
        containerView.layer.borderColor = Helper.getUIColor(color: "#E884F0").cgColor
    break
    /*
     Bug Name:- Add Delete post , edit post and report in this screen
     Fix Date:- 20/04/2021
     Fixed By:- Jayaram G
     Description of Fix:- Added delete post , edit post and report UI
     */
    case .DeletePost:
        optionImageView.tintColor = .black
        optionImageView.image = UIImage.init(named: "delete")
        optionName.text = "Delete Post".localized
         containerView.backgroundColor = #colorLiteral(red: 0.9098039216, green: 0.5176470588, blue: 0.9411764706, alpha: 0.2)
        containerView.layer.borderColor = Helper.getUIColor(color: "#E884F0").cgColor
        break
    case .EditPost:
        optionImageView.tintColor = .black
        optionImageView.image = UIImage.init(named: "edit_post")
        optionName.text = "Edit Post".localized
         containerView.backgroundColor = #colorLiteral(red: 0.9098039216, green: 0.5176470588, blue: 0.9411764706, alpha: 0.2)
        containerView.layer.borderColor = Helper.getUIColor(color: "#E884F0").cgColor
        break
    case .Report:
        optionImageView.tintColor = .black
        optionImageView.image = UIImage.init(named: "newspaper")
        optionName.text = "Report".localized
         containerView.backgroundColor = #colorLiteral(red: 0.9098039216, green: 0.5176470588, blue: 0.9411764706, alpha: 0.2)
        containerView.layer.borderColor = Helper.getUIColor(color: "#E884F0").cgColor
        break
    case .More :
           optionImageView.image = UIImage.init(named: "home_more")
        optionName.text = "More".localized
            containerView.backgroundColor = #colorLiteral(red: 0.9098039216, green: 0.5176470588, blue: 0.9411764706, alpha: 0.2)
           containerView.layer.borderColor = Helper.getUIColor(color: "#E884F0").cgColor
       break
    case .none:
        break
        }
    
 }
}
