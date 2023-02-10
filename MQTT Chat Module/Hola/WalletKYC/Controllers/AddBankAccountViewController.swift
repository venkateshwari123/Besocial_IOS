//
//  AddBankAccountViewController.swift
//  PicoAdda
//
//  Created by A.SENTHILMURUGAN on 1/3/1399 AP.
//  Copyright © 1399 Rahul Sharma. All rights reserved.
//

import UIKit

class AddBankAccountViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextBtn: UIButton!
  
    
    var activeTextField = UITextField()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nextBtn.layer.cornerRadius = 5
        self.navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: "Add Your Bank Account".localized)
        nextBtn.setTitle("Next".localized, for: .normal)
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
          NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: NSNotification.Name(rawValue: "keyboardWillShow"), object: nil)
          NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: NSNotification.Name("keyboardWillHide"), object: nil)
          
      }
    

    
    @objc func keyBoardWillHide(notification: NSNotification) {
              let contentInsets = UIEdgeInsets.zero
              tableView.contentInset = contentInsets
              tableView.scrollIndicatorInsets = contentInsets
          }
          
          @objc func keyBoardWillShow(notification: NSNotification) {
              
              if let userInfo = notification.userInfo {
                  if let keyBoardSize = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                      let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyBoardSize.height, right: 0)
                      tableView.contentInset = contentInset
                      tableView.scrollIndicatorInsets = contentInset
                      //Scroll upto visible rect
                      var visisbleRect = self.view.frame
                      visisbleRect.size.height -= keyBoardSize.height
                      if !visisbleRect.contains((activeTextField.center)) {
                          tableView.scrollRectToVisible(visisbleRect, animated: true)
                      }
                  }
              }
    
}
    
    func getDetailsCell(index: Int) -> AddBankAccountTableViewCell {
        
        guard let cell = tableView.cellForRow(at: IndexPath.init(row: index, section: 0)) as? AddBankAccountTableViewCell else {return AddBankAccountTableViewCell()}
        return cell
    }
    
    func validateDoc(ifscCode: String, accountNumber: String, accountHolderName: String, confirmAccountNumber: String) -> Bool{
          
          if ifscCode.count == 0 {
            Helper.showAlertViewOnWindow("", message: "enter".localized + " " + "ifsc code".localized)
              return true
          }else if accountNumber.count == 0 {
              Helper.showAlertViewOnWindow("", message: "enter".localized + " " + "Account Number".localized)
              return true
          }else if accountHolderName.count == 0 {
              Helper.showAlertViewOnWindow("", message: "enter".localized + " " + "Account Holder Name".localized)
              return true
          }else if confirmAccountNumber.count == 0 {
            Helper.showAlertViewOnWindow("", message: "confirm".localized + " " + "Account Number".localized)
            return true
          }else if confirmAccountNumber != accountNumber {
            Helper.showAlertViewOnWindow("", message: "check".localized + " " + "account number".localized)
            return true
          }
          else {
              return false
          }
      }

    
    
    @IBAction func nextAction(_ sender: UIButton) {
        if validateDoc(ifscCode: getDetailsCell(index: 0).topTextFieldOutlet.text!, accountNumber: getDetailsCell(index: 1).topTextFieldOutlet.text!, accountHolderName: getDetailsCell(index: 3).topTextFieldOutlet.text!, confirmAccountNumber: getDetailsCell(index: 2).topTextFieldOutlet.text!) {
            return
        }else {
        let storyBoard = UIStoryboard(name: AppConstants.StoryBoardIds.WalletKyc, bundle: nil)
                    guard let resultViewController = storyBoard.instantiateViewController(withIdentifier: "Completeidentification") as? CompleteIdentificationViewController else {return}
            resultViewController.ifscCode = getDetailsCell(index: 0).topTextFieldOutlet.text!
        resultViewController.accountNumber =  getDetailsCell(index: 1).topTextFieldOutlet.text!
        resultViewController.accountHolderName =  getDetailsCell(index: 3).topTextFieldOutlet.text!
              self.navigationController?.pushViewController(resultViewController, animated: true)
        }
    }
    
}


extension AddBankAccountViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "addBankAccountCell", for: indexPath) as? AddBankAccountTableViewCell else {return UITableViewCell()}
        cell.setDataInCell(indexPath.row)
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
