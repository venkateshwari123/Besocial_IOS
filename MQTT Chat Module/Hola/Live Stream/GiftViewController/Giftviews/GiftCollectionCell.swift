//
//  GiftCollectionCell.swift
//  Live
//
//  Created by Vengababu Maparthi on 07/02/19.
//  Copyright © 2019 io.ltebean. All rights reserved.
//

import UIKit
import Kingfisher

class GiftCollectionCell: UICollectionViewCell {
    @IBOutlet weak var giftImage: UIImageView!
    @IBOutlet weak var giftName: UILabel!
    @IBOutlet weak var coins: UILabel!
    
    
    var data:GiftsModel!{
        didSet{
            let fullStringForCoins = NSMutableAttributedString(string:"\(Int(data.giftCost ?? 0)) ")
            let image1AttachmentForCoins = NSTextAttachment()
            image1AttachmentForCoins.image = UIImage(named: "dollar")?.resizeImageUsingVImage(size: CGSize(width: 10, height: 10))
            let image1StringForSubscribe = NSAttributedString(attachment: image1AttachmentForCoins)
            fullStringForCoins.append(image1StringForSubscribe)
            
            giftName.text = data.giftTitle
            coins.attributedText = fullStringForCoins
            if var gifUrl = data.gifIcon as? String{
//                gifUrl = gifUrl.replace(target: "upload/", withString: "upload/fl_lossy,q_-800/")
                self.giftImage.setImageOn(imageUrl: gifUrl , defaultImage: #imageLiteral(resourceName: "defaultImage"))
            }
        }
    }
}
