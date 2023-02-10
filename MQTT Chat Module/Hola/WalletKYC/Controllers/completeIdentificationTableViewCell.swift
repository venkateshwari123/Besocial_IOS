//
//  completeIdentificationTableViewCell.swift
//  PicoAdda
//
//  Created by A.SENTHILMURUGAN on 1/7/1399 AP.
//  Copyright © 1399 Rahul Sharma. All rights reserved.
//

import UIKit

protocol WalletActivatedViewControllerDelegate {
    func selectImage(tag : Int)
   
    func didDeleteImage(tag: Int)
    
}

class completeIdentificationTableViewCell: UITableViewCell {
   

    @IBOutlet weak var backUploadBtn: UIButton!
    @IBOutlet weak var frontUploadBtn: UIButton!
    @IBOutlet weak var backCancelBtn: UIButton!
    @IBOutlet weak var frontCancelBtn: UIButton!
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var frontImageView: UIImageView!
    @IBOutlet weak var uploadDocLbl: UILabel!
    @IBOutlet weak var frontSideLbl: UILabel!
    @IBOutlet weak var backSideLbl: UILabel!

    
    
    var delegate: WalletActivatedViewControllerDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backCancelBtn.layer.cornerRadius = 10
        frontCancelBtn.layer.cornerRadius = 10
        backCancelBtn.isHidden = true
        frontCancelBtn.isHidden = true
        frontImageView.layer.borderWidth = 0.5
        frontImageView.layer.borderColor = #colorLiteral(red: 6.857585686e-05, green: 0.001718480955, blue: 0.05173677951, alpha: 1)
        backImageView.layer.borderWidth = 0.5
        backImageView.layer.borderColor = #colorLiteral(red: 6.857585686e-05, green: 0.001718480955, blue: 0.05173677951, alpha: 1)
        frontImageView.layer.cornerRadius = 5
        backImageView.layer.cornerRadius = 5
        frontUploadBtn.tag = 1
        backUploadBtn.tag = 2
        frontImageView.image = #imageLiteral(resourceName: "noun_Image_2536623")
        backImageView.image = #imageLiteral(resourceName: "noun_Image_2536623")
        uploadDocLbl.text = "Upload Doc".localized + "*"
        frontSideLbl.text = "Front Side".localized + "*"
        backSideLbl.text = "Back Side".localized + "*"
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func UploadButtonPressed(_ sender: UIButton) {
        if sender == frontUploadBtn {
            delegate?.selectImage(tag : sender.tag)
            frontCancelBtn.isHidden = false
        } else if sender == backUploadBtn {
             delegate?.selectImage(tag : sender.tag)
            backCancelBtn.isHidden = false
        }
    }
    
    
    @IBAction func imageDeleteButtonPressed(_ sender: UIButton) {
        if sender == frontCancelBtn {
            frontImageView.image = #imageLiteral(resourceName: "noun_Image_2536623")
            frontCancelBtn.isHidden = true
            delegate?.didDeleteImage(tag: 1)
        } else {
       
            backImageView.image = #imageLiteral(resourceName: "noun_Image_2536623")
            backCancelBtn.isHidden = true
            delegate?.didDeleteImage(tag: 2)
        }
    }
    
    
}
