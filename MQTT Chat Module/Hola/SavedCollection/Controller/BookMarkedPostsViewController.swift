//
//  BookMarkedPostsViewController.swift
//  Starchat
//
//  Created by 3Embed on 31/07/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher

class BookMarkedPostsViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var vwNoPosts: UIView!
    @IBOutlet weak var collectionBookmarks: UICollectionView!
    @IBOutlet weak var startSavingLbl: UILabel!
    @IBOutlet weak var savePhotoAndVieoLbl: UILabel!
    @IBOutlet weak var addToCollectionBtn: UIButton!
    
    let model = SaveCollectionViewModel.init(api: SavedCollectionAPI.init())
    var arrBookmarkedPosts : [BookMark] = []
    var arrCollectionPosts : [Collection] = []
    var strCollectionName : String = ""
    var isCollectionDetails : Bool = false
    var collection : SavedCollectionModel!
    var toChangeItemsInCollection : Bool = false
    var toChangeCoverImage : Bool = false
    var coverImage : String = ""
    var isAllPosts : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: isCollectionDetails ? collection.collectionName : toChangeCoverImage ? Strings.NavigationTitles.chaneCollectionCover.localized : toChangeItemsInCollection ? Strings.NavigationTitles.addToCollection.localized : Strings.NavigationTitles.createCollection.localized)
        if isAllPosts {
            navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: collection.collectionName)
        }
        if let colle = collection, colle.id == "1"{
        }else{
            
            let doneBtn = isCollectionDetails ? UIBarButtonItem.init(image: #imageLiteral(resourceName: "storyMore"), style: .plain, target: self, action: #selector(saveCollection_Tapped)) : UIBarButtonItem.init(title: toChangeCoverImage ? "" : toChangeItemsInCollection ? "Done".localized : "Save".localized, style: .plain, target: self, action: #selector(saveCollection_Tapped))
            doneBtn.tintColor = .label
            navigationItem.rightBarButtonItem = doneBtn
        }
        
        startSavingLbl.text = "Start Saving".localized
        savePhotoAndVieoLbl.text = "Save photos and videos to your collection".localized + "."
        addToCollectionBtn.setTitle("Add to Collection".localized, for: .normal)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        isCollectionDetails || toChangeCoverImage ? getCollectionPosts() : getBookmarkedPosts()
        if let colle = collection, colle.id == "1"{
//            isCollectionDetails = true
            getBookmarkedPosts()
        }
        vwNoPosts.isHidden = true
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
    
    @objc func saveCollection_Tapped(){
        if isCollectionDetails{
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let alertDelete = UIAlertController(title: "Delete Collection".localized + "?", message: "When you delete this collection".localized + ", " + "the photos and videos will still be saved".localized + ".", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Edit Collection".localized, style: .default , handler:{ (UIAlertAction)in
                let editCollectionVC : AddNewCollectionViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddNewCollectionViewController") as! AddNewCollectionViewController
                editCollectionVC.isEdit = true
                editCollectionVC.collection = self.collection
                self.navigationController?.pushViewController(editCollectionVC, animated: true)
            }))
            
            alert.addAction(UIAlertAction(title: "Add to Collection".localized, style: .default , handler:{ (UIAlertAction)in
                self.btnAddToCollection_Tapped(self)
            }))
            
            alert.addAction(UIAlertAction(title: "Delete Collection".localized, style: .destructive , handler:{ (UIAlertAction)in
                self.present(alertDelete, animated: true, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel, handler:{ (UIAlertAction)in
                print("User click Dismiss button")
            }))
            
            self.present(alert, animated: true, completion: {
                print("completion block")
            })
            
            alertDelete.addAction(UIAlertAction(title: "Delete".localized, style: .destructive , handler:{ (UIAlertAction)in
                self.model.deleteCollection(self.collection.id)
                self.model.didUpdateDict = { response in
                    UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.bookMarkUpdate)
                    self.navigationController?.popViewController(animated: true)
                }
                self.model.didError = { error in
                    
                }
            }))
            alertDelete.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler:{ (UIAlertAction)in
                print("User click Dismiss button")
            }))
            
        }else if toChangeItemsInCollection{
            model.addPostsToCollection(collection.id, postIds: arrBookmarkedPosts.filter({$0.isSelected}).map{$0.id})
            model.didUpdateDict = { response in
                UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.bookMarkUpdate)
                self.navigationController?.popViewController(animated: true)
            }
            model.didError = { error in
            }
        }else if toChangeCoverImage{
            self.collection.coverImage = self.arrBookmarkedPosts.filter({$0.isSelected}).first?.thumbnailUrl
            self.navigationController?.popViewController(animated: true)
        }
        else{
            model.createCollection(self.arrBookmarkedPosts.filter({$0.isSelected}).first?.thumbnailUrl ?? "", collectionName: strCollectionName, postIds: arrBookmarkedPosts.filter({$0.isSelected}).map{$0.id})
            model.didUpdateDict = { response in
                UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.bookMarkUpdate)
                if let savedVc = self.navigationController?.viewControllers.filter({$0.isKind(of: SavedCollectionsViewController.self)}).first as? SavedCollectionsViewController  {
                    self.navigationController?.popToViewController(savedVc, animated: true)
                }else{
                    self.navigationController?.popViewController(animated: true)
                }
            }
            model.didError = { error in
                
            }
        }
    }
    
    func getCollectionPosts(){
        if collection.id != nil {
            model.getCollectionDetails(collection.id)
            model.didUpdateCollection = { response in
                self.arrCollectionPosts = response
                self.collectionBookmarks.reloadData()
                self.vwNoPosts.isHidden = response.count > 0
            }
            model.didError = { error in
                self.vwNoPosts.isHidden = false
            }
        }
      }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isCollectionDetails || toChangeCoverImage ? arrCollectionPosts.count : arrBookmarkedPosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookMarkCell", for: indexPath)
        let imageUrl = isCollectionDetails || toChangeCoverImage ? arrCollectionPosts[indexPath.item].thumbnailUrl : arrBookmarkedPosts[indexPath.item].thumbnailUrl
        let imageCover = cell.contentView.viewWithTag(1) as! UIImageView
        imageCover.setImageOn(imageUrl: imageUrl ?? "", defaultImage: #imageLiteral(resourceName: "defaultPicture"))
 
         
        let imageTick = cell.contentView.viewWithTag(2) as! UIImageView
        imageTick.layer.cornerRadius = 10
        imageTick.layer.borderColor = UIColor.white.cgColor
        imageTick.layer.borderWidth = 1
        if isCollectionDetails || toChangeCoverImage{
            imageTick.isHidden = isCollectionDetails || toChangeCoverImage
        }else{
            if let colle = collection, colle.id == "1"{
                imageTick.isHidden = true
            }else{
                imageTick.image = arrBookmarkedPosts[indexPath.item].isSelected ? #imageLiteral(resourceName: "ic_selected") :  UIImage()
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if AppConstants.appType == .picoadda {
            return CGSize.init(width: (collectionView.frame.size.width / 3) - 1, height: (collectionView.frame.size.width / 3) - 1)
        }else{
            return CGSize.init(width: (collectionView.frame.size.width / 3) - 1, height: (collectionView.frame.size.width / 3) + 45)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isAllPosts {
            print("Go to Details")
            if AppConstants.appType == .picoadda {
                Route.navigateToInstaDetailsVc(navigationController: self.navigationController, postsArray: nil, needToCallApi: true, postId: self.arrBookmarkedPosts[indexPath.item].id)
            }else{
                Route.navigateToAllPostsVertically(navigationController: self.navigationController, postId:self.arrBookmarkedPosts[indexPath.item].id,isCommingFromChat:true,isFromProfilePage:true)
            }
            
        }else if !isCollectionDetails{
            if toChangeCoverImage{
                self.collection.coverImage = self.arrCollectionPosts[indexPath.item].thumbnailUrl
                self.navigationController?.popViewController(animated: true)
            }else{
                arrBookmarkedPosts[indexPath.row].isSelected = !arrBookmarkedPosts[indexPath.row].isSelected
            }
            collectionBookmarks.reloadData()
        }else{
            print("go to details")
            if AppConstants.appType == .picoadda {
                Route.navigateToInstaDetailsVc(navigationController: self.navigationController, postsArray: nil, needToCallApi: true, postId: self.arrCollectionPosts[indexPath.item].postId!)
            }else{
                Route.navigateToAllPostsVertically(navigationController: self.navigationController, postId:self.arrCollectionPosts[indexPath.item].postId!,isCommingFromChat:true,isFromProfilePage:true)
            }
        }
    }
    
    func getBookmarkedPosts() {
        
        toChangeItemsInCollection ? model.getUserBookmarksToAddinCollection(collectionId: collection.id) : model.getUserBookmarks()
        model.didUpdateBookmarks = { bookmarks in
            self.arrBookmarkedPosts = bookmarks
            self.collectionBookmarks.reloadData()
            print(bookmarks)
        }
        model.didError = { error in
            
        }
    }
    
    @IBAction func btnAddToCollection_Tapped(_ sender: Any) {
        let bookMarkedPostsVC : BookMarkedPostsViewController = self.storyboard?.instantiateViewController(withIdentifier: "BookMarkedPostsViewController") as! BookMarkedPostsViewController
        bookMarkedPostsVC.strCollectionName = collection.collectionName
        bookMarkedPostsVC.toChangeItemsInCollection = true
        bookMarkedPostsVC.collection = self.collection
        self.navigationController?.pushViewController(bookMarkedPostsVC, animated: true)
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
