//
//  BusinessAddressViewController.swift
//  Starchat
//
//  Created by Rahul Sharma on 5/24/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G
import UIKit
import MapKit
/// Passing street address and zipcode
protocol BusinessContactInfoDelegate{
    func gettingBusinessAddress(streetAddress:String, placeAddress: String, zipCode:String,lat: String,lang: String)
}
class BusinessAddressViewController: UIViewController{
    
    //MARK:- Outlets
    @IBOutlet weak var addressTableViewOutlet: UITableView!
    @IBOutlet weak var placesTableViewOutlet: UITableView!
    //  @IBOutlet weak var mapViewOutlet: MKMapView!
    
    // MARK:- Constants&Declarations
    var streetAddress:String?
    var localityAddress:String?
    var zipCode:String?
    var businessAddressVmObject = BusinessAddressViewModel()
    var businessContactInfoDelegate: BusinessContactInfoDelegate?
    var placeAddress:String?
    var searchString:String?
    var textFieldText:String?
    var cityTown = ""
    var addressLat:String?
    var addressLang:String?
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        uiDesign()
        
        // *** Hide keyboard when tapping outside ***
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        tapGesture.cancelsTouchesInView = true
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        self.placesTableViewOutlet.isHidden = true
        self.placesTableViewOutlet.tableFooterView = UIView()
        //        mapViewOutlet.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
            if let streetAddressCell = self.addressTableViewOutlet.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? BusinessAddressTextViewCell {
                streetAddressCell.businessAddressTextView.becomeFirstResponder()
            }
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
     }
    
    @objc func tapGestureHandler() {
        view.endEditing(true)
    }
    
    //MARK:- UIDesign
    func uiDesign(){
        navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: "Address")
        let doneBtn = UIBarButtonItem.init(title: Strings.done, style: .done, target: self, action: #selector(doneBtnAction))
        doneBtn.tintColor = .label
        navigationItem.rightBarButtonItem = doneBtn
        // *** Listen to keyboard show / hide ***
        //        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    
    
    
    
    //    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    //         var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "AnnotationView")
    //        if annotationView == nil {
    //            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
    //        }
    //        annotationView?.image = #imageLiteral(resourceName: "mapPinIcon")
    //        annotationView?.isDraggable = true
    //        annotationView?.canShowCallout = true
    //         return annotationView
    //    }
    
    
    
    
    
    
    /// Managing KeyBoard Hide/Show
    ///
    /// - Parameter notification: Notification
    //    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
    //        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
    //            var keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
    //            if #available(iOS 11, *) {
    //                if keyboardHeight > 0 {
    //                    keyboardHeight = keyboardHeight - view.safeAreaInsets.bottom
    //                }
    //            }
    //            let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
    //            UIView.animate(withDuration: duration!, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
    //                let frame = self.view.frame
    //                let height = UIScreen.main.bounds.height - keyboardHeight
    //                self.view.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: height)
    //            }, completion: nil)
    //            view.layoutIfNeeded()
    //        }
    //    }
    
    @objc func doneBtnAction() {
        if cityTown == nil || zipCode == nil || placeAddress == nil || cityTown == "" || zipCode == "" || placeAddress == "" {
            Helper.showAlertViewOnWindow(Strings.warning.localized, message: Strings.enterAllFields.localized)
        }else{
            guard let strtAdress = placeAddress else {return}
            guard let zipCo = zipCode else {return}
            businessContactInfoDelegate?.gettingBusinessAddress(streetAddress: strtAdress ?? "", placeAddress: self.cityTown ?? "", zipCode: zipCo, lat: self.addressLat ?? "", lang: self.addressLang ?? "")
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //    //MARK:- Button Actions
    //    @IBAction func doneBtnAction(_ sender: UIButton) {
    //        if cityTown == "nil" || zipCode == nil || placeAddress == nil || cityTown == "" || zipCode == "" || placeAddress == "" {
    //            Helper.showAlertViewOnWindow(Strings.warning.localized, message: Strings.enterAllFields.localized)
    //        }else{
    //            guard let strtAdress = placeAddress else {return}
    //            guard let zipCo = zipCode else {return}
    //            businessContactInfoDelegate?.gettingBusinessAddress(streetAddress: strtAdress ?? "", placeAddress: self.cityTown ?? "", zipCode: zipCo)
    //            self.navigationController?.popViewController(animated: true)
    //        }
    //    }
    
    @IBAction func removeAddressAction(_ sender: UIButton) {
        self.placeAddress =  ""
        self.cityTown = ""
        self.streetAddress = ""
        self.addressLat = ""
        self.addressLang = ""
        self.zipCode = ""
        //        businessContactInfoDelegate?.gettingBusinessAddress(streetAddress: "", placeAddress: "", zipCode: "")
        self.addressTableViewOutlet.reloadData()
    }
}


//MARK:- Extensions
// table view extensions
// Delegate and DataSource methods
// MARK: - UITableViewDelegate,UITableViewDataSource
extension BusinessAddressViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == addressTableViewOutlet{
            return 3
        }else{
            return self.businessAddressVmObject.placesArray.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == addressTableViewOutlet{
            if indexPath.row == 0 {
                let streetAddressCell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.businessAddressTextViewCellId, for: indexPath) as! BusinessAddressTextViewCell
                streetAddressCell.businessAddressTextView.text =  placeAddress
                
                //                if let cell:BusinessAddressTextViewCell = self.addressTableViewOutlet.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? BusinessAddressTextViewCell {
                let fixedWidth = streetAddressCell.businessAddressTextView.frame.size.width
                let newSize = streetAddressCell.businessAddressTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
                streetAddressCell.textViewHeightConstraint.constant = newSize.height
                self.view.layoutIfNeeded()
                //                }
                streetAddressCell.businessAddressTextView.tag = 1
                return streetAddressCell
            }else{
                let addressCell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.businessAddressCellId, for: indexPath) as! BusinessAddressCell
                switch indexPath.row {
                    //                case 1:
                    //                    addressCell.addressTextField.placeholder = Strings.streetAddress
                    //                    addressCell.addressTextField.tag = 1
                    //                    addressCell.addressTextField.text =  placeAddress
                //                    addressCell.addressImageView.image =  #imageLiteral(resourceName: "maps-and-flags (2)")
                case 1:
                    addressCell.addressTextField.placeholder = Strings.cityTown
                    addressCell.addressTextField.text =  self.cityTown
                    addressCell.addressTextField.tag = 2
                default:
                    addressCell.addressTextField.placeholder = Strings.zipCode
                    addressCell.addressTextField.text =  self.zipCode
                    addressCell.addressTextField.tag = 3
                }
                return addressCell
            }
        }
        
        let placesCell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.placesCellId, for: indexPath) as! PlacesCell
        
        if self.businessAddressVmObject.placesArray.count > 0 {
            let data = self.businessAddressVmObject.placesArray[indexPath.row]
            placesCell.placesLabel.text = "\(data.primarytext) \(data.secondaryText ?? "")"
        }
        
        return placesCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if   tableView == placesTableViewOutlet{
            return UITableView.automaticDimension
        }else if tableView == addressTableViewOutlet {
            if indexPath.row == 0 {
                return 75
            }else {
                return 60
            }
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == placesTableViewOutlet{
            if self.businessAddressVmObject.placesArray.count > 0 {
                let data = self.businessAddressVmObject.placesArray[indexPath.row]
                var placeId:String?
                placeId = data.placeId
                self.businessAddressVmObject.getPlaceInformation(placeId: placeId ?? "") { (gmsAddress,finished, error) in
                    if let address = self.businessAddressVmObject.placeFullAddress?.name{
                        
                        self.addressLat = "\(gmsAddress?.coordinate.latitude)"
                        self.addressLat = "\(gmsAddress?.coordinate.longitude)"
                        self.placeAddress = address
                        self.streetAddress = address
                        self.businessAddressVmObject.placeFullAddress?.addressComponents?.forEach({ (obj) in
                        
                            if obj.type == "postal_code"{
                                if let cell : BusinessAddressCell = self.addressTableViewOutlet.cellForRow(at: IndexPath.init(row: 2, section: 0)) as? BusinessAddressCell{
                                    self.zipCode = obj.name
                                    cell.addressTextField.text = self.zipCode
                                    
                                }
                            }
                            if obj.type == "locality"{
                                self.cityTown = obj.name
                            }
                            if obj.type == "administrative_area_level_1"{
                                self.cityTown = self.cityTown + ", " + obj.name
                            }
                            if obj.type == "route"{
                                self.placeAddress = self.placeAddress ?? "" + ", " + obj.name
                            }
                            if obj.type == "sublocality_level_2"{
                                self.placeAddress = self.placeAddress ?? "" + ", " + obj.name
                            }
                        })
                        
                        if let cell : BusinessAddressCell = self.addressTableViewOutlet.cellForRow(at: IndexPath.init(row: 1, section: 0)) as? BusinessAddressCell{
                            
                            self.localityAddress = self.cityTown
                            cell.addressTextField.text = self.cityTown
                            
                        }
                        
                        self.placesTableViewOutlet.isHidden = true
                        self.addressTableViewOutlet.reloadData()
                    }
                }
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension BusinessAddressViewController: UITextFieldDelegate ,GrowingTextViewDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        var index = IndexPath()
        switch textField.tag {
        case 2:
            index = IndexPath(row: textField.tag, section: 0)
            break
        default:
            index = IndexPath(row: 2, section: 0)
            guard let cell = self.addressTableViewOutlet.cellForRow(at: index) as? BusinessAddressCell else{return true}
            cell.addressTextField.resignFirstResponder()
            return true
        }
        guard let cell = self.addressTableViewOutlet.cellForRow(at: index) as? BusinessAddressCell else{return true}
        cell.addressTextField.becomeFirstResponder()
        return true
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        textView.heightConstraint?.constant = newSize.height
        self.view.layoutIfNeeded()
    }
    
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var txtAfterUpdate : String = ""
        if let text = textField.text as NSString? {
            txtAfterUpdate = text.replacingCharacters(in: range, with: string)
        }
        
        switch textField.tag {
         
        case 2:
            self.streetAddress = txtAfterUpdate
            self.cityTown = txtAfterUpdate
        case 3:
            self.zipCode = txtAfterUpdate
        default:
            break
        }
        return true
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //        var txtAfterUpdate : String = ""
        //        if let text = textView.text as NSString? {
        //            txtAfterUpdate = text.replacingCharacters(in: range, with: text)
        //        }
        
        switch textView.tag {
        case 1:
            if text == "\n" {
                //                textView.resignFirstResponder()
                guard let cell = self.addressTableViewOutlet.cellForRow(at: IndexPath(row: 1, section: 0)) as? BusinessAddressCell else{return true}
                cell.addressTextField.becomeFirstResponder()
                
                self.placesTableViewOutlet.isHidden = true
                return false
            }
            guard let textV = textView.text else{ return true}
            self.businessAddressVmObject.searchingText = textV + text
            //            if let addressTextViewCell = self.addressTableViewOutlet.cellForRow(at: IndexPath(row: 0, section: 0)) as? BusinessAddressTextViewCell{
            //                addressTextViewCell.businessAddressTextView.text = textView.text + text
            //            }
            self.placeAddress = textV + text
            if self.businessAddressVmObject.searchingText?.count == 1  {
                placesTableViewOutlet.isHidden = true
                self.businessAddressVmObject.placesArray = []
                self.placesTableViewOutlet.reloadData()
            }else{
                self.businessAddressVmObject.checkLocationPermissions { (success) in
                    if success {
                        if self.businessAddressVmObject.placesArray == [] {
                            self.placesTableViewOutlet.isHidden = true
                        }else {
                            self.placesTableViewOutlet.isHidden = false
                            self.placesTableViewOutlet.reloadData()
                        }
                        
                    }
                }
            }
            return true
        default:
            return true
        }
    }
}


