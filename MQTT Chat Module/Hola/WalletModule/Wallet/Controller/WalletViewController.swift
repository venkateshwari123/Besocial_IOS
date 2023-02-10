//
//  WalletViewController.swift
//  Yelo
//
//  Created by Rahul Sharma on 24/04/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

class WalletViewController: BaseViewController {
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var allTransactionQrCodeScanner: UIButton!
    
    let socialViewModel = SocialViewModel()
    let viewModel = WalletViewModel()
    var qrCode:String = ""
    
    /// pull down to refresh
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(handleRefresh),
                                 for: .valueChanged)
        refreshControl.tintColor = UIColor.lightGray
        return refreshControl
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        self.navigationItem.title = "Wallet".localized
        
        viewModel.getWalletDetails()
        viewModel.getTransaction { _ in
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
            
        }
        socialViewModel.getVerificationStatus { (success, error) in
            if success {
                print("verification status recieved")
            }else{
                print(error)
            }
        }
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
    
    
    func setup() {
        if allTransactionQrCodeScanner != nil {
            Helper.provideShadowForBtn(btn:allTransactionQrCodeScanner,rgbValue:0x3897F0,radius:allTransactionQrCodeScanner.bounds.width/2, width:0)
        }
        if tableview != nil {
            tableview.estimatedRowHeight = 50
            tableview.rowHeight = UITableView.automaticDimension
            tableview.addSubview(refreshControl)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        unHideNavBar()
        self.navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: "Wallet".localized)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    
    /*
     Bug Name:- Please add a QR code in the top right cornen like in the android application
     Fix Date:- 24/06/21
     Fix By  :- Jayaram G
     Description of Fix:- Added qrcode UI and navigation
     */
    func moveToQrCodeVc() {
        let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
        let qrCodeVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.qrCodeVc) as! QrCodeViewController
        qrCodeVc.qrCode = qrCode
        qrCodeVc.barcodeReaded(barcode: qrCode)
        qrCodeVc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(qrCodeVc, animated: true)
    }
    
    
    /// used for pull down to refresh
    @objc func handleRefresh(){
        /*
         Bug Name:- Data Changing after refreshing
         Fix Date:- 10/06/21
         Fix By  :- Jayaram G
         Description of Fix:-
         */
        viewModel.index = 0
        viewModel.pageState = ""
        viewModel.getWalletDetails()
        viewModel.getTransaction { _ in
            DispatchQueue.main.async {
                self.tableview.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.refreshControl.endRefreshing()
        }
    }
    
    /*
     Bug Name:- Please add a QR code in the top right cornen like in the android application
     Fix Date:- 24/06/21
     Fix By  :- Jayaram G
     Description of Fix:- Added qrcode UI and navigation
     */
    @IBAction func qrCodeVc(_ sender: Any) {
        moveToQrCodeVc()
    }
    @IBAction func moveToScanQrVc(_ sender: UIButton) {
        let qrScannerVc = ScannQrCodeViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.qrCode) as ScannQrCodeViewController
        qrScannerVc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(qrScannerVc, animated: false)
    }
    
}

extension WalletViewController: HeaderTVCellDelegate, WalletAlertVCDelegate{
    
    func transactionSelectionButtonAction() {
        showTransactionTypeSelectionVC()
    }
    
    func typeSelected(type: WalletViewModel.type) {
        viewModel.selectedType =  type
        viewModel.getTransaction { _ in
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
        }
    }
}

extension WalletViewController: BalanceTVCellDelegate{
    func withdrwaButtonPressed() {
         navigateToWithdrawOptionsVC()
    }
    
    func rechargeButtonPressed() {
        navigateToCardVC()
    }
}
