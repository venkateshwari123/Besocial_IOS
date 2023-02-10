//
//  CompleteIdentificationViewController.swift
//  PicoAdda
//
//  Created by A.SENTHILMURUGAN on 1/3/1399 AP.
//  Copyright © 1399 Rahul Sharma. All rights reserved.
//

import UIKit
import RxSwift
import Kingfisher


//tableview cell for drop down menu
class DropDownTableViewCell: UITableViewCell {
    
}


class CompleteIdentificationViewController: UIViewController,UINavigationControllerDelegate {
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var verifyButton: UIButton!
    
    let disposeBag = DisposeBag()
    var activeTextField = UITextField()
    let transparentView = UIView()
    let dropDownTableView = UITableView()
    var frames : CGRect?
    var doc = ""
    var frontPickedImage = #imageLiteral(resourceName: "noun_Image_2536623")
    var backPickedImage = #imageLiteral(resourceName: "noun_Image_2536623")
    var tag = 0
    var frontUrl = ""
    var backUrl = ""
    var documentNumber = ""
    var documentHolderName = ""
    var document = ""
    var ifscCode = ""
    var accountNumber = ""
    var accountHolderName = ""
    var kycDocumentViewModel : KycDocumentViewModel = KycDocumentViewModel()
    var arrOfDocInfo = [IdentificationInfoTableViewCell]()
    var arrOfImage = [completeIdentificationTableViewCell]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        dropDownTableView.delegate = self
        dropDownTableView.dataSource = self
        verifyButton.layer.cornerRadius = 5
        
        verifyButton.setTitle("Verify".localized, for: .normal)
        self.navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: "KYC".localized)
        self.tableView.tableFooterView = UIView()
        dropDownTableView.register(DropDownTableViewCell.self, forCellReuseIdentifier: "dropDownTableViewCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(didSelectDropDownButton(n:)), name: NSNotification.Name("didRecieveIndexPath"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didPickFrontImage(n:)), name: NSNotification.Name("didPickFrontImage"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didPickBackImage(n:)), name: NSNotification.Name("didPickBackImage"), object: nil)
        
        kycDocumentViewModel.getDocumentList { (success, error) in
            if success{
                print("document list uploaded")
                self.tableView.reloadData()
            }else{
                print(error)
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: NSNotification.Name(rawValue: "keyboardWillShow"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: NSNotification.Name("keyboardWillHide"), object: nil)
        
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
        
    }
    
    /// Make the view visible
    /// - Parameter n: n:Notification
    @objc func didSelectDropDownButton(n:Notification) {
        if let selectedItem = n.object as? String {
            print(selectedItem)
            doc = selectedItem
            self.tableView.reloadData()
        }
        
    }
    
    @objc func didPickFrontImage(n: Notification) {
        if let selectedItem = n.object as? UIImage {
            frontPickedImage = selectedItem
            tableView.reloadData()
            
            
        }
    }
    
    @objc func didPickBackImage(n: Notification) {
        if let selectedItem = n.object as? UIImage {
            backPickedImage = selectedItem
            tableView.reloadData()
            
        }
        
    }
    
    
    
    @IBAction func verifyButtonPressed(_ sender: UIButton) {
        if kycDocumentViewModel.validateDoc(documentName: getDocCell(index: 0).typeContentTF.text!, documentNumber: getDocCell(index: 1).typeContentTF.text!, documentHolderName: getDocCell(index: 2).typeContentTF.text!){
            return
        }else if kycDocumentViewModel.validatePic(documentFrontImage: frontPickedImage, documentBackImage: backPickedImage) {
            return
        }else {
            self.uploadingFrontImage(imageUrl: self.frontPickedImage)
 }
    }
    
    /// to hide the keyboard
    /// - Parameter notification: checks if the textfield is done editing
    @objc func keyBoardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        tableView.contentInset = contentInsets
        tableView.scrollIndicatorInsets = contentInsets
    }
    //func to show the keyboard
    @objc func keyBoardWillShow(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            if let keyBoardSize = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyBoardSize.height, right: 0)
                tableView.contentInset = contentInset
                tableView.scrollIndicatorInsets = contentInset
                //Scroll upto visible rect
                var visisbleRect = self.view.frame
                visisbleRect.size.height -= keyBoardSize.height
                if !visisbleRect.contains((activeTextField.center)) {
                    tableView.scrollRectToVisible(visisbleRect, animated: true)
                }
            }
        }
    }
    
    func getImageCell(index : Int) -> completeIdentificationTableViewCell {
        
        guard let cell = tableView.cellForRow(at: IndexPath.init(row: index, section: 1)) as? completeIdentificationTableViewCell else {return completeIdentificationTableViewCell()}
        return cell
        
    }
    
    func getDocCell(index: Int) -> IdentificationInfoTableViewCell {
        guard let cell = tableView.cellForRow(at: IndexPath.init(row: index, section: 0)) as? IdentificationInfoTableViewCell else {return IdentificationInfoTableViewCell()}
             return cell
      
    }
    
    func uploadingFrontImage(imageUrl: UIImage) {
        Helper.showPI()
        
        CloudinaryManager.sharedInstance.uploadImage(image: imageUrl, folder: .kyc) { (result, error) in
            if let result = result {
                self.frontUrl = result.url ?? ""
              DispatchQueue.main.async {
              self.uplaodBackImage(imageUrl: self.backPickedImage)
              }
            }
        }
    }
    
    
    func uplaodBackImage(imageUrl: UIImage) {
        
        CloudinaryManager.sharedInstance.uploadImage(image: imageUrl, folder: .kyc) { (result, error) in
            if let result = result {
                self.backUrl = result.url ?? ""
              DispatchQueue.main.async {
                self.verifyiApiCall()
              }
            }
        }
    }
        
        func verifyiApiCall() {
            kycDocumentViewModel.verifyKyc(documentName: getDocCell(index: 0).typeContentTF.text!, documentNumber: getDocCell(index: 1).typeContentTF.text!, documentHolderName: getDocCell(index: 2).typeContentTF.text!, ifscCode: self.ifscCode, accountNumber: self.accountNumber, accountHolderName: self.accountHolderName, documentFrontImage: frontUrl, documentBackImage: backUrl)
                       kycDocumentViewModel.didGetResponse.subscribe(onNext: { (success) in
                           print(self.frontUrl)
                           print(self.backUrl)
                           print("data posted")
                           if success {
                               let storyBoard = UIStoryboard(name: AppConstants.StoryBoardIds.WalletKyc, bundle: nil)
                               guard let resultViewController = storyBoard.instantiateViewController(withIdentifier: "WalletactivatedViewController") as? WalletActivatedViewController else {return}
                            resultViewController.delegate = self
                            resultViewController.modalPresentationStyle = .fullScreen
                               self.present(resultViewController, animated: true)
                            
                           }
                       }, onError: { (error) in
                           print(error)
                       }, onCompleted: nil, onDisposed: nil)
                           .disposed(by: disposeBag)
                   }
        }



