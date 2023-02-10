//
//  GiftChooserViewController.swift
//  Live
//
//  Created by leo on 16/7/15.
//  Copyright © 2016年 io.ltebean. All rights reserved.
//

import UIKit

protocol GiftChooserViewControllerDelegate {
    func sentGiftCoinAnimation()
    /* Bug Name : "LIVESTREAM In other person livestream, user is able to send gifts when there are no coins or not. In other person
     livestream, user should not be able to send gifts when there are no coins."
     Fix Date : 26-May-2021
     Fixed By : Jayaram G
     Description Of Fix : Added alert options to navigate to coin wallet screen.
     */
    func navigateToCoinWallet()
}
class GiftChooserViewController: UIViewController {
    @IBOutlet weak var giftviewcontroller: UICollectionView!
    @IBOutlet weak var categoryViewController: UICollectionView!
    @IBOutlet weak var balanceLabelOutlet: UILabel!
    @IBOutlet weak var backViewOutlet: UIView!
    @IBOutlet weak var yourBalanceOutlet: UILabel!
    @IBOutlet weak var getMoreBtn: UIButton!
        
    var canServiceCall: Bool = false
    var audiStreamID = ""
    var audienceModel = AudienceModel()
    var selectedIndex = 0
    var receiverName: String = ""
    var receiverId:String = ""
    var walletbalance: Double = 0.0
    var canServiceCallForGifts: Bool = false
    var delegate:GiftChooserViewControllerDelegate?
    var audioPlayer:AVAudioPlayer?
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(GiftChooserViewController.handleTap(_:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
//        backViewOutlet.makeBorderColorAndBorderWidth(UIColor.lightGray.cgColor, borderWidth: 0.5)
//        backViewOutlet.makeShadowEffect(color: .lightGray)
        self.getCategoryServiceCall()
//        getTheGiftData()
        self.yourBalanceOutlet.text = "Your balance".localized
        self.getMoreBtn.setTitle("Get more".localized, for: .normal)
        if let walletData = KeychainHelper.sharedInstance.getCoinWalletBalance() as? String{
            self.balanceLabelOutlet.text = walletData + " " + "Coins".localized
            self.walletbalance = Double(KeychainHelper.sharedInstance.getCoinWalletBalance()) ?? 0.0
        }
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
    
    func getTheGiftData()  {
        audienceModel.getTheGiftsData { (data) in
            self.audienceModel.categories = data
            self.giftviewcontroller.reloadData()
            self.categoryViewController.reloadData()
        }
    }
    
    
    //MARK:- Service call
    func getCategoryServiceCall(){
        let url = AppConstants.giftCategories
        self.audienceModel.getCategorys(strUrl: url) { (success, error, canServiceCall) in
            if success{
                DispatchQueue.main.async {
                    self.categoryViewController.reloadData()
                }
                self.getGiftsAccordingToCategories(index: self.selectedIndex)
            }else if let error = error{
                if error.code != 204{
//                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
            }
            self.canServiceCall = canServiceCall
        }
    }
    
    func getGiftsAccordingToCategories(index: Int) {
        let url = AppConstants.gifts + "?categoryId=\(self.audienceModel.categoryListArray[index].categoryId ?? "")&status=1"
        
        self.audienceModel.getGifts(strUrl: url) { (success, error, canServiceCall) in
            if success{
                self.giftviewcontroller.reloadData()
            }else if let error = error{
                if error.code != 204{
//                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
            }
            self.canServiceCallForGifts = canServiceCall
        }
    }
    
    @IBAction func dismissBtnAction(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func getMoreCoinsBtnAction(_ sender: Any) {
        self.dismiss(animated: true) {
        self.delegate?.navigateToCoinWallet()
        }
    }
    
    
    
    @IBAction func openWalletScreenAction(_ sender: UIButton) {
        let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Services, bundle: nil)
        let walletVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.walletVcId) as! WalletViewController
//        walletVc.isPresented = true
        let navigation = UINavigationController.init(rootViewController: walletVc)
        self.present(navigation,animated: true)
        
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else {
            return
        }
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    
    func widthOfTheLabel(text: String, height: CGFloat) -> CGFloat {
        
        let label: UILabel = UILabel(frame: CGRect(x: 0,
                                                   y: 0,
                                                   width: CGFloat.greatestFiniteMagnitude,
                                                   height: height))
        label.numberOfLines = 1
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.text = text
        label.sizeToFit()
        
        return label.frame.width + 25
    }
}


extension GiftChooserViewController:UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: self.giftviewcontroller) || touch.view!.isDescendant(of: self.categoryViewController){
            return false
        }else{
            return true
        }
    }
}


extension GiftChooserViewController:UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {        
        if collectionView.tag == 99{
            var cellSize = CGSize()
            cellSize.width = (collectionView.bounds.width - 35)/4
            cellSize.height = 70
            return cellSize
        }else{
            var cellSize = CGSize()
            cellSize.width = self.widthOfTheLabel(text: "Category", height: 90)
            cellSize.height = 90
            return cellSize
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 99{
            DispatchQueue.main.async {
                self.checkBalanceAndSendGift(indexPath: indexPath)
            }
        }else{
            self.audienceModel.giftsListArray.removeAll()
            getGiftsAccordingToCategories(index: indexPath.row)
            selectedIndex = indexPath.row
            self.giftviewcontroller.reloadData()
            self.categoryViewController.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == categoryViewController {
            let indexPassed: Bool = indexPath.item >= self.audienceModel.categoryListArray.count - 15
            if canServiceCall && indexPassed{
                canServiceCall = false
                getCategoryServiceCall()
            }
        }else{
            let indexPassed: Bool = indexPath.item >= self.audienceModel.categoryListArray.count - 15
            if canServiceCallForGifts && indexPassed{
                canServiceCallForGifts = false
                self.getGiftsAccordingToCategories(index: self.selectedIndex)
            }
        }
    }
    
    func checkBalanceAndSendGift(indexPath: IndexPath){
//        let data = self.audienceModel.giftsListArray[selectedIndex]
        let giftData = self.audienceModel.giftsListArray[indexPath.row]
        let coins = Double(giftData.giftCost ?? 0)
        if walletbalance > coins{
            let dict = ["message":"0",
                        "streamID":audiStreamID,
                        "image":giftData.gifIcon as Any,
                        "gifs":giftData.gif as Any,
                        "name":giftData.giftTitle as Any,
                        "id":giftData.giftId as Any,
                        "coin":giftData.giftCost as Any,
                        "userName":Utility.getUserName(),
                        "userId":Utility.getUserid() as Any,
                        "userImage":UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userImage) as Any
            ]
            do{
                let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                print(jsonData)
                MQTT.sharedInstance.publishData(wthData: jsonData, onTopic: AppConstants.MQTT.gift + audiStreamID, retain: false, withDelivering: .exactlyOnce)
            }catch{
                
            }
            let apiParams = ["senderId":Utility.getUserid() ?? "",
                             "senderName": Utility.getUserName() as Any,
                             "senderType": "user",
                             "giftId":giftData.giftId ?? "",
                             "streamId":audiStreamID as Any,
                             "receiverId":self.receiverId ?? "",
                             "receiverType":"user",
            "receiverName":self.receiverName as Any,
            "notes":"gift",
            "description":"gift"] as [String:Any]
            self.audienceModel.giftTransferApiCall(strUrl: AppConstants.giftTransfer, params: apiParams as [String : Any]) { (success, error) in
                if success {
                    print("Sent Successfully ")
                }
            }
            /*
             Bug Name:- Balance not updating after sending gift in live stream
             Fix Date:- 25/05/21
             Fix By  :- Jayaram G
             Description of Fix:- updating wallet balace
             */
            UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.walletUpdate)
            let balance = walletbalance - coins
            walletbalance = balance
            KeychainHelper.sharedInstance.setCoinWalletBalance(balance: "\(balance)")
            UserDefaults.standard.set(balance, forKey: AppConstants.UserDefaults.walletBalance)
            self.balanceLabelOutlet.text = "\(Int(balance)) Coins"
            /*
             Bug Name:- when I send 10 coins it appears like 100 coins in that animation
             Fix Date:- 25/05/21
             Fix By  :- Jayaram G
             Description of Fix:- Showing Int values instead of Double
             */
            showCoinAnymation(coins: "\(Int(coins))")
//            presentingViewController?.dismiss(animated: true, completion: {
//                self.delegate?.sentGiftCoinAnimation()
//            })
            
        }else{
            Helper.showAlertViewOnWindow("Insufficient balance".localized, message: "Not enough coins".localized + " , " + "please rechange and try again".localized + ".")
        }
    }
    
    
     func showCoinAnymation(coins: String){
          self.playCoinsSound()
          for i in 1..<7 {
              if(self.balanceLabelOutlet != nil) {
                  self.view.applyCoinsAnimation(indexAt:i
                                                , fromView:self.balanceLabelOutlet.superview!, coins: coins, image: UIImage(named: "dollar"))
              }
          }
      }
    
