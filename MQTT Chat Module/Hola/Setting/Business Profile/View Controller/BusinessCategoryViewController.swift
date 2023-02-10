//
//  BusinessCategoryViewController.swift
//  Starchat
//
//  Created by Rahul Sharma on 5/24/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G

import UIKit

/// BusinessProfileDelegate , TO pass the Data Business Category Name and business CategoryId
protocol BusinessProfileDelegate{
    func gettingBusinessCategoryNameAndId(businessCategoryName:String,businessCategoryId:String)
}
class BusinessCategoryViewController: UIViewController {
    
    //MARK:- Constants and Declarations
    struct Constants {
        static let businessCategoryListCellId = "BusinessCategoryListCellId"
    }
    var selectedIndexPath:Int!
    var businessCategoryName:String?
    var businessCategoryId:String?
    var businessProfileDelegate: BusinessProfileDelegate?
    var businessCategoryVmObject = BusinessCategoryViewModel()
    var updateEmailPhoneVMObject = UpdateEmailPhoneViewModel()
    var categoryRow:Int?
    var categoryName = ""
    var indexChanged:Bool = false
    var isFromCreate:Bool = false
    
    //MARK:- Outlets
    @IBOutlet weak var businessCategoryTableView: UITableView!
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        uiDesign()
        let saveBtn = UIBarButtonItem.init(title: "Save", style: .plain, target: self, action: #selector(dismissAndSave(_:)))
        saveBtn.tintColor = .label
        self.navigationItem.rightBarButtonItem = saveBtn
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.getAllBusinessCategoryList()
        self.businessCategoryTableView.tableFooterView = UIView()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
            /*
             Bug Name:- toast not appear sometime
             Fix Date:- 16/04/21
             Fix By  :- Nikunj C
             Description of Fix:- refactor extra code
             */
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
    /*
     Bug name:- category not updated
     Fix Date:- 12/06/21
     Fixed By:- Nikunj C
     Description of Fix:- call update profile api
     */
    @objc func dismissAndSave(_ sender: Any) {
        /*
         Bug name:- unable to select business category while creating
         Fix Date:- 25/08/21
         Fixed By:- Jayaram G
         Description of Fix:- not updating category while creating business
         */
        if isFromCreate {
            guard let businessCatName = businessCategoryName else {return}
            guard let businessCatId = businessCategoryId else { return }
            self.businessProfileDelegate?.gettingBusinessCategoryNameAndId(businessCategoryName: businessCatName, businessCategoryId: businessCatId)
            self.navigationController?.popViewController(animated: true)
        }else{
            guard let businessCatName = businessCategoryName else {return}
            guard let businessCatId = businessCategoryId else { return }
            let params = [Strings.businessCategoryId:businessCatId,Strings.businessUniqueId:Utility.getBusinessUniqueId()]
            self.updateEmailPhoneVMObject.updateProfile(params: params) { (dict) in
                self.businessProfileDelegate?.gettingBusinessCategoryNameAndId(businessCategoryName: businessCatName, businessCategoryId: businessCatId)
                self.navigationController?.popViewController(animated: true)
            }
        }
        }
    
    //MARK:- UIDesign
    func uiDesign(){
        
        navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: "Select Category".localized)
    }
    
    //MARK:- Button Actions
    // Select Categoy Action
    @IBAction func selectCategoryBtnAction(_ sender: UIButton) {
       
    }
    
    /// Get Business Category list
    func getAllBusinessCategoryList(){
        Helper.showPI()
        businessCategoryVmObject.businessCategoryApiCall{ (success, error) in
            if success{
                print(success)
                
                self.businessCategoryTableView.reloadData()
            }else if let error = error{
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
            }
            Helper.hidePI()
        }
    }
}

//MARK:- Extensions

// Table View extensions

// MARK: - UITableViewDelegate,UITableViewDataSource
extension BusinessCategoryViewController: UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.businessCategoryVmObject.businessCategoryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let categoryCell = tableView.dequeueReusableCell(withIdentifier: Constants.businessCategoryListCellId, for: indexPath) as! BusinessCategoryListCell
//        let categoryRow = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.selectedBusinessCategoryRowIndex) as? Int
//
//        if selectedIndexPath == indexPath.row{
//            categoryCell.selectIndicationImage.image = UIImage(named: "Group 2268")
//        }else{
//            categoryCell.selectIndicationImage.image = UIImage(named: "unselecte_category_icon")
//        }
//
      //  categoryCell.selectIndicationImage.image = UIImage(named: "unselecte_category_icon")
        
        if self.indexChanged {
            if businessCategoryVmObject.businessCategoryArray[indexPath.row].businessCategorieType == self.businessCategoryName {
                categoryCell.seletionImage.isHidden = false
            }else {
                 categoryCell.seletionImage.isHidden = true
            }
        }else{
            if businessCategoryVmObject.businessCategoryArray[indexPath.row].businessCategorieType == self.businessCategoryName {
                selectedIndexPath = indexPath.row
                categoryCell.seletionImage.isHidden = false
            }else {
                 categoryCell.seletionImage.isHidden = true
            }
        }
     
        let categoryData = self.businessCategoryVmObject.businessCategoryArray[indexPath.row]
        categoryCell.businessCategoryData(allCategoryList: categoryData)
        return categoryCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedIndexPath != indexPath.row {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.indexChanged = true
            selectedIndexPath = indexPath.row
            businessCategoryName = businessCategoryVmObject.businessCategoryArray[selectedIndexPath].businessCategorieType
            businessCategoryId = businessCategoryVmObject.businessCategoryArray[selectedIndexPath].businessCategoryId
            self.businessCategoryTableView.reloadData()
            
        }
        
        
        
        
    }
}
