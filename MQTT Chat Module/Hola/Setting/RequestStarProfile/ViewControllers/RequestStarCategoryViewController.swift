//
//  RequestStarCategoryViewController.swift
//  Starchat
//
//  Created by Rahul Sharma on 5/6/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
// Author:- Jayaram G

import UIKit

/// requestStarProfileDelegate for passing the data
protocol requestStarProfileDelegate{
    func gettingStarCategoryNameAndId(categoryName:String,categoryId:String)
}
class RequestStarCategoryViewController: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var categoryListTableView: UITableView!
    
    //MARK:- Declarations&Constants
    let requestStarCategoryVmObject = RequestStarCategoryViewModel() // Used for RequestStarCategoryViewModel Object Reference
    let requestStarProfileVmObject = RequestStarProfileViewModel() // Used for RequestStarProfileViewModel Object Reference
    var starProfiledelegate: requestStarProfileDelegate?  // Used for  requestStarProfileDelegate Reference
    
    var selectedIndexPath:Int!                    // used To check the selected index in tableView
    var starCategoryName:String?                  // Used To Store starCategory Name
    var starCategoryId:String?                    // Used To Store StarCategoryId
    
    
    //MARK:- View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        uiDesign()
        categoryListTableView.tableFooterView = UIView()
        self.getCategoryList()
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
    
    //MARK:- UiDesign
    func uiDesign(){
        //. navTopView.makeBorderColorAndBorderWidth(UIColor.darkGray.cgColor, borderWidth: 0.4)
        navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: Strings.NavigationTitles.verifyProfile.localized)
        self.categoryListTableView.tableFooterView = UIView()
    }
    
    /// Get RequestStar Category List - GET Api
    func getCategoryList(){
        Helper.showPI()
        requestStarCategoryVmObject.requestCategoryApiCall{ (success, error) in
            if success{
                
                self.categoryListTableView.reloadData()
            }else if let error = error{
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
            }
            Helper.hidePI()
        }
    }
    

}

//MARK:-- Extensions
extension RequestStarCategoryViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requestStarCategoryVmObject.requestStarCategoryModelArray.count ?? 0
    }
    
    // unselecte_category_icon
    //Group 2268
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let categoryRow = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.selectedCategoryRowIndex) as? Int
        
        
        let categoryCell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.requestCategoryTypesCellId, for: indexPath) as! RequestCategoryTypesCell
      
        
        let data = self.requestStarCategoryVmObject.requestStarCategoryModelArray[indexPath.row]
        categoryCell.categoryData(allCategoryList: data)
        return categoryCell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath.row
        categoryListTableView.reloadData()
        let categoryRow = indexPath.row
        UserDefaults.standard.set(categoryRow, forKey: AppConstants.UserDefaults.selectedCategoryRowIndex)
        starCategoryName = requestStarCategoryVmObject.requestStarCategoryModelArray[selectedIndexPath].categorie!
        starCategoryId = requestStarCategoryVmObject.requestStarCategoryModelArray[selectedIndexPath].userId!
        
        guard let starCatName = requestStarCategoryVmObject.requestStarCategoryModelArray[selectedIndexPath].categorie else {return}
        guard let starCatId = requestStarCategoryVmObject.requestStarCategoryModelArray[selectedIndexPath].userId else { return }
        starProfiledelegate?.gettingStarCategoryNameAndId(categoryName: starCatName, categoryId: starCatId)
        self.navigationController?.popViewController(animated: true)
        
       
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
