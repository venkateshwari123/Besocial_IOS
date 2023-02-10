//
//  CurrencyViewController.swift
//  Starchat
//
//  Created by Rahul Sharma on 06/09/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
protocol CurrencyViewControllerDelegate {
    func updateData(currency: String, currencySymbol: String)
}
class CurrencyViewController: UIViewController {

    var currencyViewModelObj =  currencyViewModel()
    var canServiceCall: Bool = false
    var delegateObj: CurrencyViewControllerDelegate?
    @IBOutlet weak var currencyListTableViewOutlet: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        uiDesign()
         getCurrencyListApiCall()
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
    
    func uiDesign(){
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: Strings.NavigationTitles.currency.localized)
         self.currencyListTableViewOutlet.tableFooterView = UIView()
    }
     
    
     func getCurrencyListApiCall(){
         let url = AppConstants.currency
        currencyViewModelObj.getCurrencyList(strUrl: url) { (success, error, canServiceCall) in
            if success{
                self.currencyListTableViewOutlet.reloadData()
            }else if let error = error{
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
            }
            self.canServiceCall = canServiceCall
        }
    }
 
}


extension CurrencyViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currencyViewModelObj.currencyListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let currencyListCell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.currencyListCellTableViewCellId, for: indexPath) as? CurrencyListCellTableViewCell else {fatalError()}
        currencyListCell.currencyNameLabel.text = self.currencyViewModelObj.currencyListArray[indexPath.row].currencyName
        currencyListCell.currencySymbol.text = self.currencyViewModelObj.currencyListArray[indexPath.row].currencySymbol
        return currencyListCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let AddPriceVC = self.navigationController?.viewControllers.filter({$0.isKind(of: AddPriceViewController.self)}).first as? AddPriceViewController{
            AddPriceVC.currency = "\(self.currencyViewModelObj.currencyListArray[indexPath.row].currencyName ?? "")"
            AddPriceVC.currencySymbol = self.currencyViewModelObj.currencyListArray[indexPath.row].currencySymbol
            
            self.navigationController?.popToViewController(AddPriceVC, animated: true)
        }
        /*
         Bug Name:- Add dynamic currency selection
         Fix Date:- 02/06/2021
         Fixed By:- Jayaram G
         Discription of Fix:- updating data after selecting currency
         */
        self.delegateObj?.updateData(currency: "\(self.currencyViewModelObj.currencyListArray[indexPath.row].currencyName ?? Utility.getWalletCurreny())", currencySymbol: self.currencyViewModelObj.currencyListArray[indexPath.row].currencySymbol ?? Utility.getWalletCurrenySymbol())
    }
}