extension CompleteIdentificationViewController : WalletActivatedViewControllerDelegate, SelectDocumentTypeDelegate {
    func didDeleteImage(tag: Int) {
        if tag == 1 {
            frontUrl = ""
            frontPickedImage = #imageLiteral(resourceName: "noun_Image_2536623")
        }else if tag == 2 {
            backUrl = ""
            backPickedImage = #imageLiteral(resourceName: "noun_Image_2536623")
        }
    }
    
  
    //to add a view to for document drop down button
    func addTransparentView(frames : CGRect) {
           let window = UIApplication.shared.keyWindow
           transparentView.frame = window?.frame ?? self.view.frame
           self.view.addSubview(transparentView)
        self.frames = frames
        var topY = 100.0
        if Utility.getDeviceHasSafeAreaStatus() {
            topY = 150.0
        }
           transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        dropDownTableView.frame = CGRect(x: frames.origin.x, y: CGFloat(topY) , width: frames.width, height: 0)
        self.view.addSubview(dropDownTableView)
        dropDownTableView.layer.cornerRadius = 5
        
        
           let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
           transparentView.addGestureRecognizer(tapGesture)
           transparentView.alpha = 0
           UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
               self.transparentView.alpha = 0.5
            self.dropDownTableView.frame = CGRect(x: frames.origin.x, y: CGFloat(topY), width: frames.width + 20, height: CGFloat(self.kycDocumentViewModel.getDocumentCount() * 50))
           }, completion: nil)
       }
     //to remove the document drop down view
    @objc func removeTransparentView() {
        
           UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
               self.transparentView.alpha = 0.0
            guard let newFrame = self.frames else {return}
            self.dropDownTableView.frame = CGRect(x: newFrame.origin.x, y: newFrame.origin.y + newFrame.height, width: newFrame.width, height: 0 )
                  }, completion: nil)
       }
    //func to select image to upload in the image view
    func selectImage(tag : Int) {
           
            self.tag = tag
           //Create the AlertController and add Its action like button in Actionsheet
        let actionSheetController: UIAlertController = UIAlertController(title: "Please".localized + " " + "Select".localized + " " + "Image".localized as String?,
                                                                            message: "",
                                                                            preferredStyle: .actionSheet)
           
           let cancelActionButton: UIAlertAction = UIAlertAction(title: "Cancel".localized as String?,
                                                                 style: .cancel) { action -> Void in
           }
           actionSheetController.addAction(cancelActionButton)
           
           
           
           let saveActionButton: UIAlertAction = UIAlertAction(title: "Gallery".localized as String?,
                                                               style: .default) { action -> Void in
                                                                   self.chooseFromPhotoGallery()
           }
           actionSheetController.addAction(saveActionButton)
           
           let deleteActionButton: UIAlertAction = UIAlertAction(title: "Camera".localized as String?,
                                                                 style: .default) { action -> Void in
                                                                   self.chooseFromCamera()
           }
           actionSheetController.addAction(deleteActionButton)
          
           
           self.present(actionSheetController, animated: true, completion: nil)
       }
       //to choose image from the gallery
       func chooseFromPhotoGallery()
         {
           if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
                 
                 let imagePickerObj = UIImagePickerController()
               imagePickerObj.delegate = self
               imagePickerObj.sourceType = UIImagePickerController.SourceType.photoLibrary;
                 imagePickerObj.allowsEditing = true
                 imagePickerObj.modalPresentationStyle = .fullScreen
                 self.present(imagePickerObj, animated: true, completion: nil)
             }
         }
       //to click image through the camera
       func chooseFromCamera()
          {
           if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)
              {
                  let imagePickerObj = UIImagePickerController()
               imagePickerObj.delegate = self
               imagePickerObj.sourceType = UIImagePickerController.SourceType.camera;
                  
                  imagePickerObj.allowsEditing = true
                  self.present(imagePickerObj, animated: true, completion: nil)
              }
              else
              {
                  noCamera()
              }
          }
       
       
      func noCamera(){
           let alertVC = UIAlertController(
               title: "No Camera".localized,
            message: "Sorry".localized + ", " + "this device has no camera".localized,
               preferredStyle: .alert)
           let okAction = UIAlertAction(
               title: "OK".localized,
               style:.default,
               handler: nil)
           alertVC.addAction(okAction)
           present(
               alertVC,
               animated: true,
               completion: nil)
       }
       

}

