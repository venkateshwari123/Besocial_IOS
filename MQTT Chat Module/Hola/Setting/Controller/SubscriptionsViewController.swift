//
//  SubscriptionsViewController.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 12/12/20.
//  Copyright © 2020 Rahul Sharma. All rights reserved.
//

import UIKit

class SubscriptionsViewController: UIViewController{
    
    //MARK: Declarations
    //    var tag:Int!
    var subscriptionsViewModelObject = SubscriptionsViewModel()
    var canServiceCall: Bool = false
    var profileViewModel = ProfileViewModel()
    var selectedCancelIndex = 0
    var selectedRenewIndex = 0
    //MARK:- Outlets
    @IBOutlet weak var allBottomView: UIView!
    @IBOutlet weak var activeBtnOutlet: UIButton!
    @IBOutlet weak var activeSubscriptionsTableView: UITableView!
    @IBOutlet weak var allBottomViewLeadingOutlet: NSLayoutConstraint!
    @IBOutlet weak var scrollViewOutlet: UIScrollView!
    @IBOutlet weak var cancelSubscriptionsTableView: UITableView!
    
    @IBOutlet weak var cancelBtnOutlet: UIButton!
    //MARK:-VIew Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        uiDesign()
        self.activeSubscriptionsTableView.tableFooterView = UIView()
        self.cancelSubscriptionsTableView.tableFooterView = UIView()
        if let totalBalance  = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.walletBalance) as? String{
           let walletData = Double(totalBalance)
           let WalletDataStr = String(format: "%.2f", walletData!)
        }
            
        getActiveSubscriptions()
        getCanceledSubscriptions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.layer.zPosition = 0;
        self.navigationController?.navigationBar.isHidden = false
    }
    //MASK:- UIDesign
    func uiDesign(){
        
        /* Bug Name :- unbold cancel button in setting ->  my subscription
         Fix Date :- 23/03/2021
         Fixed By :- Nikunj C
         Description Of fix :- now only selected option is bold and other button regular */
        activeBtnOutlet.setTitle("Active".localized, for: .normal)
        cancelBtnOutlet.setTitle("Cancelled".localized, for: .normal)
        activeBtnOutlet.titleLabel?.font = Utility.Font.Bold.ofSize(18)
        cancelBtnOutlet.titleLabel?.font = Utility.Font.Regular.ofSize(18)
        navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: "My Subscriptions".localized)
    }
    
    //MARK:- Button Actions
    
    @IBAction func AllTransactionsAction(_ sender: UIButton) {
        allBottomView.isHidden = false
        
        /* Bug Name :- unbold cancel button in setting ->  my subscription
         Fix Date :- 23/03/2021
         Fixed By :- Nikunj C
         Description Of fix :- when button select it become bold and other button unbold  */
        
        activeBtnOutlet.titleLabel?.font = Utility.Font.Bold.ofSize(18)
        cancelBtnOutlet.titleLabel?.font = Utility.Font.Regular.ofSize(18)
        allBottomViewLeadingOutlet.constant =  0
        //      scrollViewOutlet.contentOffset.x = 0
        self.updateScrollViewFrame(newOffsetPoint: 0)
        }
    @IBAction func creditsAction(_ sender: UIButton) {
        
        /* Bug Name :- unbold cancel button in setting ->  my subscription
         Fix Date :- 23/03/2021
         Fixed By :- Nikunj C
         Description Of fix :- when button select it become bold and other button unbold*/
        
        cancelBtnOutlet.titleLabel?.font = Utility.Font.Bold.ofSize(18)
        activeBtnOutlet.titleLabel?.font = Utility.Font.Regular.ofSize(18)
        allBottomViewLeadingOutlet.constant =  self.view.frame.width / 2
        // scrollViewOutlet.contentOffset.x = self.sampleTableView2.frame.origin.x
        self.updateScrollViewFrame(newOffsetPoint: self.view.frame.size.width)
    }
    
 
    func updateScrollViewFrame(newOffsetPoint:CGFloat) {
        var scrollContentOffset = self.scrollViewOutlet.contentOffset
        scrollContentOffset.x = newOffsetPoint
        self.scrollViewOutlet.setContentOffset(scrollContentOffset, animated: true)
    }
    
    //For all Transactions
    func getActiveSubscriptions(){
        let urlStr = AppConstants.subscribersList + "?status=2"
//        let params = ["debitOrCredit":"/0"]
        subscriptionsViewModelObject.getActiveSubscribersList(strUrl: urlStr, params: [:], complitation: {  (success, error, canServiceCall) in
            if success{
                //  self.updateUIForNoBlockUsers()
                print(success)
                self.subscriptionsViewModelObject.offset1 = self.subscriptionsViewModelObject.offset1 - 20
                if self.subscriptionsViewModelObject.activeSubscribersListArray.count == 0 {
                    self.setTableViewOrCollectionViewBackground(tableView: self.activeSubscriptionsTableView, collectionView: nil, image: #imageLiteral(resourceName: "NoSubscription"), labelText: "No active subscriptions yet".localized + ". ", labelWithImage: true, yPosition: self.view.center.y - 120)

                }
                 self.activeSubscriptionsTableView.reloadData()
            }else if let error = error{
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
                if self.subscriptionsViewModelObject.activeSubscribersListArray.count == 0 {
                    self.setTableViewOrCollectionViewBackground(tableView: self.activeSubscriptionsTableView, collectionView: nil, image: #imageLiteral(resourceName: "NoSubscription"), labelText: "No active subscriptions yet".localized + ". ", labelWithImage: true, yPosition: self.view.center.y - 120)

                }
                self.subscriptionsViewModelObject.offset1 = self.subscriptionsViewModelObject.offset1 - 20
            }
            self.canServiceCall = canServiceCall
             Helper.hidePI()
        })
    }
    
    //For all Credits
    func getCanceledSubscriptions(){
        let urlStr = AppConstants.subscribersList + "?status=3"
        subscriptionsViewModelObject.getCancelledSubscribersList(strUrl: urlStr, params: [:], complitation: {  (success, error, canServiceCall) in
            if success{
                //  self.updateUIForNoBlockUsers()
                print(success)
                if self.subscriptionsViewModelObject.cancelledSubscribersListArray.count == 0 {
                    self.setTableViewOrCollectionViewBackground(tableView: self.cancelSubscriptionsTableView, collectionView: nil, image: #imageLiteral(resourceName: "Group 40834"), labelText: "No cancelled subscriptions yet".localized + ". ", labelWithImage: true, yPosition: self.view.center.y - 120)

                }
                self.cancelSubscriptionsTableView.reloadData()
            }else if let error = error{
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
                if self.subscriptionsViewModelObject.cancelledSubscribersListArray.count == 0 {
                    self.setTableViewOrCollectionViewBackground(tableView: self.cancelSubscriptionsTableView, collectionView: nil, image: #imageLiteral(resourceName: "Group 40834"), labelText: "No cancelled subscriptions yet".localized + ". ", labelWithImage: true, yPosition: self.view.center.y - 120)

                }
                self.subscriptionsViewModelObject.offset2 = self.subscriptionsViewModelObject.offset2  - 20
            }
            self.canServiceCall = canServiceCall
             Helper.hidePI()
        })
    }
    
    func setTableViewOrCollectionViewBackground(tableView: UITableView? , collectionView: UICollectionView?,image : UIImage?,labelText: String?,labelWithImage:Bool , yPosition: CGFloat){
        
        let backgroundView = UIView()
        backgroundView.frame = self.view.frame
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
    
    
    @IBAction func removeSubscription(_ sender: UIButton) {
        if self.subscriptionsViewModelObject.activeSubscribersListArray[sender.tag].isSubscriptionCancelled == 1 {
            if let timeStamp = self.subscriptionsViewModelObject.activeSubscribersListArray[sender.tag].endDateTimeStamp {
                let Date:Date = Helper.getDateObj(fromTimeStamp: String(Int(timeStamp)))
                Helper.showAlertViewOnWindow("Message".localized, message: "You have already cancelled the subscription".localized + ". " + "Your current billing cycle ends on".localized + " \(Date.toString(dateFormat: "dd MMM yyyy")), " + "so subscription will remain active till then and it will stop there after".localized + ".")
            }
        }else{
            selectedCancelIndex = sender.tag
            let storyBoardObj = UIStoryboard.init(name: "Alerts".localized, bundle: nil)
            if #available(iOS 13.0, *) {
                guard let cancelSubscriptionConfirmVc = storyBoardObj.instantiateViewController(identifier: "CancelSubsscritpionViewController") as? CancelSubsscritpionViewController else {return}
                cancelSubscriptionConfirmVc.definesPresentationContext = true
                cancelSubscriptionConfirmVc.modalPresentationStyle = .overCurrentContext
                cancelSubscriptionConfirmVc.delegate = self
                cancelSubscriptionConfirmVc.data = self.subscriptionsViewModelObject.activeSubscribersListArray[sender.tag]
                var topRootViewController = UIApplication.shared.keyWindow?.rootViewController
                while ((topRootViewController?.presentedViewController) != nil) {
                    topRootViewController = topRootViewController?.presentedViewController
                }
                DispatchQueue.main.async {
                    topRootViewController?.present(cancelSubscriptionConfirmVc, animated: true, completion: nil)
                }
    //            self.present(unLockConfirmVc,animated: true)
            } else {
                // Fallback on earlier versions
            }
        }
        
    }
    
    @IBAction func renewbtnAction(_ sender: UIButton) {
        let profileVC = ProfileViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Profile) as ProfileViewController
        profileVC.isNotFromTabBar = true
        profileVC.memberId = self.subscriptionsViewModelObject.cancelledSubscribersListArray[sender.tag].beneficiaryId
        self.navigationController?.pushViewController(profileVC, animated: true)
        
//        selectedRenewIndex = sender.tag
//        let storyBoardObj = UIStoryboard.init(name: "Alerts", bundle: nil)
//        if #available(iOS 13.0, *) {
//            guard let cancelSubscriptionConfirmVc = storyBoardObj.instantiateViewController(identifier: "RenewSubscriptionAlertViewController") as? RenewSubscriptionAlertViewController else {return}
//            cancelSubscriptionConfirmVc.definesPresentationContext = true
//            cancelSubscriptionConfirmVc.modalPresentationStyle = .overCurrentContext
//            cancelSubscriptionConfirmVc.delegate = self
//            cancelSubscriptionConfirmVc.data = self.subscriptionsViewModelObject.cancelledSubscribersListArray[sender.tag]
//            var topRootViewController = UIApplication.shared.keyWindow?.rootViewController
//            while ((topRootViewController?.presentedViewController) != nil) {
//                topRootViewController = topRootViewController?.presentedViewController
//            }
//            DispatchQueue.main.async {
//                topRootViewController?.present(cancelSubscriptionConfirmVc, animated: true, completion: nil)
//            }
////            self.present(unLockConfirmVc,animated: true)
//        } else {
//            // Fallback on earlier versions
//        }
    }
    
    
}

extension SubscriptionsViewController:UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch tableView {
        case activeSubscriptionsTableView:
            return self.subscriptionsViewModelObject.activeSubscribersListArray.count
        case cancelSubscriptionsTableView:
            return self.subscriptionsViewModelObject.cancelledSubscribersListArray.count
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch tableView {
        case activeSubscriptionsTableView:
            if let activeSubCell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: ActiveSubscriptionsCell.self), for: indexPath) as? ActiveSubscriptionsCell{
                activeSubCell.removeButtonOutlet.tag = indexPath.row
                if self.subscriptionsViewModelObject.activeSubscribersListArray.count > indexPath.row {
                    activeSubCell.setCellData(data: self.subscriptionsViewModelObject.activeSubscribersListArray[indexPath.row])
                }
                return  activeSubCell
            }
        case cancelSubscriptionsTableView:
            if let cancelSubCell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: CancelSubscriptionsTableViewCell.self), for: indexPath) as? CancelSubscriptionsTableViewCell{
                cancelSubCell.renewBtnOutlet.tag = indexPath.row
                if self.subscriptionsViewModelObject.cancelledSubscribersListArray.count > indexPath.row {
                    cancelSubCell.setCellData(data: self.subscriptionsViewModelObject.cancelledSubscribersListArray[indexPath.row])
                }
                return  cancelSubCell
            }
        default:
           break
            return UITableViewCell()
            }
        return UITableViewCell()
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 75
        return UITableView.automaticDimension
    }
    }


