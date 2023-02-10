//
//  RequestStarProfileChooseFileViewCell.swift
//  Starchat
//
//  Created by Rahul Sharma on 5/2/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G
import UIKit

/// RequestStarProfileChooseFileViewCellDelegate  to manage Button Actions in cell
protocol RequestStarProfileChooseFileViewCellDelegate: class{
    func RequestingApiCall()
    func movingToTermsAndCondtions()
    func choosingFile()
    func checkingTermsAndCondtions()
}
class RequestStarProfileChooseFileViewCell: UITableViewCell {

        
    //MARK:- Outlets
    @IBOutlet weak var requestBtn: UIButton!
    @IBOutlet weak var choosenImage: UIImageView!
    @IBOutlet weak var selectedImageHeightConstraintOutlet: NSLayoutConstraint!

    @IBOutlet weak var chooseFileBtn: UIButton!
    @IBOutlet weak var termsLbl: UILabel!
    @IBOutlet weak var discriptionLbl: UILabel!
    @IBOutlet weak var attachPhotoIDLbl: UILabel!
    
    @IBOutlet weak var termsAndConditionsBtn: UIButton!

    
    //MARK:- variables&Declarations
    var delegate1: RequestStarProfileChooseFileViewCellDelegate?  // Used To get the referance of the RequestStarProfileChooseFileViewCellDelegate Protocol
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//
        let mainAttrText = NSAttributedString(string: "I agree to the".localized + " " + "\(AppConstants.AppName) ")
        let andAttrText = NSAttributedString(string: " " + "for a verify user".localized + ".")
        let termsServiceText = "Star terms and conditions".localized
        
        self.requestBtn.setTitle("Request".localized, for: .normal)
        self.attachPhotoIDLbl.text = "Please attach your photo of ID".localized
        self.discriptionLbl.text = "We require a government-issued photo ID that shows your name and date of birth (e.g driver's lilcense,passport or national identification card) of official business documents (tax filling ,recent utility bill, article of incorporation) in order to review your request.".localized
        self.chooseFileBtn.setTitle("Choose file".localized, for: .normal)
      
        let ppAttributedText = NSAttributedString(string: termsServiceText, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor(red: 55 / 255.0, green: 152 / 255.0, blue: 219 / 255.0, alpha: 1.0), convertFromNSAttributedStringKey(NSAttributedString.Key.underlineStyle) : NSUnderlineStyle.single.rawValue]))
        
        termsLbl.attributedText = mainAttrText  +  ppAttributedText + andAttrText
        
        selectedImageHeightConstraintOutlet.constant = 0
        uiDesign()
    }
    
    //MARK:- UIDesign
    func uiDesign(){
        requestBtn.makeImageCornerRadius(20)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    
    /// Requesting For Star Profile Action
    ///
    /// - Parameter sender: request Button
    @IBAction func requestStarProfileAction(_ sender: UIButton) {
        delegate1?.RequestingApiCall()
    }
    
    
    @IBAction func chooseFileAction(_ sender: UIButton) {
        delegate1?.choosingFile()
    }
    
    
    @IBAction func termsAndCondtionsWebViewAction(_ sender: UIButton) {
              delegate1?.movingToTermsAndCondtions()
    }
    
    @IBAction func termsAndCondtionsAction(_ sender: Any) {
        termsAndConditionsBtn.isSelected = !termsAndConditionsBtn.isSelected
        delegate1?.checkingTermsAndCondtions()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
