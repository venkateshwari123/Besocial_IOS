
//
//  BusinessButtonTextViewController.swift
//  Starchat
//
//  Created by Rahul Sharma on 06/09/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
class BusinessButtonTextViewController: UIViewController {
    
    @IBOutlet weak var businessButtonTextTableViewOutlet: UITableView!
    
    var selectedIndex:Int?
    var businessButton = BusinessButtonModel(modelData: [:])
    var businessButtonListVmObject = BusinessButtonsListViewModel()
    var canServiceCall: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        businessButtonTextTableViewOutlet.tableFooterView = UIView()
        uiDesign()
        businessButtonListApiCall()
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
    
    func uiDesign(){
        self.navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: Strings.NavigationTitles.buttonText.localized)
        let doneBtn = UIBarButtonItem.init(title: Strings.save.localized, style: .done, target: self, action: #selector(saveAction))
        doneBtn.tintColor = .label
        self.navigationItem.rightBarButtonItem = doneBtn
     }
    
    @objc func saveAction(){
        if checkBusinessButtonSelectedOrNot(){
            if let createPostVC = self.navigationController?.viewControllers.filter({$0.isKind(of: CreatePostViewController.self)}).first as? CreatePostViewController{
                createPostVC.businessButtonText = self.businessButton.buttonText
                createPostVC.businessButtonColor = self.businessButton.buttonColor
                self.navigationController?.popToViewController(createPostVC, animated: true)
            }
        }
    }
    
    func checkBusinessButtonSelectedOrNot() -> Bool{
        if self.businessButton.buttonText != ""{
            return true
        }else {
            let alert = UIAlertController(title: nil, message: Strings.businessSelectionAlert.localized, preferredStyle: .alert)
            let okAction = UIAlertAction(title: Strings.ok.localized, style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return false
        }
    }
    
    
    func businessButtonListApiCall () {
        let urlStr = AppConstants.bizButtons
        self.businessButtonListVmObject.getBusinessButtonList(strUrl: urlStr) { (success, error) in
            if success{
                self.businessButtonTextTableViewOutlet.reloadData()
            }else{
                print(error?.localizedDescription)
            }
        }
    }
    
}


extension BusinessButtonTextViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.businessButtonListVmObject.busiessButtonListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let businessBtnTextCell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.businessButtonTextCellId, for: indexPath) as? BusinessButtonTextCell else {fatalError()}
        let modelData = self.businessButtonListVmObject.busiessButtonListArray[indexPath.row]
        businessBtnTextCell.businessTextBtnLbl.text = modelData.buttonText
        if businessButton.buttonText ==  modelData.buttonText {
            businessBtnTextCell.indicationImage.image = #imageLiteral(resourceName: "select_category_icon")
        }else {
            businessBtnTextCell.indicationImage.image = #imageLiteral(resourceName: "unselecte_category_icon")
        }
        return businessBtnTextCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        let modelData = self.businessButtonListVmObject.busiessButtonListArray[indexPath.row]
        businessButton = modelData
        self.businessButtonTextTableViewOutlet.reloadData()
        
    }
    
}