extension SubscriptionsViewController: CancelSubsscritpionViewControllerDelegate,RenewSubscriptionAlertViewControllerDelegate {
    func confirmNavigation() {
        let data = self.subscriptionsViewModelObject.activeSubscribersListArray[selectedCancelIndex]
        self.profileViewModel.subscribeAndUnSubscribeApiCall(isSubscribe:false, userId: data.beneficiaryId ?? "") { (success, error) in
            print(success)
            if success {
                
                self.subscriptionsViewModelObject.offset1 = -20
                self.getActiveSubscriptions()
            }
        }
    }
    
    func confirmNavigationForRenewSubsribe() {
        let data = self.subscriptionsViewModelObject.cancelledSubscribersListArray[selectedRenewIndex]
        self.profileViewModel.subscribeAndUnSubscribeApiCall(isSubscribe:true, userId: data.beneficiaryId ?? "") { (success, error) in
            print(success)
            if success {
                self.subscriptionsViewModelObject.cancelledSubscribersListArray.remove(at: self.selectedRenewIndex)
                self.activeSubscriptionsTableView.reloadData()
            }
        }
    }
}

extension SubscriptionsViewController: UIScrollViewDelegate {
    
    /* Bug Name :- Scroll view indication not updating
     Fix Date :- 19/05/2021
     Fixed By :- Jayaram G
     Description Of fix :- Changing indication bar when scrollview animation end
     */
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.scrollViewOutlet {
            if scrollView.contentOffset.x == 0 {
                self.AllTransactionsAction(self.activeBtnOutlet)
            }else{
                self.creditsAction(self.cancelBtnOutlet)
            }
        }
    }
}
