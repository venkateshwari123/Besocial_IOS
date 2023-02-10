//
//  CoinWalletCell.swift
//  Do Chat
//
//  Created by 3Embed on 05/11/20.
//  Copyright © 2020 Rahul Sharma. All rights reserved.
//

import UIKit

class CoinWalletCell: UICollectionViewCell {
    
    @IBOutlet weak var coinImage: UIImageView!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    
    override func awakeFromNib(){
        super.awakeFromNib()
    }
}
