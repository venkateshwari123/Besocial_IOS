//
//  CoinTransactionView.swift
//  Do Chat
//
//  Created by 3Embed on 05/11/20.
//  Copyright © 2020 Rahul Sharma. All rights reserved.
//

import UIKit
import Locksmith
import Alamofire

class CoinTransactionView: UIViewController {
    let currency = ""
    let totalTabs = 3
    @IBOutlet weak var viewMove: UIView!
    var coinModel = [CoinWalletModel]()
    var transactions = [CoinWalletModel]()
    @IBOutlet weak var btnAll: UIButton!
    @IBOutlet weak var btnCoinAll: UIButton!
    @IBOutlet weak var btnCoinOut: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noPostViewOutlet: UIView!
    @IBOutlet weak var noTransaction: UILabel!
    
    var pageState:String?
    var canServiceCall = false
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.isHidden = true
        self.navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: "Coin Transactions".localized)
        self.btnAll.titleLabel?.font = UIFont(name: "Poppins-Bold", size: 17)
        self.btnCoinAll.titleLabel?.font = UIFont(name: "Poppins-Medium", size: 17)
        self.btnCoinOut.titleLabel?.font = UIFont(name: "Poppins-Medium", size: 17)
        self.btnAll.setTitle("All".localized, for: .normal)
        self.btnCoinAll.setTitle("Credit".localized, for: .normal)
        self.btnCoinOut.setTitle("Debit".localized, for: .normal)
        self.btnAll.setTitle("All".localized, for: .selected)
        self.btnCoinAll.setTitle("Credit".localized, for: .selected)
        self.btnCoinOut.setTitle("Debit".localized, for: .selected)
        self.noTransaction.text = "No transactions yet".localized + "!"
        self.navigationItem.title = "Coin".localized + " " + "Transactions".localized
        self.transServiceCall()
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView()
        
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
    
    func transServiceCall(){
        print("pageState\(self.pageState)")
        var url = ""
        if self.pageState != nil {
            url = "walletTransaction?walletId=\(KeychainHelper.sharedInstance.getCoinWalletId())&txnType=0&pageState=\(pageState ?? "")&fetchSize=20"
        }else{
            url = "walletTransaction?walletId=\(KeychainHelper.sharedInstance.getCoinWalletId())&txnType=0&fetchSize=20"
        }
        self.getWalletTransactionData(with: url, complitation: { (res,error,pageState) in
            if let result = res as? [[String:Any]]{
                if pageState != nil {
                    self.canServiceCall = true
                }else{
                    self.canServiceCall = false
                }
                for resObj in result{
                    let allTransactionData = CoinWalletModel(modelData: resObj)
                    self.coinModel.append(allTransactionData)
                    self.transactions.append(allTransactionData)
                }
                if self.coinModel.count > 0 {
                    self.tableView.isHidden = false
                    self.tableView.reloadData()
                }else{
                    self.tableView.isHidden = true
                    self.noPostViewOutlet.isHidden = false
                    self.tableView.reloadData()
                }
            }else if let error = error{
                if error.code == 204 {
                    if self.coinModel.count == 0 {
                        self.tableView.isHidden = true
                        self.noPostViewOutlet.isHidden = false
                        self.tableView.reloadData()
                    }
                    self.canServiceCall = false
                }
                print(error.localizedDescription)
            }
        })
    }
    
    func getWalletTransactionData(with strURL: String, complitation: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?,_ pageState: String?)-> Void){
           guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
           guard  let token = keyDict["token"] as? String  else {return}
           
           let headers = ["authorization":token,"lan": Utility.getSelectedLanguegeCode()]
           
           let apiCall = RxAlmofireClass()
           apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .get, parameters: nil ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.coinWallet.rawValue)
           apiCall.subject_response.subscribe(onNext: {dict in
               print("output here \(dict)")
             
               guard let dataArray = dict["data"] else {return}
            if let pageState = dict["pageState"] as? String {
                self.pageState = pageState
                complitation(dataArray,nil,pageState)
            }else{
                complitation(dataArray,nil,nil)
            }
            
           }, onError: {error in
               complitation(nil,error as? CustomErrorStruct,nil)
           })
       }
    
    @IBAction func onMenuTap(_ sender: UIButton) {
        btnAll.isSelected = false
        btnCoinAll.isSelected = false
        btnCoinOut.isSelected = false
        self.setList(type: sender.tag)
        sender.isSelected = true
        UIView.animate(withDuration: 0.2) {
            self.viewMove.frame = CGRect(x: (self.view.frame.size.width/CGFloat(self.totalTabs))*(CGFloat(sender.tag)), y: self.viewMove.frame.origin.y, width: self.viewMove.frame.width, height: self.viewMove.frame.height)
        }
    }
    func setList(type : Int){
        if type != 0 {
            coinModel = transactions.filter({$0.txntype == type})
        }else{
            coinModel = transactions
        }
        
        if coinModel.count == 0 {
            self.noPostViewOutlet.isHidden = false
        }else{
            self.noPostViewOutlet.isHidden = true
        }
        
        /*
         Refactor Name:- make font less bold on sub tabs
         Refactor Date:- 21/04/21
         Refactor   By:- Nikunj C
         Description of Refactor:- selected tab bold
         */
        
        if type == 0 {
            self.btnAll.titleLabel?.font = UIFont(name: "Poppins-Bold", size: 17)
            self.btnCoinAll.titleLabel?.font = UIFont(name: "Poppins-Medium", size: 17)
            self.btnCoinOut.titleLabel?.font = UIFont(name: "Poppins-Medium", size: 17)
        } else if type == 1{
            self.btnCoinAll.titleLabel?.font = UIFont(name: "Poppins-Bold", size: 17)
            self.btnAll.titleLabel?.font = UIFont(name: "Poppins-Medium", size: 17)
            self.btnCoinOut.titleLabel?.font = UIFont(name: "Poppins-Medium", size: 17)
        } else {
            self.btnCoinOut.titleLabel?.font = UIFont(name: "Poppins-Bold", size: 17)
            self.btnAll.titleLabel?.font = UIFont(name: "Poppins-Medium", size: 17)
            self.btnCoinAll.titleLabel?.font = UIFont(name: "Poppins-Medium", size: 17)
        }
        self.tableView.reloadData()
    }
}
extension CoinTransactionView:UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coinModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoinTransacationCell", for: indexPath) as! CoinTransacationCell
        if coinModel.count > indexPath.row {
            let item = coinModel[indexPath.row]
            cell.setCellData(model: item)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if coinModel.count > indexPath.row {
            let item = coinModel[indexPath.row]
            print("postId _________\(item.postId)")
            if let postId = item.postId as? String , postId != "" {
                if AppConstants.appType == .picoadda {
                    Route.navigateToInstaDetailsVc(navigationController: self.navigationController, postsArray: nil, needToCallApi: true, postId: postId)
                }else{
                    Route.navigateToAllPostsVertically(navigationController: self.navigationController,postId: postId, postsArray: nil,isCommingFromChat:true,isFromProfilePage:true)
                }
            }
        }
    }
 
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){
    if coinModel.count > indexPath.row {
    let indexPassed: Bool = indexPath.row >= self.coinModel.count - 10
    if self.canServiceCall && indexPassed{
        canServiceCall = false
        self.transServiceCall()
    }
}
    }
}
extension CoinTransactionView:UITableViewDelegate{
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return tableView.
//    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.performSegue(withIdentifier: "webViewVC", sender: nil)
//    }
}
