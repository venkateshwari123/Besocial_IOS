//
//  SavedCollectionsViewController.swift
//  Starchat
//
//  Created by 3Embed on 30/07/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher

class SavedCollectionsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var vwNoRecords: UIView!
    @IBOutlet weak var nothingToSaveLbl: UILabel!
    @IBOutlet weak var instructionLbl: UILabel!
    @IBOutlet var collectionSaved : UICollectionView!
    var arrSavedPosts : [SavedCollectionModel] = []
    var isFromHome = false
    var postIdToSave = ""
    var thumnailToSave = ""
    var arrBookMarks : [BookMark] = []
    let model = SaveCollectionViewModel.init(api: SavedCollectionAPI.init())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nothingToSaveLbl.text = "Nothing saved yet".localized
        instructionLbl.text = "Save photos and videos that you want to see again".localized + "." + "No one is notified".localized + "," + "and only you can see what you’ve saved".localized
        navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: Strings.NavigationTitles.saved.localized)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "add (2)"), style: .plain, target: self, action: #selector(addNewCollection_Tapped))
        self.vwNoRecords.isHidden = true
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if Utility.isDarkModeEnable(){
            UIApplication.shared.statusBarStyle = .lightContent
        }else{
            UIApplication.shared.statusBarStyle = .darkContent
        }
        self.navigationController?.navigationBar.isHidden = false

        getCollections()
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
    
    
    func getCollections(){
        arrSavedPosts.count == 0 ? Helper.showPI() : print("")

        model.getUserCollections(offset: 0)
        model.didUpdate = { arrCollections, arrPosts in
            Helper.hidePI()
            self.arrSavedPosts.removeAll()
            let obj = SavedCollectionModel.init(modelData: ["_id":"1","collectionName":"All Posts".localized,"coverImage":"","userId":"0","postIds":""])
            self.arrSavedPosts.append(obj)
            self.arrSavedPosts.append(contentsOf: arrCollections)
            self.arrBookMarks = arrPosts
            self.collectionSaved.reloadData()
            self.vwNoRecords.isHidden = self.arrSavedPosts.count > 0
        }
        model.didError = { error in
            Helper.hidePI()
            self.arrBookMarks.removeAll()
            self.collectionSaved.reloadData()
//            if error.code == 204{
//                self.arrSavedPosts.removeAll()
//                let obj = SavedCollectionModel.init(modelData: ["_id":"1","collectionName":"All Posts","coverImage":"","userId":"0","postIds":""])
//                self.arrSavedPosts.append(obj)
//                self.collectionSaved.reloadData()
//            }else{
                self.vwNoRecords.isHidden = false
//            }
        }
    }
    
    @objc func addNewCollection_Tapped(){
        let addNewVC : AddNewCollectionViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddNewCollectionViewController") as! AddNewCollectionViewController
        self.navigationController?.pushViewController(addNewVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrSavedPosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0{
            let cell : AllPostsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AllPostsCell", for: indexPath) as! AllPostsCell
            cell.lblCollectionName.text = "All Posts".localized
            
            if let firstImage = self.arrBookMarks.first{
                cell.imgThumbOne.setImageOn(imageUrl: firstImage.thumbnailUrl!, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
            }else {
                cell.imgThumbOne.image = #imageLiteral(resourceName: "defaultPicture")
            }
            if self.arrBookMarks.count > 1{
                cell.imgThumTwo.setImageOn(imageUrl: self.arrBookMarks[1].thumbnailUrl!, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
            }else {
              cell.imgThumTwo.image = #imageLiteral(resourceName: "defaultPicture")
            }
            if self.arrBookMarks.count > 2{
                cell.imgThumbThree.setImageOn(imageUrl: self.arrBookMarks[2].thumbnailUrl!, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
            }else {
               cell.imgThumbThree.image = #imageLiteral(resourceName: "defaultPicture")
            }
            if self.arrBookMarks.count > 3{
                cell.imgThumbFour.setImageOn(imageUrl: self.arrBookMarks[3].thumbnailUrl!, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
            }else {
               cell.imgThumbFour.image = #imageLiteral(resourceName: "defaultPicture")
            }
            return cell
        }else{
            let cell : SavedCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SavedCollectionCell", for: indexPath) as! SavedCollectionCell
         //   cell.imgCollectionThumb.backgroundColor = .lightGray
            cell.imgCollectionThumb.layer.cornerRadius = 1
            cell.imgCollectionThumb.layer.masksToBounds = true
            cell.lblCollectionName.text = arrSavedPosts[indexPath.item].collectionName
            cell.imgCollectionThumb.setImageOn(imageUrl: arrSavedPosts[indexPath.item].coverImage, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if AppConstants.appType == .picoadda {
            return CGSize.init(width: (collectionView.frame.size.width / 2) - 15, height: (collectionView.frame.size.width / 2) - 15)
        }else{
            let width = self.view.frame.size.width / 2
            return CGSize.init(width: (collectionView.frame.size.width / 2) - 15, height: width + 35)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let bookMarkedVC : BookMarkedPostsViewController = self.storyboard?.instantiateViewController(withIdentifier: "BookMarkedPostsViewController") as! BookMarkedPostsViewController
        bookMarkedVC.collection = arrSavedPosts[indexPath.item]
        bookMarkedVC.isCollectionDetails = indexPath.item == 0 ? false : true
        bookMarkedVC.isAllPosts = indexPath.item == 0 ? true : false
        self.navigationController?.pushViewController(bookMarkedVC, animated: true)
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
