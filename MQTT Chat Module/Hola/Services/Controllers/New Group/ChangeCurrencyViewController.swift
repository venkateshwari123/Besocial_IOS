//
//  ChangeCurrencyViewController.swift
//  Starchat
//
//  Created by Rahul Sharma on 4/17/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
class ChangeCurrencyViewController: UIViewController {
    
    //MArk:- All Outlets
    @IBOutlet weak var sampleTableView: UITableView!
    
    //MARK:- Variables&Declarations
    var selectedIndexPath:Int?
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: Strings.NavigationTitles.chooseCurrency.localized)
    }
}

//MARK:- Extensions

// MARK: - UITableView Delegate & DataSources
extension ChangeCurrencyViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.changeCurrencyCellId, for: indexPath) as! ChangeCurrencyCell
        if selectedIndexPath == indexPath.row{
            cell.selectionImage.isHidden = false
        }else{
            cell.selectionImage.isHidden = true
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath.row
        self.sampleTableView.reloadData()
    }
}