extension CompleteIdentificationViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
        if tableView == self.tableView {
        return 3
        } else {
            return kycDocumentViewModel.getDocumentCount()
        }
        }else {
            return 1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
             if tableView == self.tableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "IdentificationInfo", for: indexPath) as? IdentificationInfoTableViewCell else {return UITableViewCell()}
            cell.delegate = self
            cell.setDataInCell(index: indexPath.row)
                if indexPath.row == 0 {
                if doc == "" {
                    cell.typeContentTF.text = ""
                } else {
                    cell.typeContentTF.text = doc
                }
                }
            return cell
            } else {
                 guard let cell = tableView.dequeueReusableCell(withIdentifier: "dropDownTableViewCell", for: indexPath) as? DropDownTableViewCell else {return UITableViewCell()}
                cell.textLabel?.text = kycDocumentViewModel.getDocumentList(index: indexPath.row)
                return cell
            }
            
        } else if indexPath.section == 1 {
            if tableView == self.tableView {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CompleteIdentificationCell", for: indexPath) as? completeIdentificationTableViewCell else {return UITableViewCell()}
            cell.delegate = self
                if frontPickedImage == #imageLiteral(resourceName: "noun_Image_2536623")  {
                    cell.frontImageView.image = #imageLiteral(resourceName: "noun_Image_2536623")
                }else {
                    cell.frontImageView.image = frontPickedImage
                   
                }
                if backPickedImage == #imageLiteral(resourceName: "noun_Image_2536623")  {
                    cell.backImageView.image = #imageLiteral(resourceName: "noun_Image_2536623")
                } else {
                    cell.backImageView.image = backPickedImage
                    
                }
            return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
        if tableView == self.tableView {
            return 80
        } else {
            return 50
        }
        } else if indexPath.section == 1{
            if tableView == self.tableView{
                return tableView.frame.size.height / 2
            }
        }
        return CGFloat()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == dropDownTableView {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didRecieveIndexPath"), object: kycDocumentViewModel.getDocumentList(index: indexPath.row))
            removeTransparentView()

        }
    }
    
}

extension CompleteIdentificationViewController : UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        if tag == 1 {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didPickFrontImage"), object: image)
        } else if tag == 2 {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didPickBackImage"), object: image)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}


extension CompleteIdentificationViewController:NavigateDelegate{
    func donePressed() {
        if let dashBoardVC = self.navigationController?.viewControllers.filter({$0.isKind(of: ProfileViewController.self)}).first as? ProfileViewController{
            self.navigationController?.popToViewController(dashBoardVC, animated: true)
        }
        if let dashBoardVC = self.navigationController?.viewControllers.filter({$0.isKind(of: SocialViewController.self)}).first as? SocialViewController{
            dashBoardVC.navigationController?.navigationBar.layer.zPosition = 0
            self.navigationController?.popToViewController(dashBoardVC, animated: true)
        }
    }
}
