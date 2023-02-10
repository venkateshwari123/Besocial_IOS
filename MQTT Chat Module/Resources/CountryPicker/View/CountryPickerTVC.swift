//
//  CountryPickerTVC.swift
//  Shoppd
//
//  Created by Rahul Sharma on 01/10/19.
//  Copyright © 2019 Nabeel Gulzar. All rights reserved.
//

import UIKit

enum countryPickerFrom{
    case countryPicker
    case sort
    case cancelProduct
}

class CountryPickerTVC: UITableViewCell {
    @IBOutlet weak var countryName: UILabel!
    @IBOutlet weak var checkMarkImageView: UIImageView!
    var fromVC:countryPickerFrom?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        initialSetUp()
    }
    
    func initialSetUp(){
        Fonts.setFont(countryName, fontFamiy: .primary(.Regular), size: fromVC == .sort ? .standard(.h14) : .custom(15), color: UIColor.setColor(lightMode: "#040404", darkMode: AppColourStr.whiteColor))
        checkMarkImageView.image = UIImage(named: "radio_empty")?.withTintColor(.systemBackground)
    }

    func updateCell(celldata:CountryPicker){
        countryName.text = celldata.countryName
    }
    
    func updateSortCell(cellData:String){
        countryName.text = cellData
    }
    
    func updateCancelProductCell(cellData:String){
        countryName.text = cellData
    }
}
