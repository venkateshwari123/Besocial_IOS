//
//  UpdateStatusViewController.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 16/10/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//
import UIKit
protocol UpdateStatusViewControllerDelegate: class{
    func updatedStatus(status: String)
    func removeStatus()
}
class UpdateStatusViewController: UIViewController {

    
    /// Outlets
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var tickButtonOutlet: UIButton!
    @IBOutlet weak var statusTextField: UITextField!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var statuslable: UILabel!
    @IBOutlet weak var growingTextView: NextGrowingTextView!
    
    
    /// variables and Declarations
    var userProfileData: UserProfileModel?
    var delegate: UpdateStatusViewControllerDelegate?
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.growingTextView.textView.text = userProfileData?.status
        self.statuslable.isHidden = true
        self.bottomView.backgroundColor = Utility.appColor()
        
        self.growingTextView.layer.cornerRadius = 4
        self.growingTextView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        let font = Utility.Font.Regular.ofSize(18)
        self.growingTextView.textView.font = font
        let fontAttribute = [ convertFromNSAttributedStringKey(NSAttributedString.Key.font): font, convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.gray ]

        self.growingTextView.placeholderAttributedText = NSAttributedString(
            string: "Enter Status",
            attributes: convertToOptionalNSAttributedStringKeyDictionary(fontAttribute)
        )
        self.growingTextView.backgroundColor = UIColor.white
        self.growingTextView.maxNumberOfLines = 6
        self.growingTextView.textView.delegate = self
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.growingTextView.textView.becomeFirstResponder()
        if !Utility.isDarkModeEnable(){
            self.navView.makeShadowEffect(color: UIColor.lightGray)
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        if delegate != nil{
            delegate?.updatedStatus(status: self.growingTextView.textView.text!)
        }
        self.dismiss(animated: true, completion: nil)
    }

}

extension UpdateStatusViewController: UITextViewDelegate{
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let textViewtext = textView.text else {return true}
        if text != "" && textViewtext.count >= 500{
            return false
        }
        if text == "\n"{
            self.growingTextView.textView.resignFirstResponder()
            return false
        }
        if textViewtext.count == 1 && text == ""{
            self.statuslable.isHidden = false
            self.statuslable.text = "Status can't be empty".localized
            self.bottomView.backgroundColor = UIColor.red
            self.tickButtonOutlet.isEnabled = false
        }else if textViewtext.count < 3 || (textViewtext.count == 4 && text == "") || (textViewtext.count == 3 && text == ""){
            self.statuslable.isHidden = false
            self.statuslable.text = "Status must have atleast 4 charecters".localized
            self.bottomView.backgroundColor = UIColor.red
            self.tickButtonOutlet.isEnabled = false
        }else{
            self.statuslable.isHidden = true
            self.bottomView.backgroundColor = Utility.appColor()
            self.tickButtonOutlet.isEnabled = true
        }
        return true
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
