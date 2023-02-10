//
//  CreateChannelViewController.swift
//  dub.ly
//
//  Created by 3Embed Software Tech Pvt Ltd on 14/12/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import TextFieldEffects
import CocoaLumberjack
class CreateChannelViewController: UIViewController {
    
    /// Outlets
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var channelImageView: UIImageView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var privacySwitch: UISwitch!
    @IBOutlet weak var channelNameTextField: HoshiTextField!
    @IBOutlet weak var cancelBtnOutlet: UIButton!
    @IBOutlet weak var saveBtnOutlet: UIButton!
    @IBOutlet weak var channelTitleLabel: UILabel!
    
    @IBOutlet weak var categoryImageView: UIImageView!
    
    /// Variables and Declarations
    var isEditingChannel:Bool = false
    var imageUrl: String?
    var selectedCategoryListModel: CategoryListModel?
    var isFirstTime: Bool = true
    var selectedChannelModel: ProfileChannelModel?
    let createChannelViewModel = CreateChannelViewModel()
    var categoryId: String?
    var isChanged:Bool = false
    
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navView.makeShadowEffect(color: UIColor.lightGray)
        if isEditingChannel{
            self.channelTitleLabel.text = Strings.editChannel
            self.imageUrl = selectedChannelModel?.channelImageUrl
            self.channelNameTextField.text = selectedChannelModel?.channelName
            self.categoryId = selectedChannelModel?.categoryId
            self.channelImageView.setImageOn(imageUrl: selectedChannelModel?.channelImageUrl, defaultImage: #imageLiteral(resourceName: "channel_default_icon"))
            self.categoryNameLabel.text = selectedChannelModel?.categoryName
            self.categoryImageView.setImageOn(imageUrl: selectedChannelModel?.categoryUrl, defaultImage: #imageLiteral(resourceName: "voice_call_profile_default_image"))
            if selectedChannelModel?.privicy == 1 {
                self.privacySwitch.isOn = true
            }else {
                self.privacySwitch.isOn = false
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isEditingChannel {
            if isFirstTime{
                isFirstTime = false
                self.channelNameTextField.becomeFirstResponder()
                self.privacySwitch.isOn = false
            }
        }
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CreateChannelViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            self.view.layoutIfNeeded()
            //            let radious = self.channelImageView.frame.size.width / 2
            //            self.channelImageView.makeCornerRadious(readious: radious)
            self.channelImageView.layer.cornerRadius = self.channelImageView.frame.size.width / 2
            self.channelImageView.clipsToBounds = true
            self.view.layoutIfNeeded()
        }
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        self.channelNameTextField.resignFirstResponder()
    }
    
    //MARK:- Buttons Action
    
    @IBAction func changeChannelImageAction(_ sender: Any) {
        self.channelNameTextField.resignFirstResponder()
        
        let alert = UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: Strings.takePhoto, style: .default, handler: { (action) in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: Strings.choosePhoto, style: .default, handler: { (action) in
            self.openGallery()
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
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
            self.showAlert(Strings.alert, message: Strings.yourDeviceNotSupportCamera)
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
    
    @IBAction func selectCategoryButtonAction(_ sender: Any) {
        self.channelNameTextField.resignFirstResponder()
        //        self.performSegue(withIdentifier: segueIdentifier.categoryListSegue, sender: nil)
        guard let categoryListVC = self.storyboard!.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.CategoryListViewController) as? CategoryListViewController else{return}
        categoryListVC.delegate = self
        categoryListVC.selectedCategoryListModel = self.selectedCategoryListModel
        let navController = UINavigationController(rootViewController: categoryListVC)
        // Creating a navigation controller with categoryListVC at the root of the navigation stack.
        self.present(navController, animated:true, completion: nil)
    }
    
    @IBAction func privicyActionSwitchAction(_ sender: Any) {
        self.channelNameTextField.resignFirstResponder()
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        self.channelNameTextField.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        self.channelNameTextField.resignFirstResponder()
        if self.validateChannelDatas(){
            if isEditingChannel {
                self.editChannelServiceCall()
            }else {
                
                self.createChannelServiceCall()
            }
        }
        
    }
    
    //MARK:- Service call
    private func createChannelServiceCall(){
        
        let channelImageUrl = self.imageUrl != nil ? imageUrl! : ""
        let name = self.channelNameTextField.text != nil ? self.channelNameTextField.text! : ""
        let isPrivate = self.privacySwitch.isOn
        guard let categoryModel = selectedCategoryListModel else {return}
        categoryId = categoryModel.categoryId != nil ? categoryModel.categoryId! : ""
        let params = [Strings.channelNameKey : name as Any,
                      Strings.channelImageUrlKey : channelImageUrl as Any,
                      Strings.categoryIdKey : categoryId! as Any,
                      Strings.descriptionKey : name as Any,
                      Strings.privateKey : isPrivate] as [String : Any]
        self.createChannelViewModel.createChannelService(params: params) { (success, error) in
            if success{
                self.showPopUpAnddismissView()
            }else if let error = error{
                Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
            }
        }
    }
    
    //MARK:- Service call
    private func editChannelServiceCall(){
        let channelImageUrl =  self.imageUrl != nil ? imageUrl! : ""
        let name = self.channelNameTextField.text != nil ? self.channelNameTextField.text! : ""
        let isPrivate = self.privacySwitch.isOn
        if selectedCategoryListModel != nil {
            guard let categoryModel = selectedCategoryListModel else {return}
            categoryId = categoryModel.categoryId != nil ? categoryModel.categoryId! : ""
        }else{
            categoryId =  selectedChannelModel?.categoryId
        }
        
        let channelId = selectedChannelModel?.id
        let params = [Strings.channelNameKey : name as Any,
                      Strings.channelImageUrlKey : channelImageUrl as Any,
                      Strings.categoryIdKey : categoryId as Any,
                      Strings.descriptionKey : name as Any,
                      Strings.isPrivateKey : isPrivate,
                      "channelId": channelId ?? ""] as [String : Any]
        
        self.createChannelViewModel.editChannelService(channelId: channelId ?? "" , params: params) { (success, error) in
            if success{
                self.showPopUpAnddismissView()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppConstants.notificationObserverKeys.refreshProfileData), object: nil)
                Helper.hidePI()
            }else if let error = error{
                Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
            }
            Helper.hidePI()
        }
    }
    
    
    
    
    
    
    /// To show popup and dismiss view controller on success
    func showPopUpAnddismissView(){
        if isEditingChannel {
//            let alert = UIAlertController(title: Strings.success.localized, message: Strings.channelUpdatedSuccessFully.localized, preferredStyle: UIAlertController.Style.alert)
//            let okAction = UIAlertAction(title: Strings.ok.localized, style: UIAlertAction.Style.default) { (action) in
//                self.dismiss(animated: true, completion: nil)
//            }
//            alert.addAction(okAction)
//            self.present(alert, animated: true, completion: nil)
            
            /*features Name :- add toast message for create or update channel
              Fix Date :- 22/03/2021
              Fixed By :- Nikunj C
              Description Of features :- add toast message for update channel instead of alert*/
            
        }else {
//            let alert = UIAlertController(title: Strings.success.localized, message: Strings.channelCreatedSuccessFully.localized, preferredStyle: UIAlertController.Style.alert)
//            let okAction = UIAlertAction(title: Strings.ok.localized, style: UIAlertAction.Style.default) { (action) in
//                self.dismiss(animated: true, completion: nil)
//            }
//            alert.addAction(okAction)
//            self.present(alert, animated: true, completion: nil)
            
            /*features Name :- add toast message for create or update channel
              Fix Date :- 22/03/2021
              Fixed By :- Nikunj C
              Description Of features :- add toast message for create channel instead of alert*/
                }
    }
    
    private func validateChannelDatas() -> Bool{
        if (channelNameTextField.text?.count)! < 3{
//            Helper.showAlertViewOnWindow(Strings.message.localized, message: Strings.pleaseEnterChannelNameAtleastCharacters.localized)
            self.channelNameTextField.becomeFirstResponder()
            return false
        }
        if self.categoryId == nil{
            Helper.showAlertViewOnWindow(Strings.message.localized, message: Strings.pleaseSelectCategory.localized)
            return false
        }
        if self.imageUrl == nil{
            Helper.showAlertViewOnWindow(Strings.message.localized, message: Strings.pleaseSelectImage.localized)
            return false
        }
        return true
    }
    
}

extension CreateChannelViewController : UITextFieldDelegate{
    
    func textFieldDidChange(_ textField: UITextField) {
        if (textField == channelNameTextField) && ((textField.text?.count)! > 15) {
            channelNameTextField.deleteBackward()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        channelNameTextField.resignFirstResponder()
        return true
    }
}

extension CreateChannelViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var flippedImage =   info[.originalImage] as? UIImage
        guard let image = info[.originalImage] as? UIImage else {return}
        if picker.sourceType == UIImagePickerController.SourceType.camera && picker.cameraDevice == UIImagePickerController.CameraDevice.front{
            flippedImage = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation:.leftMirrored)
        }
        let reSizedImage = flippedImage!.resizeImageUsingVImage(size: CGSize(width: 100, height: 100))
        Helper.showPI(_message: Strings.uploading)
        let cloudinary = CloudinaryManager.sharedInstance
        cloudinary.uploadImage(image: reSizedImage!, folder: .post, complication: {(result, error) in
            if let url = result?.url{
                self.channelImageView.image = flippedImage
                self.imageUrl = url
            }
            Helper.hidePI()
        })
        picker.dismiss(animated: true, completion: nil)
    }
    
}
    
//    func imagePickerController(_ picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!) {
//        var flippedImage: UIImage = image
//        if picker.sourceType == UIImagePickerController.SourceType.camera && picker.cameraDevice == UIImagePickerController.CameraDevice.front{
//            flippedImage = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation:.leftMirrored)
//        }
//        Helper.showPI(_message: Strings.uploading)
//        let cloudinary = CloudinaryManager.sharedInstance
//        cloudinary.uploadImage(image: flippedImage, complication: {(url, error) in
//            if url != ""{
//                self.channelImageView.image = flippedImage
//                self.imageUrl = url
//            }
//            Helper.hidePI()
//        })
//        self.dismiss(animated: true, completion: nil)
//    }


extension CreateChannelViewController: CategoryListViewControllerDelegate{
    
    func selectedCategory(categoryListModel: CategoryListModel) {
        self.selectedCategoryListModel = categoryListModel
        self.categoryNameLabel.text = categoryListModel.categoryName!
        self.categoryImageView.setImageOn(imageUrl: categoryListModel.categoryActiveIconUrl, defaultImage: #imageLiteral(resourceName: "voice_call_profile_default_image"))
        self.categoryId = categoryListModel.categoryId!
    }
}
