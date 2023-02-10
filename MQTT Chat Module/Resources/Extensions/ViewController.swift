//
//  ViewController.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 28/08/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController{
    
    struct controllerIdentifierName {
        static let searchViewController = "searchViewController"
        static let profileViewController = "ProfileViewController"
    }
    
    
    
    /// Search Button action of navigationbar
    ///
    /// - Parameter sender: search button
    @IBAction func searchProfileAction(_ sender: Any) {
        print("search button clicked")
         let storyBoard = UIStoryboard(name: AppConstants.StoryBoardIds.Main, bundle: nil)
        guard let searchViewController = storyBoard.instantiateViewController(withIdentifier: controllerIdentifierName.searchViewController) as? SearchViewController else {return}
  // self.navigationController?.pushViewController(searchViewController, animated: true)
         self.present(searchViewController, animated: true, completion: nil)
    }
    
    /// Profile image button action of navigatio bar
    ///
    /// - Parameter sender: profile button
    @IBAction func profileImageButtonAction(_ sender: Any) {
        let profileVC = ProfileViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Profile) as ProfileViewController
        profileVC.isNotFromTabBar = true
        profileVC.isSelf = true
        profileVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    
    /// Profile image button action of navigatio bar
    ///
    /// - Parameter sender: profile button
    @IBAction func optionsAction(_ sender: Any) {
        let storyBoard = UIStoryboard(name: AppConstants.StoryBoardIds.Services, bundle: nil)
        guard let optionsVC = storyBoard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.customOptionsAlertViewControllerId) as? CustomOptionsAlertViewController else {return}
        optionsVC.definesPresentationContext = true
       optionsVC.modalPresentationStyle = .overCurrentContext
        
      //  splitViewController?.showDetailViewController(optionsVC, sender: nil)
      //   optionsVC.modalPresentationStyle = .pageSheet
        optionsVC.hidesBottomBarWhenPushed = true
        
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController!.present(optionsVC, animated: false, completion: nil)
    }
    

    /// Back Button action
    ///
    /// - Parameter sender: back button
    @IBAction func backAction(_ sender: Any) {
        if self.navigationController?.presentedViewController != nil {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    /// Back Button action
    ///
    /// - Parameter sender: back button
    @IBAction func dismissVcAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //Wallet Action
    @IBAction func walletAction(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Services, bundle: nil)
        let walletVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.walletVcId) as! WalletViewController
        self.navigationController?.pushViewController(walletVc, animated: true)
    }
    
    @IBAction func btnCamera_Tapped(_ sender : UIButton){
        let rootVC : RootViewController = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as! RootViewController
        rootVC.collectionControllers.scrollToItem(at: IndexPath.init(row: 0, section: 0), at: .right, animated: false)
    }
    
    /// To show alert
    ///
    /// - Parameters:
    ///   - title: title of alert
    ///   - message: message of alert
    func showAlert(_ title: String, message: String) {
        
        // create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK".localized, style: UIAlertAction.Style.default, handler: { action in
            // do something like...
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func setTblOrCollectionViewBackground(tableView: UITableView? , collectionView: UICollectionView?,image : UIImage?,labelText: String?,labelWithImage:Bool , yPosition: CGFloat){
        
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
    
    func addObserVerForCamera() {
        NotificationCenter.default.addObserver(self, selector: #selector(openInstagramCameraVc(_:)), name: NSNotification.Name(rawValue: "openCameraForPost"), object: nil)
    }
    
    @objc func openInstagramCameraVc(_ notification: NSNotification){
        DispatchQueue.main.async {
            let picker = YPImagePicker()
            picker.modalPresentationStyle = .overCurrentContext
//            picker.selectedVideo =
            
            self.present(picker, animated: true, completion: {
                if let tabController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
                    guard let swipeNav = tabController.viewControllers?[0] as? SwipeNavigationController else {
                        return
                    }
                    guard let postDetails = swipeNav.viewControllers.first as? SocialViewController else {return}
                    postDetails.stopVideoPlayer()
                }
            })
//            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController!.present(picker, animated: true, completion: nil)
        }
    }
    
    func presentCameraVC(){
        DispatchQueue.main.async {
            let picker = YPImagePicker()
            picker.modalPresentationStyle = .fullScreen
            self.present(picker, animated: true, completion: nil)
//            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController!.present(picker, animated: true, completion: nil)
        }
    }
    
    
    
    /// To make fade animation on a view controller
    func applyFadeAnimationOnController(){
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.fade
        self.view.layer.add(transition, forKey: nil)
    }
}

final class SwipeNavigationController: UINavigationController {

    // MARK: - Lifecycle

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // This needs to be in here, not in init
        interactivePopGestureRecognizer?.delegate = self
    }

    deinit {
        delegate = nil
        interactivePopGestureRecognizer?.delegate = nil
    }

    // MARK: - Overrides

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        duringPushAnimation = true

        super.pushViewController(viewController, animated: animated)
    }

    // MARK: - Private Properties

    fileprivate var duringPushAnimation = false

}

// MARK: - UINavigationControllerDelegate

extension SwipeNavigationController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let swipeNavigationController = navigationController as? SwipeNavigationController else { return }

        swipeNavigationController.duringPushAnimation = false
    }

}

// MARK: - UIGestureRecognizerDelegate

extension SwipeNavigationController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == interactivePopGestureRecognizer else {
            return true // default value
        }

        // Disable pop gesture in two situations:
        // 1) when the pop animation is in progress
        // 2) when user swipes quickly a couple of times and animations don't have time to be performed
        return viewControllers.count > 1 && duringPushAnimation == false
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboards))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboards() {
        view.endEditing(true)
    }
}
