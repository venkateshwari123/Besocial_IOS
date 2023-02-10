//
//  StripeSignUpViewController.swift
//  Yelo
//
//  Created by Rahul Sharma on 04/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

protocol  stripeSignUpVCDelegate {
    func stripeSignUpSuccess()
}

class StripeSignUpViewController: BaseViewController {
 
    @IBOutlet weak var documentIdPlaceHolderLabel: UILabel!
    @IBOutlet weak var proofIdPlaceHolderLabel: UILabel!
    @IBOutlet weak var firstNamePlaceHolderLabel: UILabel!
    @IBOutlet weak var lastNamePlaceHolderLabel: UILabel!
    @IBOutlet weak var dateOfBitrhPlaceHolderLabel: UILabel!
    @IBOutlet weak var ssnPlaceHolderLabel: UILabel!
    @IBOutlet weak var addressPlaceHolderLabel: UILabel!
    @IBOutlet weak var cityNamePlaceHolderLabel: UILabel!
    @IBOutlet weak var stateNamePlaceHolderLabel: UILabel!
    @IBOutlet weak var zipCodeNamePlaceHolderLabel: UILabel!
    @IBOutlet weak var countryNamePlaceHolderLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var documentIdTextField: UITextField!
    @IBOutlet weak var proofImageView: UIImageView!
    @IBOutlet weak var proofCancleButton: UIButton!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var dateOfBirthTextField: UITextField!
    @IBOutlet weak var ssnTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var zipCodeTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var submitButtonBottomConstraint: NSLayoutConstraint!
    
    var imagePicker = UIImagePickerController()
    let viewModel = StripeSignUpViewModel()
    var delegate: stripeSignUpVCDelegate?

