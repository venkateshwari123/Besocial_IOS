//
//  LocationPickerViewModel.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 16/12/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import GooglePlacePicker
import GooglePlaces
import GoogleMaps



protocol locationPickDelegate {
    
    func didSendselectedlocation(address name:String ,location latLog:[String:Any])
    
}

class LocationPickerViewModel: NSObject {
    
    var chatObj : ChatViewController?
    var delegate:locationPickDelegate?
    
    
    init(_ chatOb : ChatViewController) {
        chatObj = chatOb
    }
    
    
    func openLocationPicker(){
        
        if CLLocationManager.locationServicesEnabled() && CLLocationManager.authorizationStatus() != .denied {
//        GMSServices.provideAPIKey(AppConstants.googleMapKey)
//        GMSPlacesClient.provideAPIKey(AppConstants.googleMapKey)
//        let confi = GMSPlacePickerConfig.init(viewport: nil)
//        let placePicker = GMSPlacePickerViewController.init(config: confi)
//        placePicker.delegate = self
////        self.chatObj?.present(placePicker, animated: true, completion: nil)
//        self.chatObj?.navigationController?.pushViewController(placePicker, animated: true)
            
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self
            
            // Specify the place data types to return.
            let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
                UInt(GMSPlaceField.placeID.rawValue))!
            autocompleteController.placeFields = fields
            
            // Specify a filter.
            let filter = GMSAutocompleteFilter()
            filter.type = .address
            autocompleteController.autocompleteFilter = filter
            
            // Display the autocomplete view controller.
            self.chatObj?.present(autocompleteController, animated: true, completion: nil)
            
            
            
        }else {
            let alert = UIAlertController.init(title: Strings.locationServicesDisabled.localized, message: Strings.reEnableLocationsMessage.localized, preferredStyle: .alert)
            let alertAction = UIAlertAction.init(title: "Ok".localized, style: .cancel, handler: nil)
            let alertSettingsAction = UIAlertAction.init(title: "Settings", style: .default) { (settings) in
                UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
            }
            alert.addAction(alertAction)
            alert.addAction(alertSettingsAction)
            chatObj?.present(alert, animated: true, completion: nil)
        }
    }
}

extension LocationPickerViewModel: GMSPlacePickerViewControllerDelegate, GMSAutocompleteViewControllerDelegate{
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        
//        chatObj?.dismiss(animated: true, completion: nil)
        chatObj?.navigationController?.popViewController(animated: true)
        let dict:[String:Any] = ["lat":"\(place.coordinate.latitude)",
                                 "log":"\(place.coordinate.longitude)"]
        delegate?.didSendselectedlocation(address: place.name ?? "", location: dict)
    }
    
    
    func placePicker(_ viewController: GMSPlacePickerViewController, didFailWithError error: Error) {
        print("error")
    }
    
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
//        chatObj?.dismiss(animated: true, completion: nil)
        chatObj?.navigationController?.popViewController(animated: true)
    }
    
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
//        print("Place name: \(place.name)")
//        print("Place ID: \(place.placeID)")
//        print("Place attributions: \(place.attributions)")
        let dict:[String:Any] = ["lat":"\(place.coordinate.latitude)",
            "log":"\(place.coordinate.longitude)"]
        delegate?.didSendselectedlocation(address: place.name ?? "", location: dict)
        self.chatObj?.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.chatObj?.dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    
}
