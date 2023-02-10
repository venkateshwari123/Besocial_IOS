//
//  QrCodeViewController.swift
//  Starchat
//
//  Created by Rahul Sharma on 06/06/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G

import UIKit
import Kingfisher
class QrCodeViewController: UIViewController,BarcodeDelegate  {
    
    /// After scannig Bar Code
    ///
    /// - Parameter barcode: We are getting Response as String (qrCode)
    func barcodeReaded(barcode: String) {
        print(barcode)
    }
    
    
    /* Bug Name :  After scanning qrcode need to navigate to profile page
     Fix Date : 02-Apr-2021
     Fixed By : Jayaram G
     Description Of Fix : Added profile navigation here through protocol delegate
     */
    func moveToProfileUser(userId: String) {
        let profileVC = ProfileViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Profile) as ProfileViewController
        profileVC.isSelf = false
        profileVC.isNotFromTabBar = true
        profileVC.memberId = userId
        profileVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(profileVC, animated: true)
        
    }
    
    
    //MARK:- All Outlets
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var qrCodeView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var qrCodeImage: UIImageView!
    @IBOutlet weak var scanQRCodeLabel: UILabel!
    
    
    //MARK:- Variables&declarations
    var qrCode:String?
    var profielVmObject = ProfileViewModel()
    var qrCodeVmObject = QrCodeViewModel()
    var isPrivate:Int = 0
    
    //MARK:- App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        Helper.addedUserImage(profilePic: Utility.getUserImage(), imageView: self.profileImage, fullName: Utility.getUserFullName() ?? "P")
        userNameLabel.text = Utility.getUserName()
        scanQRCodeLabel.text = "Scan the QR Code to add me on".localized + " \(AppConstants.AppName)"
        uiDesign()
        navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: Strings.NavigationTitles.myQrCode.localized)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.layer.zPosition = 0;
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        if self.qrCodeVmObject.qrCodeString == nil {
            self.qrCodeImage.setImageOn(imageUrl: self.qrCode, defaultImage: UIImage())
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
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    //MARK:- UIDesign
    func uiDesign(){
        qrCodeView.layer.shadowColor = UIColor.darkGray.cgColor
        qrCodeView.layer.shadowOffset = CGSize(width: 2, height: 2)
        qrCodeView.layer.shadowOpacity = 0.5
        qrCodeView.layer.shadowRadius = 3
        profileImage.makeImageCornerRadius(40)
    }
    
    //MARK:- Button Actions 
    @IBAction func openQrScanner(_ sender: UIButton) {
        let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
        let qrScannerVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.qrScannerViewControllerVcId) as! QrScannerViewController
        qrScannerVc.isPrivate = self.isPrivate
        qrScannerVc.delegate = self
        self.present(qrScannerVc,animated: true)
    }
    
    /// Resending QrCode Again
    ///
    /// - Parameter sender: resendBtn
    @IBAction func resendQrCode(_ sender: UIButton) {
        resendingQrCode()
    }
    
    /// To Get the QrCode 2ND Time
    func resendingQrCode(){
        let url = AppConstants.qrCode
        self.qrCodeVmObject.getQrCode(strUrl: url) { (success, error) in
            if success{
                KingfisherManager.shared.cache.removeImage(forKey: self.qrCodeVmObject.qrCodeString ?? "")
                self.qrCodeImage.setImageOn(imageUrl: self.qrCodeVmObject.qrCodeString, defaultImage: #imageLiteral(resourceName: "defaultImage"))
            }else{
                print(error?.localizedDescription)
            }
        }
        
    }
    
}
