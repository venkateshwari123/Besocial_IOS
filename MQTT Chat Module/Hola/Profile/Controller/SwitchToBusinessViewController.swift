//
//  SwitchToBusinessViewController.swift
//  Starchat
//
//  Created by Rahul Sharma on 4/24/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
import TextFieldEffects

class SwitchToBusinessViewController: UIViewController {

    
    /// variables and Declarations
    var switchDelegate: SwitchToBusinessViewController?
    let switchToBusinessVmObject = SwitchToBusinessViewModel()

    
    /// Outlets
    @IBOutlet weak var businessTableView: UITableView!
  

    
    //MARK:- View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "back_arrow"), style: .plain, target: self, action: #selector(dismissSelf))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.black
        let image = #imageLiteral(resourceName: "defaultImage")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView
        
        
        // *** Listen to keyboard show / hide ***
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        // *** Hide keyboard when tapping outside ***
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        tapGesture.cancelsTouchesInView = true
        view.addGestureRecognizer(tapGesture)
        
        
        getBusinessProfileDetails()
    }
    
    
    @objc func dismissSelf(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.businessTableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 73, right: 0)
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
            if #available(iOS 11, *) {
                if keyboardHeight > 0 {
                    keyboardHeight = keyboardHeight - view.safeAreaInsets.bottom
                }
            }            
            let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
            UIView.animate(withDuration: duration!, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
                let frame = self.view.frame
                let height = UIScreen.main.bounds.height - keyboardHeight
                self.view.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: height)
            }, completion: nil)
            view.layoutIfNeeded()
        }
    }
    @objc func tapGestureHandler() {
        view.endEditing(true)
    }

    
    func getBusinessProfileDetails(){
        let url = AppConstants.bussinessProfile
        self.switchToBusinessVmObject.getBusinessDeatails(strUrl: url) { (finished, error) in
            if finished {
                self.businessTableView.reloadData()
                print("got Business Details")
            }
        }
    }
}

extension SwitchToBusinessViewController:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
        let titleCell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.SwitchToBusinessTitleCellId, for: indexPath) as! SwitchToBusinessTitleCell
        return titleCell
        }else if indexPath.row == 1 || indexPath.row == 6{
            let headerCell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.SwitchToBusinessHeaderViewCellId, for: indexPath) as! SwitchToBusinessHeaderViewCell
            if indexPath.row == 6 {
                headerCell.headerViewCellTitleLabel.text = Strings.contactInfo.localized
            }else {
                headerCell.headerViewCellTitleLabel.text = Strings.businessDetails.localized

            }
            return headerCell
        }else if indexPath.row == 9 {
            let descriptionCell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.SwitchToBusinessDescriptionCellId, for: indexPath) as! SwitchToBusinessDescriptionCell
            return descriptionCell
        }        else {
            let textCell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.SwitchToBusinessTextViewCellId, for: indexPath) as! SwitchToBusinessTextViewCell
            if self.switchToBusinessVmObject.switchToBusinessViewModelArray.count > 0{
                self.setDataInCell(textCell: textCell, index: indexPath)
            }
            
            return textCell
        }
    }
    
    /// To set cell data accprding to its index
    ///
    /// - Parameters:
    ///   - textCell: cell reference
    ///   - index: index of cell
    func setDataInCell(textCell: SwitchToBusinessTextViewCell, index: IndexPath){
        switch index.row{
        case 2:
            print(self.switchToBusinessVmObject.switchToBusinessViewModelArray.count)
            textCell.textField.tag = 1
            textCell.setTextCellData(text: self.switchToBusinessVmObject.switchToBusinessViewModelArray[0].businessName ?? "", placeHolder: Strings.businessName.localized)
        case 3:
            textCell.textField.tag = 2
            textCell.setTextCellData(text: self.switchToBusinessVmObject.switchToBusinessViewModelArray[0].businessAddress ?? "", placeHolder: Strings.address.localized)
        case 4:
            textCell.textField.tag = 3
            textCell.setTextCellData(text: "", placeHolder: Strings.webSiteUrl.localized)
        case 5:
            textCell.textField.tag = 4
            textCell.setTextCellData(text: "", placeHolder: Strings.aboutBusiness.localized )
        case 7:
            textCell.textField.tag = 5
            if let businessEmail = self.switchToBusinessVmObject.switchToBusinessViewModelArray[0].businessEmail{
               if let email = businessEmail[Strings.id] as? String {
                   textCell.setTextCellData(text: email, placeHolder: Strings.email.localized)
               }else {
                   textCell.setTextCellData(text: "", placeHolder: Strings.email.localized)
                }
             }
        default :
            textCell.textField.tag = 6
            if let businessNumber = self.switchToBusinessVmObject.switchToBusinessViewModelArray[0].businessPhone{
                if let phoneNumber = businessNumber[Strings.number] as? String {
                    textCell.setTextCellData(text: phoneNumber, placeHolder: Strings.phoneNumber.localized)
                }else {
                    textCell.setTextCellData(text: "", placeHolder: Strings.phoneNumber.localized)
                }
            }
        self.view.layoutIfNeeded()
    }
}
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 || indexPath.row == 6{
            return 50
        }else if indexPath.row == 0 {
            return 140
        }else if indexPath.row == 9{
            return 120
        } else {
            return 80
        }
    }
}
extension SwitchToBusinessViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        var index = IndexPath()
        var index1 = IndexPath()
        switch textField.tag {
        case 1:
            index = IndexPath(row: textField.tag + 2, section: 0)
            break
        case 2:
            index = IndexPath(row: textField.tag + 2, section: 0)
            break
        case 3:
            index = IndexPath(row: textField.tag + 2, section: 0)
            break
        case 4:
            index = IndexPath(row: textField.tag + 2, section: 0)
             self.view.endEditing(true)
            break
//        case 5:
//            index = IndexPath(row: textField.tag + 2, section: 0)
//            break
        default:
            
            index = IndexPath(row: 7, section: 0)
            index1 = IndexPath(row: 8, section: 0)
            guard let cell1 = self.businessTableView.cellForRow(at: index1) as? SwitchToBusinessTextViewCell else{return true}
            cell1.textField.resignFirstResponder()
            guard let cell = self.businessTableView.cellForRow(at: index) as? SwitchToBusinessTextViewCell else{return true}
            cell.textField.resignFirstResponder()
            return true
        }
        guard let cell = self.businessTableView.cellForRow(at: index) as? SwitchToBusinessTextViewCell else{return true}
        cell.textField.becomeFirstResponder()
        return true
    }
}

