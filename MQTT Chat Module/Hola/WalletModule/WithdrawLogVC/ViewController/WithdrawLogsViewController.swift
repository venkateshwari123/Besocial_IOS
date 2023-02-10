//
//  WithdrawLogsViewController.swift
//  Yelo
//
//  Created by Rahul Sharma on 09/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

class WithdrawLogsViewController: BaseViewController {
    

    @IBOutlet weak var tableView: UITableView!
    
    let viewModel = WithdrawLogViewModel()

    //Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.getWithdrawLogs {
            self.tableView.reloadData()
        }
        setUp()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    func setUp(){
        self.navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: "Withdraw Logs".localized)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
    }
 
  
}
