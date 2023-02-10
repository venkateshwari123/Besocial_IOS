//
//  EditSubjectTableViewController.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 20/02/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import Locksmith
import Alamofire

protocol editSubjectdelegate {
    
    func nameChanged(groupName:String?)
}

class EditSubjectTableViewController: UITableViewController {
    
    var gpName:String?
    var delegate:editSubjectdelegate?
    var groupID:String?

    @IBOutlet weak var count: UIView!
    @IBOutlet weak var cancelBtnOutlet: UIBarButtonItem!
    @IBOutlet weak var saveBtnOutlet: UIBarButtonItem!
    @IBOutlet weak var countLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countLbl.text = String(describing: (gpName?.count)!)
        self.navigationItem.title = "Subject".localized
        self.cancelBtnOutlet.title = "Cancel".localized
        self.saveBtnOutlet.title = "Save".localized
    }
    
    /*
     Bug Name:- network handling
     Fix Date:- 20/04/21
     Fix By  :- Nikunj C
     Description of Fix:- check connectivity and show popup for no internet
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Helper.checkConnectionAvaibility(view: self.view)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "editSubjectCell", for: indexPath) as! EditSubjectTableViewCell
        
        cell.editSubjecttext.text = gpName
        cell.editSubjecttext.becomeFirstResponder()
        cell.editSubjecttext.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        cell.editSubjecttext.tag = 90
        
        return cell
    }
    
    @IBAction func cancelCliked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveCliked(_ sender: Any) {
     
        if gpName?.count == 0 {
            let alert = UIAlertController.init(title: "Oops".localized, message: "Enter Group Name".localized, preferredStyle: .alert)
            let alerAction = UIAlertAction.init(title: "OK".localized, style: .default, handler: nil)
            alert.addAction(alerAction)
            self.present(alert, animated: true, completion: nil)
        }
        
        self.changeGroupNameAPI()
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        countLbl.text = String(describing: (textField.text?.count)!)
        gpName = textField.text
        if (textField.text?.count)! > 24 {
            textField.deleteBackward()
        }
        
    }
    
    
    
    func changeGroupNameAPI(){
        
        Helper.showPI(_message: "Loading".localized + "...")
        let strURL = AppConstants.creatgroupChat
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":/*AppConstants.authorization, "token":*/token,"lang": Utility.getSelectedLanguegeCode()]
        let params  = ["chatId":self.groupID!] as [String:Any]
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .put, parameters:params,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.changeGPpicAPI.rawValue)
        apiCall.subject_response
            .subscribe(onNext: {dict in
                Helper.hidePI()
                guard let responseKey = dict[AppConstants.resposeTypeKey] as? String else {return}
                if responseKey == AppConstants.resposeType.changeGPpicAPI.rawValue {
                    self.delegate?.nameChanged(groupName: self.gpName)
                    self.dismiss(animated: true, completion: nil)
                }
            }, onError: {error in
                Helper.hidePI()
            })
        
    }
    
}
