//
//  DeactivateConfirmationViewController.swift
//  Yelo
//
//  Created by Rahul Sharma on 13/03/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

protocol DeactivateConfirmationViewControllerDelegate {
    func confirm()
}

class DeactivateConfirmationViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var blueButton: UIButton!
    @IBOutlet weak var whiteButton: UIButton!
    
    var titleText = ""
    var descriptionText = ""
    var whiteButtonText = ""
    var blueButtonText = ""
    var delegate: DeactivateConfirmationViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        self.perform(#selector(animateBackground), with: nil, afterDelay: 0.5)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
    func setUp(){
        self.view.backgroundColor = .clear
        titleLabel.font = Theme.getInstance().postHeaderStyle18.getFont()
        
        if Utility.isDarkModeEnable(){
            titleLabel.textColor = .white
            descriptionLabel.textColor = .white
            whiteButton.layer.borderColor = UIColor.white.cgColor
            whiteButton.setTitleColor( .white, for: .normal)
            blueButton.backgroundColor = Theme.getInstance().deleteProfileCancelButttonStyle.getBackgroundColor()
            blueButton.setTitleColor( Theme.getInstance().deleteProfileCancelButttonStyle.getTextColor(), for: .normal)
        }else{
            titleLabel.textColor = Theme.getInstance().postHeaderStyle18.getTextColor()
            descriptionLabel.textColor = Theme.getInstance().report_Options.getTextColor()
            whiteButton.layer.borderColor = Colors.attributeBorderColor.cgColor
            whiteButton.setTitleColor( Colors.attributeBorderColor, for: .normal)
            blueButton.backgroundColor = Theme.getInstance().deleteProfileCancelButttonStyle.getBackgroundColor()
            blueButton.setTitleColor( Theme.getInstance().deleteProfileCancelButttonStyle.getTextColor(), for: .normal)
        }
        
        
        
        
        descriptionLabel.font = Theme.getInstance().report_Options.getFont()
        
        
        whiteButton.layer.borderWidth = 1
        
        whiteButton.titleLabel?.font = Theme.getInstance().deleteProfileDeleteButttonStyle.getFont()
        
        whiteButton.layer.cornerRadius = 5
        
        blueButton.titleLabel?.font = Theme.getInstance().deleteProfileCancelButttonStyle.getFont()
        
        
        blueButton.layer.cornerRadius = 5
        
        setTitleAndDescription()
    }
    
    func setTitleAndDescription() {
        titleLabel.text = titleText
        descriptionLabel.text = descriptionText
        blueButton.setTitle(blueButtonText, for: .normal)
        whiteButton.setTitle(whiteButtonText, for: .normal)
    }
    
    func setPageDetails(title: String, description: String, whiteButtonText: String, blueButtonText: String){
        self.titleText = title
        self.descriptionText = description
        self.whiteButtonText = whiteButtonText
        self.blueButtonText = blueButtonText
    }
    
    //MARK:- Button Action
    @IBAction func blueButtonAction(_ sender: UIButton){
        animateOutBackground(needToPushDeactivateVC : true)
    }
    
    @IBAction func whiteButtonAction(_ sender: UIButton){
        animateOutBackground()
    }
    
    @objc func animateBackground() {
        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        }
    }
    
    @objc func animateOutBackground(needToPushDeactivateVC:Bool = false) {
        
        UIView.animate(withDuration: 0.15, animations: {
            self.view.backgroundColor = .clear
        }) { (done) in
            if done{
                self.dismiss(animated: true) {
                    if needToPushDeactivateVC{
                        self.delegate?.confirm()
                        self.animateOutBackground()
                    }
                }
            }
        }
    }
}
