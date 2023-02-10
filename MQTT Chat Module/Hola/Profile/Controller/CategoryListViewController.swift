
//
//  CategoryListViewController.swift
//  dub.ly
//
//  Created by 3Embed Software Tech Pvt Ltd on 14/12/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

protocol CategoryListViewControllerDelegate: class {
    func selectedCategory(categoryListModel: CategoryListModel)
}

class CategoryListViewController: UIViewController {
    
    /// All Outlets
    @IBOutlet weak var categoryListTableView: UITableView!
    @IBOutlet weak var selectCategoryBtn: UIButton!
    
    /// Variables and Declarations
    let categoryListViewMode = CategoryListViewModel()
    var canServiceCall: Bool = false
    var isForPosting = false
    var delegate: CategoryListViewControllerDelegate?
    var selectedCategoryListModel: CategoryListModel?
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        selectCategoryBtn.setTitle("Select".localized, for: .normal)
        self.navigationItem.title = "Select Category".localized
        self.getCategoryServiceCall()
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
    
    //MARK:- Button Action
    @IBAction func selectCategoryButtonAction(_ sender: Any) {
        if self.delegate != nil, let modelData = self.selectedCategoryListModel{
            self.delegate?.selectedCategory(categoryListModel: modelData)
        }
        if isForPosting {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    @IBAction func backButtonAction(_ sender: Any) {
        if isForPosting {
            
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK:- Service call
    func getCategoryServiceCall(){
        let url = AppConstants.category
        self.categoryListViewMode.getCategorys(strUrl: url) { (success, error, canServiceCall) in
            if success{
                self.categoryListTableView.reloadData()
            }else if let error = error{
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
            }
            self.canServiceCall = canServiceCall
        }
    }
    
}

//MARK:- Table view datasource and delegate
extension CategoryListViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categoryListViewMode.categoryListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.CategoryListTableViewCell) as? CategoryListTableViewCell else {fatalError()}
        let data = self.categoryListViewMode.categoryListArray[indexPath.row]
        var isSelected = false
        if let selectedData = self.selectedCategoryListModel{
            isSelected = data.categoryId == selectedData.categoryId ? true : false
        }
        cell.setDataInCategoryListCell(modelData: data, isSelected: isSelected)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedCategoryListModel = self.categoryListViewMode.categoryListArray[indexPath.item]
        self.categoryListTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let indexPassed: Bool = indexPath.item >= self.categoryListViewMode.categoryListArray.count - 15
        if canServiceCall && indexPassed{
            canServiceCall = false
            getCategoryServiceCall()
        }
    }
}