    //life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
         Bug Name:- Wallet update , ip is missing
         Fix Date:- 17/06/21
         Fix By  :- Jayaram G
         Description of Fix:- Api call to get ip
         */
        Helper.fetchIpDetails()
        setUp()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deregisterFromKeyboardNotifications()
        NotificationCenter.default.removeObserver(self, name: .imageUploded, object: nil)
    }
    
    func setUp(){
        self.title = "Add Stripe Account".localized
        submitButton.setTitle("Submit".localized, for: .normal)
        proofIdPlaceHolderLabel.text = "Photo ID".localized
        firstNamePlaceHolderLabel.text = "First Name".localized
        lastNamePlaceHolderLabel.text = "Last Name".localized
        dateOfBitrhPlaceHolderLabel.text = "Date of Birth".localized
        ssnPlaceHolderLabel.text = "SSN".localized
        documentIdPlaceHolderLabel.text = "Document ID".localized
        addressPlaceHolderLabel.text = "Address".localized
        cityNamePlaceHolderLabel.text = "City".localized
        stateNamePlaceHolderLabel.text = "State".localized
        zipCodeNamePlaceHolderLabel.text = "Zipcode".localized
        countryNamePlaceHolderLabel.text = "Country".localized
        submitButton.setTitle("Submit".localized, for: .normal)
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismiss_Keyboard))
        self.view.addGestureRecognizer(tap)
        setUpTextField(tf: firstNameTextField)
        setUpTextField(tf: lastNameTextField)
        setUpTextField(tf: dateOfBirthTextField)
        setUpTextField(tf: ssnTextField)
        /*
         Bug Name:- Document id is missing in UI
         Fix Date:- 14/06/21
         Fix By  :- Jayaram G
         Description of Fix:- added document id field
         */
        setUpTextField(tf: documentIdTextField)
        setUpTextField(tf: addressTextField)
        setUpTextField(tf: cityTextField)
        setUpTextField(tf: stateTextField)
        setUpTextField(tf: zipCodeTextField)
        setUpTextField(tf: countryTextField)
        dateOfBirthTextField.addRightImage(image: "calendar_icon")
        
        setUpPlaceHolderLabel(lbl: proofIdPlaceHolderLabel)
        setUpPlaceHolderLabel(lbl: firstNamePlaceHolderLabel)
        setUpPlaceHolderLabel(lbl: lastNamePlaceHolderLabel)
        setUpPlaceHolderLabel(lbl: dateOfBitrhPlaceHolderLabel)
        setUpPlaceHolderLabel(lbl: ssnPlaceHolderLabel)
        /*
         Bug Name:- Document id is missing in UI
         Fix Date:- 14/06/21
         Fix By  :- Jayaram G
         Description of Fix:- added document id field
         */
        setUpPlaceHolderLabel(lbl: documentIdPlaceHolderLabel)
        setUpPlaceHolderLabel(lbl: addressPlaceHolderLabel)
        setUpPlaceHolderLabel(lbl: cityNamePlaceHolderLabel)
        setUpPlaceHolderLabel(lbl: stateNamePlaceHolderLabel)
        setUpPlaceHolderLabel(lbl: zipCodeNamePlaceHolderLabel)
        setUpPlaceHolderLabel(lbl: countryNamePlaceHolderLabel)
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        dateOfBirthTextField.inputView = datePicker
        datePicker.maximumDate = Date().adding(years: -18)
        datePicker.minimumDate = Date().adding(years: -100)
        dateOfBirthTextField.addDoneButtonOnKeyboard()
        /*
         Bug Name:- UI messed up for date picker
         Fix Date:- 24/05/21
         Fix By  :- Jayaram G
         Description of Fix:- added preferred date styel
         */
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        datePicker.addTarget(self, action: #selector(self.handleDatePicker(sender:)), for: .valueChanged)
        
        setNavigationLeftBarBackButton()
        submitButton.layer.cornerRadius =  submitButton.frame.height/2
        proofCancleButton.isHidden = true
    }
    
    func fetchTheAddressPlaceDetails(selectedaddress : Places){
        if let placeid = selectedaddress.placeId , placeid.count != 0
        {
            let urlString = String(format: ServiceManager.PlaceEnlarge,placeid)
            ServiceManager.fetchLocationwithplaceId(from: urlString) { placeFrom in
                if placeFrom.count > 0
                {
                    DispatchQueue.main.async {
                        self.addressTextField.text = selectedaddress.name ?? ""
                        self.viewModel.stripeSignUpModel.address = selectedaddress.name ?? ""
                    }
                        if let addressComponent = placeFrom["address_components"] as? [[String:Any]] {
                            DispatchQueue.main.async {
                                for item in addressComponent {
                                    
                                    if let types = item["types"] as? [String] {
                                        if types.contains("locality") {
                                            self.cityTextField.text = item["short_name"] as? String ?? ""
                                            self.viewModel.stripeSignUpModel.city = item["short_name"] as? String ?? ""
                                        } else if types.contains("administrative_area_level_1") {
                                            self.stateTextField.text  = item["short_name"] as? String ?? ""
                                            self.viewModel.stripeSignUpModel.state = item["short_name"] as? String ?? ""
                                        } else if types.contains("country") {
                                            self.countryTextField.text = item["short_name"] as? String ?? ""
                                            self.viewModel.stripeSignUpModel.country = item["short_name"] as? String ?? ""
                                        } else if types.contains("postal_code") {
                                            self.viewModel.stripeSignUpModel.zipCode = item["short_name"] as? String ?? ""
                                            self.zipCodeTextField.text = item["short_name"] as? String ?? ""
                                        }
                                    }
                                    
                                }
                            }
                        }
                    
                }
            }
        }
    }
    
    func setUpTextField(tf: UITextField){
        tf.delegate = self
        tf.setTheme()
    }
    
    func setUpPlaceHolderLabel(lbl: UILabel){
        lbl.font = Theme.getInstance().settingPlaceHolderStyle.getFont()
        lbl.textColor = Theme.getInstance().settingPlaceHolderStyle.getTextColor()
        lbl.addMandatoryStar()
    }
    
    @IBAction func proofImageCancelButtonAction(_ sender: Any) {
        viewModel.stripeSignUpModel.proofImage = nil
        proofImageView.image = UIImage(named: "upload_image")
        proofCancleButton.isHidden = true
    }
    
    
    @IBAction func documentInfoAction(_ sender: Any) {
        Helper.showAlert(head: "Info".localized, message: "DocumentId should be 9 characters".localized + ".")
    }
    @IBAction func ssnInfoAction(_ sender: Any) {
        Helper.showAlert(head: "Info".localized, message: "SSN should be last 4 digits of documentId".localized + ".")
    }
    
    
    @IBAction func selectProofImageAction(_ sender: Any) {
        let alert = UIAlertController(title: "Choose image".localized, message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera".localized, style: .default, handler: { _ in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Library".localized, style: .default, handler: { _ in
            self.openLibrary()
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func submitButtonAction(_ sender: Any) {
        self.view.endEditing(true)
        if viewModel.stripeSignUpModel.validate(){
           uplaodImageToCloud()
        }else{
            Helper.showAlert(head: "Oops".localized + "!", message: "Please fill mandatory fields".localized)
        }
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        dateOfBirthTextField.text = dateFormatter.string(from: sender.date)
        viewModel.stripeSignUpModel.dateOfBirth = sender.date
    }
    
}



//MARK: - image picker
extension StripeSignUpViewController: UIImagePickerControllerDelegate, UploadImageModelDelegate{
    
    // open camera
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            if imagePicker.delegate == nil{
                imagePicker.delegate = self
            }
            self.present(imagePicker, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Warning".localized, message: "You don't have camera".localized + ".", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //open photo library
    func openLibrary(){
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        if imagePicker.delegate == nil{
            imagePicker.delegate = self
        }
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.editedImage] as? UIImage {
            proofImageView.image = pickedImage
            viewModel.stripeSignUpModel.proofImage = imageOfProduct(imgUrl: "", img: pickedImage)
            proofCancleButton.isHidden = false
            imagePicker.dismiss(animated: true)
        }
    }
    
    
    
    
    ///  method used to upload images to cloud storage "cloudinary"
    func uplaodImageToCloud(){
         NotificationCenter.default.addObserver(self, selector: #selector(imageUplded(notification:)), name: .imageUploded, object: nil)
        let upMoadel = UploadImageModel() // shared instance
        var imageData = [UploadImage]()
        if let img = viewModel.stripeSignUpModel.proofImage{
            if img.imgUrl == "" {
                imageData.append(UploadImage.init(image: img.img, path: creatingFileName()))
            }
        }
        
        if imageData.count > 0 {
            upMoadel.uploadImages = imageData
            upMoadel.delegate = self
            Helper.showPI(_message: "")
            upMoadel.start()
        }else{
            print(">>>>> No Image to upload")
            NotificationCenter.default.post(name: .imageUploded, object: nil, userInfo: nil)
        }
    }
    
    /// create Image name
    func creatingFileName () -> String{
        let distanceTime = String(format: "%.0f", Date().getTimeStamp)
        return "image" + distanceTime + ".png"
    }
    
    //response from clouldinary
    func callBackWithURL(isSuccess: Bool, url: String) {
        
        if isSuccess{
            if let proofImage =  viewModel.stripeSignUpModel.proofImage, proofImage.imgUrl == "" {
                viewModel.stripeSignUpModel.proofImage?.imgUrl = url
                NotificationCenter.default.post(name: .imageUploded, object: nil, userInfo: nil)
            }
        }
    }
    
    @objc func imageUplded(notification:NSNotification){
        
        NotificationCenter.default.removeObserver(self, name: .imageUploded, object: nil)
        print("all image uploded")
        viewModel.stripeSignUp {
            self.delegate?.stripeSignUpSuccess()
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension Notification.Name{
     static let imageUploded = Notification.Name("imageUploded")
    
}