// Tap Gesture extension
extension BusinessAddressViewController: UIGestureRecognizerDelegate{
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool{
        guard let _ = touch.view?.isKind(of: PlacesCell.self) else{
            return true
        }
        return false
    }
}




//MARK:- Map Kit Code

//    var locationManager = CLLocationManager()
//    var regionInMeters:Double = 10000


//func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//    let mapLatitude = mapView.centerCoordinate.latitude
//    let mapLongitude = mapView.centerCoordinate.longitude
//    getAddressFromLatLon(pdblLatitude: "\(mapLatitude)", withLongitude: "\(mapLongitude)")
//}

//extension BusinessAddressViewController: CLLocationManagerDelegate {
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else {return}
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
//           mapViewOutlet.setRegion(region, animated: true)
//         locationManager.stopUpdatingLocation()
//    }
//
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//
//    }

//
//    func checkLocationServices(){
//        if CLLocationManager.locationServicesEnabled() {
//            setUpLocationManager()
//            checkLocationAuthorization()
//        }else {
//
//        }
//    }
//
//    func setUpLocationManager() {
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//    }
//
//
//    func checkLocationAuthorization(){
//        switch CLLocationManager.authorizationStatus() {
//        case .authorizedWhenInUse:
//            mapViewOutlet.showsUserLocation = true
//            centreViewOnUserLocation()
//            locationManager.startUpdatingLocation()
//            break
//        case .denied:
//            break
//        case .notDetermined:
//            locationManager.requestWhenInUseAuthorization()
//            break
//        case .restricted:
//            break
//        case .authorizedAlways:
//            break
//        default:
//            break
//        }
//    }
//
//
//
//    func centreViewOnUserLocation(){
//        if let location = locationManager.location?.coordinate {
//            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
//            mapViewOutlet.setRegion(region, animated: true)
//        }
//    }
//
//
//    func getAddressFromLatLon(pdblLatitude: String, withLongitude pdblLongitude: String) {
//        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
//        let lat: Double = Double("\(pdblLatitude)")!
//        //21.228124
//        let lon: Double = Double("\(pdblLongitude)")!
//        //72.833770
//        let ceo: CLGeocoder = CLGeocoder()
//        center.latitude = lat
//        center.longitude = lon
//
//        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
//
//       ceo.reverseGeocodeLocation(loc, completionHandler:
//            {(placemarks, error) in
//                if (error != nil)
//                {
//                    print("reverse geodcode fail: \(error!.localizedDescription)")
//                    Helper.showAlertViewOnWindow(Strings.error, message: "reverse geodcode fail: \(error!.localizedDescription)")
//                }
//                if let placemarksObj = placemarks {
//                    if placemarksObj.count > 0 {
//                        let pm = placemarksObj[0]
//                        print(pm.country)
//                        print(pm.locality)
//                        print(pm.subLocality)
//                        print(pm.thoroughfare)
//                        print(pm.postalCode)
//                        print(pm.subThoroughfare)
//                        var addressString : String = ""
//
//                        if pm.subThoroughfare != nil {
//                            self.placeAddress =   pm.subThoroughfare! + ", "
//                        }
//                        if pm.thoroughfare != nil {
//                            self.placeAddress = self.placeAddress! + pm.thoroughfare! + ", "
//                        }
//
//                        if pm.subLocality != nil {
//                            self.placeAddress = self.placeAddress! + pm.subLocality! + ", "
//                        }
//                        if pm.locality != nil {
//                            self.cityTown =  pm.locality! + ", "
//                         }
//                        if pm.country != nil {
//                            self.cityTown = self.cityTown + pm.country! + ", "
//                        }
//                        if pm.postalCode != nil {
//                            self.zipCode =  pm.postalCode! + " "
//                        }
//                        print(addressString)
//                        self.addressTableViewOutlet.reloadData()
//                    }
//                }
//
//
//
//        })
//
//    }
//     checkLocationServices()
//
//@IBAction func myLocationAction(_ sender: UIButton) {
//    //  let locationManager = CLLocationManager()
//    let center = CLLocationCoordinate2D(latitude: locationManager.location?.coordinate.latitude ?? 0.0, longitude: locationManager.location?.coordinate.longitude ?? 0.0)
//    let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
//    mapViewOutlet.setRegion(region, animated: true)
//    locationManager.startUpdatingLocation()
//    
//}



