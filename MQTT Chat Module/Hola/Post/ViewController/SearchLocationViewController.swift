//
//  SearchLocationViewController.swift
//  LiveM
//
//  Created by Raghavendra V on 28/08/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import Foundation
import GooglePlaces
import GooglePlacePicker
//import Locksmith
//import RxSwift
//import RxCocoa
//import RxAlamofire
//import Alamofire
//import CocoaLumberjack

protocol SearchAddressDelegate {
    /// Search Address Delegate method this will when user selected any address
    ///
    /// - Parameter addressDetails: selected address information
    func searchAddressDelegateMethod(_ addressModel:AddressModel)
}


class SearchLocationViewController:UIViewController {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var addressSearchBar: UISearchBar!
    @IBOutlet weak var navigationBackButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var poweredByGoogleImageView: UIImageView!
    
    var delegate:SearchAddressDelegate? = nil
    var previouslySelectedAddress:[Any] = []
    var managedAddress:[Any] = []
    let placesClient:GMSPlacesClient = GMSPlacesClient.shared()
    var arrayOfPastSearchWords:[Any] = []
    var arrayOfPastSearchResults:[Any] = []
    var arrayOfCurrentSearchResult:[Any] = []
    var likeHoodList: GMSPlaceLikelihoodList?
    var autoCompleteTimer:Timer = Timer()
    var searchString:String!
    var selectedIndexPathToDeleteAddress:IndexPath!
    var currentLatitude = 0.0
    var currentLongitude = 0.0
    var locationManager: CLLocationManager!
    
    var apiTag:Int!
    var selectedAddressIdToDelete = ""
    var percentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition!
    var panGestureRecognizer: UIPanGestureRecognizer!
    var barTint = UIColor.black
    
//    let disposebag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentLatitude = 13.028694
        currentLongitude = 77.589561
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        self.locationManager?.requestWhenInUseAuthorization()
        self.checkLocationPermission()
        self.navigationItem.title = "Select Location".localized
        addressSearchBar.placeholder = "Search".localized + " " + "Location".localized
        self.navigationController?.navigationBar.barTintColor = .black
//        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func checkLocationPermission(){
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .restricted, .denied:
//                let alert = UIAlertController.init(title: Strings.locationServicesDisabled.localized, message: Strings.reEnableLocationsMessage.localized, preferredStyle: .alert)
//                let alertAction = UIAlertAction.init(title: "Ok".localized, style: .cancel, handler: nil)
//                alert.addAction(alertAction)
//                self.present(alert, animated: true, completion: nil)
                break
            case .authorizedAlways, .authorizedWhenInUse:
                self.getNearByPlaces()
                currentLatitude = (locationManager.location?.coordinate.latitude) ?? 0.0
                currentLongitude = (locationManager.location?.coordinate.longitude) ?? 0.0
                break
            case .notDetermined:
                break
            }
        } else {
            print("Location services are not enabled")
        }
    }
    
    func getNearByPlaces() {
//        https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=13.028694,77.589561&radius=5000&key=AIzaSyCIArI-OqI0rFvcxynEu5G-ifoNHFFzZRM
        Helper.showPI()
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }

            if let placeLikelihoodList = placeLikelihoodList {
                print(placeLikelihoodList)
                Helper.hidePI()
                self.likeHoodList = placeLikelihoodList
                self.tableView.reloadData()
            }
        })
        

//        self.newtworkRequestAPIcall()
        
        
    }
    
    
//    func newtworkRequestAPIcall (){
//
////        let strURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=13.028694,77.589561&radius=5000&key=AIzaSyCIArI-OqI0rFvcxynEu5G-ifoNHFFzZRM"
//        let strURL = "https://api.foursquare.com/v2/venues/search?client_id=OOZHXARNKFGUATVDGV2A3QMY5IWZPBCOMYH3PV1GYVH0LN5Y&client_secret=SAZX0KD50HLQ2RSIPXR0UQLNVWOEBJTI2YSSD2H0SD4SKVOX&v=20130815&ll=\(currentLatitude),\(currentLongitude)&query=%20"
//        let params = [String : Any]()
////        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
////        guard  let token = keyDict["token"] as? String  else {return}
////        let headers = ["authorization":token,"lang": "en"]
//
//        let url = URL(string: strURL)!
//        RxAlamofire
//            .requestJSON(.get, url ,parameters:params,encoding: JSONEncoding.default)
//            .debug()
//            .subscribe(onNext: { (r, json) in
//                if  var dict  = json as? [String:Any]{
//                    var statuscode:Int = r.statusCode
//                    if dict["code"] != nil{ statuscode = (dict["code"] as? Int)!}
//                    print(dict["response"])
//                }else{
//                    let statuscode:Int = r.statusCode
//                    print(json)
//                }
//            }, onError: {  (error) in
//
//                if error.localizedDescription != AppConstants.noInternetMsg {
//                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
//                }
//            }).addDisposableTo(disposebag)
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.addressSearchBar.becomeFirstResponder()
        self.navigationController?.navigationBar.barTintColor = UIColor.black
    }

    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
    } 
    
    override func viewWillDisappear(_ animated: Bool) {
        self.addressSearchBar.resignFirstResponder()
    }
 
    @IBAction func navigationBackButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}



extension SearchLocationViewController {
    
    func getPlaceInformation(placeId:String) {
        
        placesClient.lookUpPlaceID(placeId) { (result, error) in
            
            if self.delegate != nil {
                
                if error != nil {
                    
                   // DDLogDebug("Place Details error : \(String(describing: error?.localizedDescription))");
                    return;
                    
                } else if result != nil {
                    
                    self.addSelectedAddressIntoCouchDB(selectedAddressDetails: AddressModel.forSearchAddress(addressDetails: result!))
                    
                } else {
                    
                   // DDLogDebug("No place details for PleaceId: \(placeId)")
                    return;
                }
                
            }
        }
    }
    
    func addSelectedAddressIntoCouchDB(selectedAddressDetails:[String:Any]) {
        
        //For Current Search Selected Address
        let addressModel:AddressModel = AddressModel.init(addressDetails: selectedAddressDetails)
        
        if previouslySelectedAddress.count > 0 {
            
            //Checking this Address Details Already Exist in Database
            
            passTheSelectedAddressToDelegate(addressModel: addressModel)
            
        } else {
            
            //Adding The Address Details To Database
            previouslySelectedAddress.append(selectedAddressDetails)
            
            //AddressCouchDBManager.sharedInstance.updateSearchAddressDetailsToCouchDBDocument(searchAddressArray: previouslySelectedAddress)
            
            passTheSelectedAddressToDelegate(addressModel: addressModel)
        }
        
    }
}

extension SearchLocationViewController : CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            let alert = UIAlertController.init(title: Strings.locationServicesDisabled.localized, message: Strings.reEnableLocationsMessage.localized, preferredStyle: .alert)
            let alertAction = UIAlertAction.init(title: "Ok".localized, style: .cancel, handler: nil)
            let alertSettingsAction = UIAlertAction.init(title: "Settings", style: .default) { (settings) in
                UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
            }
            alert.addAction(alertAction)
            alert.addAction(alertSettingsAction)
            self.present(alert, animated: true, completion: nil)
            break
        case .authorizedAlways, .authorizedWhenInUse:
            self.checkLocationPermission()
            break
        case .notDetermined:
            break
        }
    }
}
