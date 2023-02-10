//
//  CustomOptionsAlertViewController.swift
//  Starchat
//
//  Created by Rahul Sharma on 08/07/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
protocol PostDetailsControllerDelegate {
    func editPost()
    func deletePost()
    func reportPost()
    func playVideo()
}
class CustomOptionsAlertViewController: UIViewController,UIGestureRecognizerDelegate {


    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var editPostViewOutlet: UIView!
    @IBOutlet weak var deletePostViewOutlet: UIView!
    
    @IBOutlet weak var reportViewOutlet: UIView!
    
    var isSelf:Bool = false
    var data: SocialModel?
    var delegate:PostDetailsControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isSelf  {
            editPostViewOutlet.isHidden = false
            deletePostViewOutlet.isHidden = false
            reportViewOutlet.isHidden = true
        }else {
            editPostViewOutlet.isHidden = true
            deletePostViewOutlet.isHidden = true
            reportViewOutlet.isHidden = false
        }
    }
   
    override func viewWillAppear(_ animated: Bool) {
       self.navigationController?.isNavigationBarHidden = true
        uiDesign()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
  
    
    func uiDesign(){
        userNameLbl.text = "More Actions"
        // *** Hide keyboard when tapping outside ***
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        tapGesture.cancelsTouchesInView = true
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
    }
    
    
    
    @objc func tapGestureHandler() {
        UIView.animate(withDuration: 0.1, animations: {
            self.view.layoutIfNeeded()
        }) { (finished) in
            if finished{
                self.dismiss(animated: false,completion: {
                    self.delegate?.playVideo()
                })
            }
        }
    }
    
     @IBAction func dismissActon(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            self.view.layoutIfNeeded()
        }) { (finished) in
            if finished{
                self.dismiss(animated: false,completion: nil)
            }
        }
    }
    
    @IBAction func savedPostsAction(_ sender: UIButton) {
            self.dismiss(animated: false) {
                let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Main, bundle: nil)
                let collectionVC = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.SavedCollectionsViewController) as! SavedCollectionsViewController
                
                collectionVC.hidesBottomBarWhenPushed = true
                
 
                    if let tabbarVC : TabbarController = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as? TabbarController{
                        print(tabbarVC.viewControllers as Any)
                        if let nav = (tabbarVC.viewControllers![tabbarVC.selectedIndex] as? SwipeNavigationController){
                            nav.pushViewController(collectionVC, animated: true)
                        }
                    }
            }
        }
    
    @IBAction func moveToServicesVc(_ sender: UIButton) {
        dismiss(animated: false) {
            self.delegate?.reportPost()
        }
    }
    
    
    @IBAction func moveToDiscoverPeopleVc(_ sender: UIButton) {
        dismiss(animated: false) {
            self.delegate?.deletePost()
        }
    }
    
    
    @IBAction func moveToSavedPostsVc(_ sender: UIButton) {
        self.dismiss(animated: false) {
            self.delegate?.editPost()
        }
    }
    
    @IBAction func moveToSettingsVc(_ sender: UIButton) {
        self.dismiss(animated: false) {
            let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
            let settingsVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.settingVcId) as! SettingViewController
           settingsVc.hidesBottomBarWhenPushed = true
                if let tabbarVC : TabbarController = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as? TabbarController{
                    print(tabbarVC.viewControllers as Any)
                    if let nav = (tabbarVC.viewControllers![tabbarVC.selectedIndex] as? SwipeNavigationController){
                        nav.pushViewController(settingsVc, animated: true)
                    }
                }
//            }
        }
    }
}
