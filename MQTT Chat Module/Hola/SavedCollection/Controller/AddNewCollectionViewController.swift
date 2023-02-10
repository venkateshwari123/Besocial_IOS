//
//  AddNewCollectionViewController.swift
//  Starchat
//
//  Created by 3Embed on 30/07/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher

class AddNewCollectionViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var tfCollectionName: UITextField!
    @IBOutlet weak var imgCollectionCover: UIImageView!
    @IBOutlet weak var btnChangeCover: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    
    @IBOutlet weak var deleteOptionView: UIView!
    @IBOutlet weak var manageLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBOutlet weak var vwCollectionDetailsHeightConstraint: NSLayoutConstraint!
    let model = SaveCollectionViewModel.init(api: SavedCollectionAPI.init())
    var collection : SavedCollectionModel!
    var isEdit : Bool = false
    var newCoverImage:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: isEdit ? Strings.NavigationTitles.editCollection.localized : Strings.NavigationTitles.createCollection.localized)
        /*
         Bug Name:- While creating a new collection, delete button and manage text is being displayed
         Fix Date:- 08/06/21
         Fix By  :- Jayaram G
         Description of Fix:- Hiding delete options in create collection
         */
        self.deleteOptionView.isHidden = isEdit ? false : true
        self.setLocalisation()
        let doneBtn = isEdit ? UIBarButtonItem.init(title: "Save".localized, style: .plain, target: self, action: #selector(saveCollection_Tapped)) : UIBarButtonItem.init(title: "Next".localized, style: .plain, target: self, action: #selector(saveCollection_Tapped))
        doneBtn.tintColor = .label
        navigationItem.rightBarButtonItem = doneBtn
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.tintColor = .label
        tfCollectionName.delegate = self
        vwCollectionDetailsHeightConstraint.constant = isEdit ? 140 : 0
        self.manageLabel.font = Utility.Font.Regular.ofSize(13)
        self.descriptionLabel.font = Utility.Font.Regular.ofSize(13)
        self.deleteBtn.titleLabel?.font = Utility.Font.SemiBold.ofSize(16)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if isEdit{
            tfCollectionName.text = collection.collectionName
            navigationItem.rightBarButtonItem?.isEnabled = true
            imgCollectionCover.setImageOn(imageUrl: collection.coverImage, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tfCollectionName.becomeFirstResponder()
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
    func setLocalisation(){
        self.tfCollectionName.placeholder = "Collection name".localized
        self.btnChangeCover.setTitle("Change Cover".localized, for: .normal)
        self.nameLbl.text = "Name".localized
        self.manageLabel.text = "Manage".localized
        self.deleteBtn.setTitle("Delete Collection".localized, for: .normal)
        self.descriptionLabel.text = "When you delete this collection".localized + ", " + "the photos and videos will be stored in all posts collection".localized + "."
    }
    @objc func saveCollection_Tapped(){
        if isEdit{
            if newCoverImage != nil {
                uploadCoverImage { (success) in
                    if success {
                        DispatchQueue.main.async {
                            self.updatingCoverImage()
                        }
                        
                    }else{
                        self.imgCollectionCover.setImageOn(imageUrl: self.collection.coverImage, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
                    }
                }
            }else{
                DispatchQueue.main.async {
                    self.updatingCoverImage()
                }
            }
        }else{
            let bookMarkedPostsVC : BookMarkedPostsViewController = self.storyboard?.instantiateViewController(withIdentifier: "BookMarkedPostsViewController") as! BookMarkedPostsViewController
            bookMarkedPostsVC.strCollectionName = tfCollectionName.text!
            self.navigationController?.pushViewController(bookMarkedPostsVC, animated: true)
        }
    }
    
    func updatingCoverImage() {
        model.editCollection(collection!.coverImage, collectionName: tfCollectionName.text!, collectionId: collection.id)
        model.didUpdateDict = { response in
            if let savedVc = self.navigationController?.viewControllers.filter({$0.isKind(of: SavedCollectionsViewController.self)}).first as? SavedCollectionsViewController  {
                self.navigationController?.popToViewController(savedVc, animated: true)
            }else if let profilevc = self.navigationController?.viewControllers.filter({$0.isKind(of: ProfileViewController.self)}).first as? ProfileViewController  {
                self.navigationController?.popToViewController(profilevc, animated: true)
            }else{
                self.navigationController?.popViewController(animated: true)
            }
        }
        model.didError = { error in
            
        }
    }
    
    
    func uploadCoverImage(complitation: @escaping(Bool)->Void) {
        Helper.showPI(_message: Strings.uploading.localized)
        let cloudinary = CloudinaryManager.sharedInstance
        cloudinary.uploadImage(image: self.newCoverImage!, folder: .other) {(result, error) in
            if let url = result?.url{
                self.collection!.coverImage = url
                complitation(true)
            }else{
                complitation(false)
            }
            Helper.hidePI()
        }
    }
    
    @IBAction func btnChangeCover_Tapped(_ sender: Any) {
        let sheet = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        let bookMarkedPosts = UIAlertAction.init(title: "Add from bookmarks".localized, style: .default) { (action) in
            let bookMarkedPostsVC : BookMarkedPostsViewController = self.storyboard?.instantiateViewController(withIdentifier: "BookMarkedPostsViewController") as! BookMarkedPostsViewController
            bookMarkedPostsVC.strCollectionName = self.tfCollectionName.text!
            bookMarkedPostsVC.toChangeCoverImage = true
            bookMarkedPostsVC.collection = self.collection
            self.navigationController?.pushViewController(bookMarkedPostsVC, animated: true)
        }
        
        sheet.addAction(UIAlertAction(title: Strings.takePhoto.localized, style: .default, handler: { (action) in
            self.openCamera()
        }))
        sheet.addAction(UIAlertAction(title: Strings.choosePhoto.localized, style: .default, handler: { (action) in
            self.openGallery()
        }))
        sheet.addAction(UIAlertAction(title: Strings.cancel.localized, style: .cancel, handler: { (action) in
            sheet.dismiss(animated: true, completion: nil)
        }))
        sheet.addAction(bookMarkedPosts)
        self.present(sheet, animated: true, completion: nil)
        
    }
    
    
    /// To open camera
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePickerObj = UIImagePickerController()
            imagePickerObj.delegate = self
            imagePickerObj.sourceType = UIImagePickerController.SourceType.camera;
            imagePickerObj.allowsEditing = false
            imagePickerObj.navigationBar.tintColor = UIColor.black
            self.present(imagePickerObj, animated: true, completion: nil)
        } else {
            self.showAlert(Strings.alert.localized, message: Strings.yourDeviceNotSupportCamera.localized)
        }
    }
    
    
    /// To open Gallery
    func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            let imagePickerObj = UIImagePickerController()
            imagePickerObj.delegate = self
            imagePickerObj.sourceType = UIImagePickerController.SourceType.photoLibrary;
            imagePickerObj.allowsEditing = false
            imagePickerObj.navigationBar.tintColor = UIColor.black
            self.present(imagePickerObj, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func btnDelete_Tapped(_ sender: Any) {
        
        /*
         Bug Name:- should ask to delete collection
         Fix Date:- 30/03/21
         Fix By  :- Nikunj C
         Discription of Fix:- add alert for ask to delete collection
         */
        
        let alert = UIAlertController(title: "Warning".localized, message: "Are you sure you want to".localized + " " + "delete this collection".localized + "?", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes".localized, style: .default) { (act) in
            self.model.deleteCollection(self.collection.id)
        }
        let cancel = UIAlertAction(title: "No".localized, style: .cancel, handler: nil)
        
        self.model.didUpdateDict = { response in
            UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.bookMarkUpdate)
            if let profilevc = self.navigationController?.viewControllers.filter({$0.isKind(of: ProfileViewController.self)}).first as? ProfileViewController  {
                self.navigationController?.popToViewController(profilevc, animated: true)
            }else{
                self.navigationController?.popViewController(animated: true)
            }
            
        }
        self.model.didError = { error in
            
        }
        alert.addAction(yes)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var txtAfterUpdate : String = ""
        if let text = textField.text as NSString? {
            txtAfterUpdate = text.replacingCharacters(in: range, with: string)
        }
        navigationItem.rightBarButtonItem?.isEnabled = txtAfterUpdate.count > 0
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
extension AddNewCollectionViewController: UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard var image = info[.originalImage] as? UIImage else {return}
        if  picker.sourceType == .camera {
            if picker.cameraDevice == .front {
            image = UIImage.init(cgImage: image.cgImage!, scale: image.scale, orientation: .leftMirrored)
            }
        }
        let reSizedImage = image.resizeImageUsingVImage(size: CGSize(width: 100, height: 100))

        DispatchQueue.main.async {
            self.newCoverImage = reSizedImage
            self.imgCollectionCover.image = reSizedImage
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.imgCollectionCover.image = reSizedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
