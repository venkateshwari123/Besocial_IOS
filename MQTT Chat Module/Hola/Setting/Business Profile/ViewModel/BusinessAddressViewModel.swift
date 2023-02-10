//
//  BusinessAddressViewModel.swift
//  Starchat
//
//  Created by Rahul Sharma on 31/05/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G
import Foundation
import GooglePlaces
import GooglePlacePicker
import GoogleMaps
class BusinessAddressViewModel: NSObject {
    
    //MARK:- Variables&Declarations
    let placesClient:GMSPlacesClient = GMSPlacesClient.shared()
    var likeHoodList: GMSPlaceLikelihoodList?
    var placesArray = [PlacesModel]()
    var currentLatitude = 0.0
    var currentLongitude = 0.0
    var searchingText:String?
    var placeFullAddress:GMSPlace?
    var locationManager = CLLocationManager()
    
    
    /// Checking Location permissions
    ///
    /// - Parameter complitation: complitation handler after compliting service call
    func checkLocationPermissions(complitation: @escaping(Bool)->Void){
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .restricted, .denied:
                Helper.showAlertViewOnWindow(Strings.locationServicesDisabled.localized, message: Strings.reEnableLocationsMessage.localized)
                break
            case .authorizedAlways, .authorizedWhenInUse:
                //                self.getNearByPlaces { (success) in
                //                     complitation(true)
                //                }
                
                self.getBusinessLocationSearch(search: searchingText) { (success, error) in
                    if success {
                        print("success")
                        complitation(true)
                    }else {
                        print(error?.localizedDescription)
                    }
                }
                if let lattitude = (locationManager.location?.coordinate.latitude) {
                     currentLatitude = lattitude
                }
                if let longitude = (locationManager.location?.coordinate.longitude) {
                    currentLongitude = longitude
                }
            case .notDetermined:
                break
            }
        } else {
            print("Location services are not enabled")
        }
    }
    
    /// For Searching Locations
    ///
    /// - Parameters:
    ///   - search: Searching string (User entered String)
    ///   - finished: complitation handler after compliting service call
    func getBusinessLocationSearch(search: String?, finished: @escaping(Bool, Error?)->Void){
        guard let searchString = search else{return}
        if searchString.count <= 0{
            return
        }
        let filter = GMSAutocompleteFilter()
        filter.type =  GMSPlacesAutocompleteTypeFilter.noFilter
        
        let visibleRegion: GMSVisibleRegion = GMSVisibleRegion.init(nearLeft: CLLocationCoordinate2DMake(currentLatitude, currentLongitude), nearRight: CLLocationCoordinate2DMake(currentLatitude, currentLongitude), farLeft: CLLocationCoordinate2DMake(currentLatitude, currentLongitude), farRight: CLLocationCoordinate2DMake(currentLatitude, currentLongitude))
        
        let bounds = GMSCoordinateBounds(coordinate: visibleRegion.farLeft, coordinate: visibleRegion.nearRight)
        
        placesClient.autocompleteQuery(searchString,
                                       bounds: bounds,
                                       filter: filter,
                                       callback: { (results, error) in
//                                        self.locationArray.removeAll()
                                        if error != nil {
                                            finished(false, error)
                                        }
                                        if let results = results {
                                            self.setDataInLocationArray(result: results)
                                            //                                            self.locationArray = results
                                            finished(true, nil)
                                        }else{
                                            finished(true, nil)
                                        }
        })
    }
    
    /// To set location model array
    ///
    /// - Parameter result: result
    func setDataInLocationArray(result: [GMSAutocompletePrediction]){
        placesArray.removeAll()
        for data in result{
            let locationModel = PlacesModel(businessmodelData: data)
            self.placesArray.append(locationModel)
        }
    }
    
    
    /// To Get Particular Place Information
    ///
    /// - Parameters:
    ///   - placeId: placeId  string
    ///   - finished: complitation handler after compliting service call
    func getPlaceInformation(placeId:String,finished: @escaping(GMSPlace?,Bool, Error?)->Void) {
        
        placesClient.lookUpPlaceID(placeId) { (result, error) in
            if result != nil {
                self.placeFullAddress = result
                finished(result,true,error)
            }else{
                Helper.showAlertViewOnWindow(Strings.warning.localized, message: (error?.localizedDescription)!)
            }
        }
    }
}

