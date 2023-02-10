//
//  CoinWalletViewController.swift
//  Do Chat
//
//  Created by 3Embed on 05/11/20.
//  Copyright © 2020 Rahul Sharma. All rights reserved.
//

import UIKit
import StoreKit
import Locksmith
import Alamofire
class CoinWalletViewController: UIViewController {
    
    @IBOutlet weak var coinCollection: UICollectionView!
    var coinModel = CoinWalletModel()
    var coinWalletViewModelObj = CoinWalletViewModel()
    @IBOutlet weak var lblCoin: UILabel!
    @IBOutlet weak var lblMyBalance: UILabel!
    @IBOutlet weak var selectPlan: UILabel!
    @IBOutlet weak var headerHoldingView: UIView!
    @IBOutlet weak var transactionButton: UIButton!

    
    var products = [SKProduct]()
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: "Buy Coins".localized)
        self.selectPlan.font = Utility.Font.Bold.ofSize(16.0)
        self.tabBarController?.tabBar.isHidden = true
        getCoinsPlansApi()
        setUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Utility.isDarkModeEnable(){
            UIApplication.shared.statusBarStyle = .lightContent
        }else{
            UIApplication.shared.statusBarStyle = .darkContent
        }
        
        ApiHelper.shared.getWallet(userId: Utility.getUserid() ?? "") { _ in
            self.lblCoin.text =  KeychainHelper.sharedInstance.getCoinWalletBalance()
        }
    }
    
    func setUI(){
        if !Utility.isDarkModeEnable(){
            self.headerHoldingView.layer.borderColor = #colorLiteral(red: 0.8941176471, green: 0.8941176471, blue: 0.968627451, alpha: 1)
        }
        self.headerHoldingView.layer.borderWidth = 1
        self.transactionButton.layer.borderColor = Utility.appColor().cgColor
        self.transactionButton.layer.borderWidth = 1
        self.lblMyBalance.text = "My Balance".localized
        self.selectPlan.text = "Select Plan".localized
        self.transactionButton.setTitle("Transactions".localized, for: .normal)
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
    @IBAction func onTap(_ sender: Any) {
        Route.navigateToCoinTransaction(navigationController:self.navigationController)
    }
    
    func getCoinsPlansApi(){
        let url = AppConstants.coinPlans
        /*
         Refactor Name:- loader should be "Loading coin plans"
         Refactor Date:- 07/04/21
         Refactor By  :- Nikunj C
         Description of refactor:- show header with message
         */
        Helper.showPI(_message: "Loading".localized + " " + "coin plans".localized)
        self.coinWalletViewModelObj.getCoinPlans(strUrl: url) { (plans, error, canServiceCall) in

            IAPManager.shared.getPlansFromApple(productIds: self.coinWalletViewModelObj.coinPlanModelArray.map({$0.appstoreId ?? ""}), handler: { (result,success) in
                Helper.hidePI()
                if success {
                    self.products = result
                }
                else{
                    if self.products.count == 0 {
                        self.setTableViewOrCollectionViewBackground(tableView: nil, collectionView: self.coinCollection, image: #imageLiteral(resourceName: "Group 40556"), labelText: "No Plans Yet".localized + " !", labelWithImage: true, yPosition: 150)
                    }
                }
                self.coinCollection.reloadData()
            })
            
        }
    }
    
    func setTableViewOrCollectionViewBackground(tableView: UITableView? , collectionView: UICollectionView?,image : UIImage?,labelText: String?,labelWithImage:Bool , yPosition: CGFloat){
        
        let backgroundView = UIView()
        backgroundView.frame = self.view.bounds
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 25))
        
        if let image = image{
            imageView.image = image
            imageView.center.y = yPosition
            imageView.center.x = self.view.center.x
            imageView.contentMode = .scaleAspectFill
            backgroundView.addSubview(imageView)
        }
        
        if let labelText = labelText{
            label.text = labelText
            label.textAlignment = .center
            label.font = Theme.getInstance().noLabelStyle.getFont()
            
            if labelWithImage{
                label.center.y = imageView.frame.maxY + 30
                imageView.center.x = self.view.center.x
                backgroundView.addSubview(label)
            }else{
                imageView.center.y = self.view.center.y
                imageView.center.x = self.view.center.x
                backgroundView.addSubview(label)
            }
        }
        
        if let tableView = tableView{
            tableView.backgroundView = backgroundView
        }
        
        if let collectionView = collectionView{
            collectionView.backgroundView = backgroundView
        }
    }
    
    func Buycoins(with strURL: String, complitation: @escaping(_ success: Bool?)-> Void){
        var planId = ""
        var currency = ""
        var amount = 0.0
        let data = IAPManager.getPurchasedPlan()
        if let productId = data["productId"] as? String {
            let planData = self.coinWalletViewModelObj.coinPlanModelArray.filter({$0.appstoreId == productId})
            planId = planData.first?.planid ?? ""
            currency = planData.first?.currency ?? "INR"
            amount = planData.first?.planCost ?? 0.0
             
        }
        
        /*
         Bug Name:- Updated buy coin api
         Fix Date:- 17/05/21
         Fix By  :- Jayaram G
         Description of Fix:- Changed buycoin api to purchaseCoin api and added required parameters
         */
        
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lan": Utility.getSelectedLanguegeCode()]
        let param = ["userId":Utility.getUserid() ?? "",
                     "userType": "user",
                     "planId":planId,
                     "pgTxnId":data["transactionId"] ?? "",
                     "pgName":"APPSTORE",
                     "notes":"Special Offer",
                     "description":"Buy Coin Plan",
                     "trigger":"wallet trigger like buy coin",
                     "currency":currency,
                     "amount":amount]
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .post, parameters: param ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.coinWallet.rawValue)
        apiCall.subject_response.subscribe(onNext: {dict in
            print("output here \(dict)")
            complitation(true)
        }, onError: {error in
            complitation(false)
        })
    }

    
}
extension CoinWalletViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.view.frame.width/3)-15, height: 150)
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//
//        guard let streamId = Utility.getStreamId() else{return}
//        self.postTheChat(message: EmojiData.data[indexPath.row], streamID: streamId)
//        collectionView.deselectItem(at: indexPath, animated: true)
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CoinWalletCell", for: indexPath) as! CoinWalletCell
        let product = self.products[indexPath.row]
        
        
        if let plan = self.coinWalletViewModelObj.coinPlanModelArray.filter({$0.appstoreId == product.productIdentifier}).first{
//            cell.lblPrice.text = "\(plan.currencySymbol ?? "")\(plan.planCost ?? 0)"
            cell.lblPrice.text = IAPManager.shared.getPriceFormatted(for: product)
            cell.lblAmount.text = plan.planTitle ?? ""
            cell.coinImage.setImageOn(imageUrl: plan.imgUrl, defaultImage: UIImage(named: "coin")!)
        }
        else{
            cell.lblPrice.text = IAPManager.shared.getPriceFormatted(for: product)
            cell.lblAmount.text = product.localizedTitle
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Helper.showPI()
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
//            Helper.hidePI()
//        }
        IAPManager.shared.buy(product: self.products[indexPath.row], withHandler: { (result) in
            Helper.hidePI()
            switch result {
            case .success:
                DispatchQueue.main.async {
                    /*
                     Bug Name:- Updated buy coin api
                     Fix Date:- 17/05/21
                     Fix By  :- Jayaram G
                     Description of Fix:- Changed buycoin api to purchaseCoin api
                     */
                self.Buycoins(with: AppConstants.purchaseCoins, complitation: { success in
                    ApiHelper.shared.getWallet(userId: Utility.getUserid() ?? "") { _ in
                        self.lblCoin.text =  KeychainHelper.sharedInstance.getCoinWalletBalance()
                    }
                })
                }
                break
            case .failure(let error):
                print("failed\(error)")
            }
        })
    }
}



