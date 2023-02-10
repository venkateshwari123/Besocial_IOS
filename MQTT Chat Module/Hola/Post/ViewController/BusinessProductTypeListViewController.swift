//
//  BusinessProductTypeListViewController.swift
//  Starchat
//
//  Created by Rahul Sharma on 09/09/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class BusinessProductTypeListViewController: UIViewController {

    
    @IBOutlet weak var businessProductTypeTableViewOutlet: UITableView!
    
    
    let businessProductTypeVmObject = BusinessProductTypeViewModel()
    var canServiceCall: Bool = false
    var selectedIndex:Int?
    var post:String = ""
    var postTypeId:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        productTypeListApiCall()
      uiDesign()
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
        businessProductTypeTableViewOutlet.tableFooterView = UIView()
        self.navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: Strings.productType.localized)
        let saveBtn = UIBarButtonItem.init(title: Strings.save.localized, style: .done, target: self, action: #selector(SaveAction))
        saveBtn.tintColor = .label
        self.navigationItem.rightBarButtonItem = saveBtn
     }
    

    func productTypeListApiCall(){
        let urlStr = AppConstants.businessProductType
        businessProductTypeVmObject.getProductTypeList(strUrl: urlStr) { (success, error, canServiceCall) in
            if success{
                self.businessProductTypeTableViewOutlet.reloadData()
               
            }else if let error = error{
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
            }
            self.canServiceCall = canServiceCall
        }
    }
 
    @objc func SaveAction() {
        if let createPostVc = (self.navigationController?.viewControllers.filter({$0.isKind(of: CreatePostViewController.self)}).first as? CreatePostViewController){
            createPostVc.postType = self.post
            createPostVc.postTypeId = self.postTypeId
            self.navigationController?.popToViewController(createPostVc, animated: true)
        }
    }
}


extension BusinessProductTypeListViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.businessProductTypeVmObject.productTypeListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let prodcutListTypeCell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.businessProductTypeListCellId, for: indexPath) as? BusinessProductTypeListCell else {fatalError()}
        prodcutListTypeCell.productTypeLabel.text = self.businessProductTypeVmObject.productTypeListArray[indexPath.row].produtTypeName
          if self.businessProductTypeVmObject.productTypeListArray[indexPath.row].produtTypeName == self.post {
            prodcutListTypeCell.indicationImageView.image = #imageLiteral(resourceName: "select_category_icon")
        }else {
            prodcutListTypeCell.indicationImageView.image = #imageLiteral(resourceName: "unselecte_category_icon")
        }
        return prodcutListTypeCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         selectedIndex = indexPath.row
         self.post = self.businessProductTypeVmObject.productTypeListArray[indexPath.row].produtTypeName ?? ""
        self.postTypeId = self.businessProductTypeVmObject.productTypeListArray[indexPath.row].productTypeId ?? ""
        self.businessProductTypeTableViewOutlet.reloadData()
      }
    
    
    
}
