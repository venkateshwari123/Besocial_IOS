//
//  TextStoryViewController.swift
//  dub.ly
//
//  Created by Shivansh on 1/10/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class TextStoryViewController: UIViewController,UITextViewDelegate {

    @IBOutlet weak var labelForPlaceHolder: UILabel!
    
    @IBOutlet weak var backGroundViewForText: UIView!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    let storyAPIObj = StoryAPI()
    @IBOutlet weak var postBtnOutlet: UIButton!
    @IBOutlet weak var storyTextView: UITextView!
    
    let allAvailableFonts = ["Helvetica","Helvetica-Bold","Helvetica-BoldOblique","Helvetica-Light","Helvetica-LightOblique","Helvetica-Oblique"]
    
    let allAvailablebackGrounds = ["#0000ff",
    "#ff0074",
    "#0aeb7e",
    "#3c7c5c",
    "#bb4055",
    "#81c8c1",
    "#d69537"]
    
    var currentSelectedBackGround = "Helvetica"
    var currentSelectedFontName = "#0000ff"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.storyTextView.becomeFirstResponder()
        // Do any additional setup after loading the view.
        self.storyTextView.delegate = self
        labelForPlaceHolder.text = "Enter status".localized
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        // self.storyTextView.placeholder = "Enter status"
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        initialSetup()
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
    
    func initialSetup() {
        currentSelectedBackGround = allAvailablebackGrounds[0]
        currentSelectedFontName = allAvailableFonts[0]
        let currentFontSize = self.storyTextView.font?.pointSize
        self.storyTextView.font = UIFont(name:currentSelectedFontName, size: currentFontSize!)
        self.backGroundViewForText.backgroundColor = Helper.hexStringToUIColor(hex: currentSelectedBackGround)
        
    }
    
    func updateFont() {
        for i in allAvailableFonts.enumerated() {
            if(i.element == currentSelectedFontName) {
                if(i.offset == allAvailableFonts.count-1) {
                    //reached last font.
                    currentSelectedFontName = allAvailableFonts[0]
                } else {
                      currentSelectedFontName = allAvailableFonts[i.offset+1]
                }
                break
            }
        }
        
        let currentFontSize = self.storyTextView.font?.pointSize
        self.storyTextView.font = UIFont(name:currentSelectedFontName, size: currentFontSize!)
    }
    
    
    func postNewStory() {
        
        Helper.showPI(_message: "Adding to story".localized + " ... ")
        StoryHelper.uploadImageToCloudinary(image: self.backGroundViewForText.takeScreenshot(), view: self.view, message:"Uploading Image".localized + " ..", onCompletion:  { (isuploaded,storyDetails) in
            if(isuploaded) {
                let originalStoryDetails = ["type":3,"isPrivate":false,"backgroundColor":self.currentSelectedBackGround,"fontType":self.currentSelectedFontName,"statusMessage":self.storyTextView.text,"urlPath":storyDetails["urlPath"] as! String] as [String : Any]
                self.storyAPIObj.postNewStory(with:AppConstants.postStory , params:originalStoryDetails, complitation: { (response, error) in
                    print("responce")
                    print("error")
                    Helper.hidePI()
                    self.dismiss(animated: true, completion: nil)
                })
            }
        })
    }
    
    func updateBackGroundColor() {
        for i in allAvailablebackGrounds.enumerated() {
            if(i.element == currentSelectedBackGround) {
                if(i.offset == allAvailablebackGrounds.count-1) {
                    //reached last font.
                    currentSelectedBackGround = allAvailablebackGrounds[0]
                } else {
                    currentSelectedBackGround = allAvailablebackGrounds[i.offset+1]
                }
                break
            }
        }
        self.backGroundViewForText.backgroundColor = Helper.hexStringToUIColor(hex: currentSelectedBackGround)
    }
    
    @IBAction func createStoryAction(_ sender: Any) {
        postNewStory()
    }
    
    
    @IBAction func changeFontButtonAction(_ sender: Any) {
      updateFont()
    }
    
    
    
    @IBAction func changeColorButtonAction(_ sender: Any) {
        updateBackGroundColor()
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion:nil)
    }
    
    func textViewDidChange(_ textView: UITextView) {
//       updateTextViewFrame()
        self.adjustContentSize(tv: textView)
        if textView.text!.isEmptyOrWhitespace() {
            self.postBtnOutlet.isHidden = true
            self.labelForPlaceHolder.isHidden = false
        } else {
            self.postBtnOutlet.isHidden = false
            self.labelForPlaceHolder.isHidden = true
        }
    }
    
    func adjustContentSize(tv: UITextView){
        let deadSpace = tv.bounds.size.height - tv.contentSize.height
        let inset = max(0, deadSpace/2.0)
        tv.contentInset = UIEdgeInsets.init(top: inset, left: tv.contentInset.left, bottom: inset, right: tv.contentInset.right)
    }
    
    func updateTextViewFrame() {
        var newFrame = storyTextView.frame
        let width = newFrame.size.width
        let newSize = storyTextView.sizeThatFits(CGSize(width: width,
                                                        height: CGFloat.greatestFiniteMagnitude))
        newFrame.size = CGSize(width: width, height: newSize.height)

        if newFrame.size.height >= 40 {
            newFrame.size.height = self.storyTextView.contentSize.height
        } else {
            newFrame.size.height = 40
        }

        newFrame.origin.y = self.backGroundViewForText.frame.size.height/2 - newFrame.size.height
        
        if(newFrame.origin.y<0) {
            newFrame.origin.y = 100
        }
        
        if(newFrame.size.height >= self.backGroundViewForText.frame.size.height) {
            newFrame.size.height = self.backGroundViewForText.frame.size.height
        }
        storyTextView.frame = newFrame
    }
    
    @objc internal override func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            bottomConstraint.constant = keyboardSize.height
           // updateTextViewFrame()
        }
    }
    
    @objc internal func KeyboardDidShow(_ notification: Notification) {
       self.adjustContentSize(tv:self.storyTextView)
    }
    
    
    
    
    @objc internal override func keyboardWillHide(_ notification: Notification) {
        bottomConstraint.constant = 0
       // updateTextViewFrame()
    }
}

extension UIView {
    
    func renderViewToImage() -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 0)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
                
    }
    
    
    func takeScreenshot() -> UIImage {
        
        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        
        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if (image != nil)
        {
            return image!
        }
        return UIImage()
    }
}

extension String {
    func isEmptyOrWhitespace() -> Bool {
        
        if(self.isEmpty) {
            return true
        }
        
        return (self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "")
    }
}
