//
//  CoinsTipCollectionViewCell.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 16/12/20.
//  Copyright © 2020 Rahul Sharma. All rights reserved.
//

import UIKit
class CoinsTipCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var lblAmount: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bgView.makeCornerRadious(readious: 5)
        self.bgView.makeShadowEffect(color: .lightGray)
        self.lblAmount.font = Utility.Font.SemiBold.ofSize(14)
    }
}
