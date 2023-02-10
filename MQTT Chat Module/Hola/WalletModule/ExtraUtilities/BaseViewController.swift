//
//  BaseViewController.swift
//  CommonNavigationVC
//
//  Created by Rahul Sharma on 02/04/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController,UINavigationControllerDelegate,UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().tintColor = UIColor.black
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        
        if (self.navigationController != nil){
            Helper.transparentNavigation(controller: self.navigationController!)
        }
        self.navigationController?.navigationBar.setBackgroundImage(nil, for:.default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.layoutIfNeeded()
        self.title = "Navigation Title"
    }
    
    
    @objc func dismiss_Keyboard(){
                self.view.endEditing(true)
            }
    
    func addShadowToBar() {
        let shadowView = UIView(frame: self.navigationController!.navigationBar.frame)
        shadowView.backgroundColor = UIColor.white
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowOpacity = 0.4 // your opacity
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 2) // your offset
        shadowView.layer.shadowRadius =  4 //your radius
        self.view.addSubview(shadowView)
    }
    
    func setNavigationLeftBarBackButton( img : UIImage = #imageLiteral(resourceName: "arrow_left")){
        
        let backButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.frame = CGRect(x: -30, y: 0, width: 40, height: 40)
        backButton.contentHorizontalAlignment =  .left
        backButton.setImage(img, for: UIControl.State())
        backButton.addTarget(self, action: #selector(moveToBackVC), for: .touchUpInside)
        let backButtonBarItem = UIBarButtonItem(customView: backButton)
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItem =  backButtonBarItem
        
    }
    
    func setNavigationLeftBarCloseButton(){
        
        let backButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.frame = CGRect(x: -30, y: 0, width: 30, height: 30)
        backButton.addTarget(self, action: #selector(dismissVC), for:    .touchUpInside)
        backButton.contentHorizontalAlignment =  .left
        backButton.setImage(#imageLiteral(resourceName: "letter-x") , for: UIControl.State())
        let backButtonBarItem = UIBarButtonItem(customView: backButton)
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItem =  backButtonBarItem
        
    }
    
    func clearNavigation(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = .black
        self.navigationController?.view.backgroundColor = UIColor.clear
    }
  
    func addShadowToNavigationBar( color : UIColor, opacity : Float = 1.0){
        self.navigationController?.navigationBar.layer.shadowColor = color.cgColor
     
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)

        self.navigationController?.navigationBar.layer.shadowRadius = 4.0
        navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.layer.shadowOpacity = opacity
    }
    func removeNavigationRightBarButton(){
         self.navigationItem.rightBarButtonItem = nil
    }
    
    func setNavigationRightBarDoneButton(buttonTitle : String ){
        
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.frame = CGRect(x: -30, y: 0, width: 15, height: 30)
        button.addTarget(self, action: #selector(rightButtonAction), for:  .touchUpInside)
        button.contentHorizontalAlignment =  .right
        button.setTitle(buttonTitle, for: .normal)
        button.titleLabel?.font = Utility.Font.Regular.ofSize(15)
        button.setTitleColor(.black, for: .normal)
        let backButtonBarItem = UIBarButtonItem(customView: button)
        navigationController?.navigationBar.tintColor = .black
        navigationItem.rightBarButtonItem = backButtonBarItem
            
    }
    
    @objc func rightButtonAction( ){
        self.navigationItem.rightBarButtonItem = nil
    }
    
    /// Back Button Action
    @objc func moveToBackVC(){
        self.navigationController?.popViewController(animated: true)
    }
    
    /// Close Button Action
    @objc func dismissVC(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func removeNavigationBarItem(){
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
    }
    
    func hideNavBar(){
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func unHideNavBar(){
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func removeTransparentView(){
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor =  UIColor.colorWithHex(color: Colors.AppBaseColor)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
    }
    
    func restoreBar(){
        self.navigationController?.navigationBar.setBackgroundImage(nil, for:.default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.layoutIfNeeded()
    }
    
    func addTransparentNavigation(color : UIColor = .clear ){
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.shadowImage = UIImage.init()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(), for: UIBarMetrics.default )
        self.navigationItem.title = ""
        self.navigationController?.navigationBar.tintColor = color
    }
    
    func addTableViewHeader(tableview: UITableView,viewColor: UIColor, headerText: String) -> UIView {
        
        let customView = UIView(frame:CGRect(x: 0, y: 0, width: tableview.frame.width, height: 50))
        customView.backgroundColor = viewColor
        let label = UILabel(frame: CGRect(x: 20, y: 12.5, width: tableview.frame.width, height: 25))
        label.text = headerText
        label.textColor = .lightGray
        customView.addSubview(label)
        return customView
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
            imageView.contentMode = .scaleAspectFit
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
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height - 300, width: 150, height: 35))
        toastLabel.backgroundColor = #colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 1)
        toastLabel.textColor = UIColor.white
        toastLabel.font = Utility.Font.Regular.ofSize(10)
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 5
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 2.0, delay: 2, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    func setTableViewPlaceHolderCell(tableView: UITableView, indexPath: IndexPath, image: UIImage, noDataText: String) -> UITableViewCell{
        tableView.registerCell(cellname: "NoDataPlaceHolderTableViewCell")
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoDataPlaceHolderTableViewCell", for: indexPath) as? NoDataPlaceHolderTableViewCell else { return UITableViewCell() }
        cell.configureCell(image: image, noDataText: noDataText)
        return cell
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool{
          guard let _ = touch.view?.isKind(of: RechargeSuggetionsCell.self) else{
              return true
          }
          return false
      }
    
}

extension UICollectionViewCell{
    
    func setCollectionViewPlaceHolderCell(collectionView: UICollectionView, indexPath: IndexPath, image: UIImage, noDataText: String) -> UICollectionViewCell{
        collectionView.registerCell(cellname: "NoDataPlaceHolderCollectionViewCell")
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoDataPlaceHolderCollectionViewCell", for: indexPath) as? NoDataPlaceHolderCollectionViewCell else { return UICollectionViewCell() }
        cell.configureCell(image: image, noDataText: noDataText)
        return cell
    }
}

 //MARK: - UITableView
extension UITableView{
    /// function is used to register any custom UITableViewCell in any UITableView
    ///
    /// - Parameter cellname: pass the name of that cell which you wanna register in UITableView
    func registerCell(cellname : String){
        register(UINib.init(nibName: cellname, bundle: nil), forCellReuseIdentifier: cellname)
    }
    
    func sizeForHeader(){
        if let headerView = self.tableHeaderView{
            headerView.setNeedsLayout()
            headerView.layoutIfNeeded()
            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var frame = headerView.frame
            frame.size.height = height
            headerView.frame = frame
            self.tableHeaderView = headerView
        }
    }
    
    func reloadData(completion: @escaping () -> ()) {
        UIView.animate(withDuration: 0, animations: { self.reloadData()})
        {_ in completion() }
    }
}


// MARK: - UICollectionView
extension UICollectionView{
    
    /// function is used to register any custom UIcollectionViewCell in any UICollectionView
    ///
    /// - Parameter cellname: pass the name of that cell which you wanna register in collectionView
    func registerCell(cellname : String){
        register(UINib.init(nibName: cellname, bundle: nil), forCellWithReuseIdentifier: cellname)
    }
}