    func playCoinsSound() {
           guard let path = Bundle.main.path(forResource: "Coin-collect-sound-effect", ofType: "mp3") else{
               return
           }
           guard let url = URL(string: path) else{return}
           do{
               audioPlayer = try AVAudioPlayer(contentsOf: url)
               audioPlayer?.prepareToPlay()
               audioPlayer?.play()
           }catch let error{
               print(error.localizedDescription)
           }
       }
}

extension GiftChooserViewController:UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 99{
            if self.audienceModel.categoryListArray.count > 0{
            return self.audienceModel.giftsListArray.count
            }else{
                return 0
            }
        }else{
            return self.audienceModel.categoryListArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 99{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GiftCollectionCell", for: indexPath) as! GiftCollectionCell
            
            cell.data = self.audienceModel.giftsListArray[indexPath.row]
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionCell", for: indexPath) as! CategoryCollectionCell
            if selectedIndex == indexPath.row{
                cell.categoryName.textColor = UIColor.white
                cell.selectionView.isHidden = false
            }else{
                cell.categoryName.textColor = UIColor.lightGray
                cell.selectionView.isHidden = true
            }
            cell.categoryName.text = self.audienceModel.categoryListArray[indexPath.row].categoryName
            cell.categoryImage.setImageOn(imageUrl: self.audienceModel.categoryListArray[indexPath.row].categoryActiveIconUrl, defaultImage: #imageLiteral(resourceName: "icon-gift"))
            return cell
        }
    }
}
