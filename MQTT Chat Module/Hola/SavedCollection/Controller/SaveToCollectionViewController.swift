//
//  SaveToCollectionViewController.swift
//  Starchat
//
//  Created by 3Embed on 03/08/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher

class SaveToCollectionViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, UITextFieldDelegate {

    @IBOutlet weak var collectionBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionMain: UICollectionView!
    @IBOutlet weak var saveToCollectionLbl: UILabel!
    @IBOutlet weak var cancelBtnOutlet: UIButton!
    @IBOutlet weak var newCollectionLbl: UILabel!
    
    
    var imageUrl : String = ""
    var postId : String = ""
    var arrSavedPosts : [SavedCollectionModel] = []
     let model = SaveCollectionViewModel.init(api: SavedCollectionAPI.init())
    var isFromPostDetailsVC:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        getCollections()
        // Do any additional setup after loading the view.
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
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
            if #available(iOS 11, *) {
                if keyboardHeight > 0 {
                    keyboardHeight = keyboardHeight - view.safeAreaInsets.bottom
                }
            }
            let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
            UIView.animate(withDuration: duration!, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
                self.collectionBottomConstraint.constant = keyboardHeight
            }, completion: nil)
            view.layoutIfNeeded()
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionMain{
            return 2
        }else{
            return arrSavedPosts.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionMain{
            switch (indexPath.item) {
            case 0:
                let cell : SaveToCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SaveToCollectionCell", for: indexPath) as! SaveToCollectionCell
                cell.saveToCollectionLbl.text = "Save To".localized
                cell.cancelBtnOutlet.setTitle("Cancel".localized, for: .normal)
                cell.collectionPosts.reloadData()
                return cell
            case 1:
                let cell : NewCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewCollectionCell", for: indexPath) as! NewCollectionCell
                cell.newCollectionLbl.text = "New Collection".localized
                cell.btnCancel.setTitle("Cancel".localized, for: .normal)
                cell.btnBack.isHidden = self.arrSavedPosts.count == 0
                cell.imgCollectionCover.layer.cornerRadius = 4
                cell.imgCollectionCover.setImageOn(imageUrl: imageUrl,  defaultImage: #imageLiteral(resourceName: "defaultPicture"))
                return cell
            default:
                return UICollectionViewCell()
            }
        }else{
            let cell : collectionItemsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionItemsCell", for: indexPath) as! collectionItemsCell
            cell.imgCover.layer.cornerRadius = 4
            cell.imgCover.setImageOn(imageUrl: arrSavedPosts[indexPath.item].coverImage, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
            cell.lblCollectionName.text = arrSavedPosts[indexPath.item].collectionName
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? NewCollectionCell{
            cell.tfCollectionName.becomeFirstResponder()
        }else{
            self.view.endEditing(true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collectionMain{
            return CGSize.init(width: self.view.frame.size.width, height: collectionMain.frame.size.height)
        }else{
            if AppConstants.appType == .picoadda {
                return CGSize.init(width: 110, height: 110)
            }else{
                return CGSize.init(width: 100, height: 130)
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView != collectionMain{
            model.addPostsToCollection(arrSavedPosts[indexPath.item].id, postIds: [self.postId])
            model.didUpdateDict = { response in
                self.dismiss(animated: true, completion: {
                    if self.isFromPostDetailsVC {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showViewCollectionsForPostDetails"), object: self.arrSavedPosts[indexPath.item])
                    }else {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showViewCollections"), object: self.arrSavedPosts[indexPath.item])
                    }
                    
                })
            }
            model.didError = { error in
            }
        }
    }
    
    @IBAction func btnAddNewCollection(_ sender: Any) {
        collectionMain.scrollToItem(at: IndexPath.init(row: 1, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    @IBAction func btnCancelSaving(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnDoneNewCollection(_ sender: Any) {
        let cell : NewCollectionCell = collectionMain.cellForItem(at: IndexPath.init(row: 1, section: 0)) as! NewCollectionCell
        if cell.btnCancel.titleLabel?.text == "Done".localized{
            model.createCollection(imageUrl, collectionName: cell.tfCollectionName.text!, postIds: [postId])
            model.didUpdateDict = { response in
                self.view.endEditing(true)
                self.dismiss(animated: true, completion: nil)
            }
            model.didError = { error in
                
            }
        }else{
            self.view.endEditing(true)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func btnBackToCollections(_ sender: Any) {
        if self.arrSavedPosts.count == 0{
            self.view.endEditing(true)
            self.dismiss(animated: true, completion: nil)
        }
        collectionMain.scrollToItem(at: IndexPath.init(row: 0, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    func getCollections(){
        model.getUserCollections(offset: 0)
        model.didUpdate = { arrCollections, arrPosts in
            self.arrSavedPosts.append(contentsOf: arrCollections)
            self.collectionMain.reloadData()
            if arrCollections.count == 0{
                self.collectionMain.scrollToItem(at: IndexPath.init(row: 1, section: 0), at: .centeredHorizontally, animated: false)
            }
        }
        model.didError = { error in
            self.collectionMain.scrollToItem(at: IndexPath.init(row: 1, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let str = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        let cell : NewCollectionCell = collectionMain.cellForItem(at: IndexPath.init(row: 1, section: 0)) as! NewCollectionCell
        if str.count > 0{
            cell.tfCollectionName.returnKeyType = .done
            cell.btnCancel.setTitle("Done".localized, for: .normal)
            cell.btnCancel.backgroundColor = UIColor.init(red: 22.0/255.0, green: 99.0/255.0, blue: 216.0/255.0, alpha: 1.0)
            cell.btnCancel.setTitleColor(.white, for: .normal)
        }else{
            cell.tfCollectionName.returnKeyType = .next
            cell.btnCancel.setTitle("Cancel".localized, for: .normal)
            cell.btnCancel.backgroundColor = .white
            if #available(iOS 13.0, *) {
                cell.btnCancel.setTitleColor(.label, for: .normal)
            } else {
                cell.btnCancel.setTitleColor(.black, for: .normal)
                // Fallback on earlier versions
            }
        }
        cell.tfCollectionName.reloadInputViews()
        
//        let size = str.size(attributes:[NSFontAttributeName: textField.font!])
//        print(size.width)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

