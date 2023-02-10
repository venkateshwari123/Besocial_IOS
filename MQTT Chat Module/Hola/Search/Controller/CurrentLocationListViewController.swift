//
//  CurrentLocationListViewController.swift
//  dub.ly
//
//  Created by 3Embed Software Tech Pvt Ltd on 08/03/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps


class CurrentLocationListViewController: UIViewController {

    @IBOutlet weak var currentLocationListTableView: UITableView!
    
    var locationManager: CLLocationManager!
    
    let placesClient:GMSPlacesClient = GMSPlacesClient.shared()
    var likeHoodList: GMSPlaceLikelihoodList?
    
    struct storyboardId {
        static let postLocationViewController = "PostsLocationViewController"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        self.locationManager?.requestWhenInUseAuthorization()
        self.checkLocationPermission()
        self.navigationItem.title = "Nearby".localized

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
    
    func checkLocationPermission(){
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .restricted, .denied:
                let alert = UIAlertController.init(title: Strings.locationServicesDisabled.localized, message: Strings.reEnableLocationsMessage.localized, preferredStyle: .alert)
                let alertAction = UIAlertAction.init(title: "Ok".localized, style: .cancel, handler: nil)
                let alertSettingsAction = UIAlertAction.init(title: "Settings".localized, style: .default) { (settings) in
                    UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
                }
                alert.addAction(alertAction)
                alert.addAction(alertSettingsAction)
                self.present(alert, animated: true, completion: nil)
                break
             break
            case .authorizedAlways, .authorizedWhenInUse:
                self.nearbyPlaces()
                break
            case .notDetermined:
                break
            }
        } else {
            print("Location services are not enabled")
        }
    }
    
    func nearbyPlaces() {
        Helper.showPI()
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }

            if let placeLikelihoodList = placeLikelihoodList {
                self.likeHoodList = placeLikelihoodList
                self.currentLocationListTableView.reloadData()
            }
            Helper.hidePI()
        })
        
        
        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue))!
        placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: fields, callback: {
            (placeLikelihoodList: Array<GMSPlaceLikelihood>?, error: Error?) in
            if let error = error {
                print("An error occurred: \(error.localizedDescription)")
                return
            }
            
            if let placeLikelihoodList = placeLikelihoodList {
                print("nearby locations")
//                self.likeHoodList = placeLikelihoodList
//                self.currentLocationListTableView.reloadData()
            }
        })
    }

    
    //MARK:- Back action
    @IBAction func backButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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

extension CurrentLocationListViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let likeHoodList = likeHoodList {
            return likeHoodList.likelihoods.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NearByLocationTableViewCell") as? NearByLocationTableViewCell else{fatalError()}
        if let list = likeHoodList{
            let place = list.likelihoods[indexPath.row].place //this is a GMSPlace object
            cell.locationNameLabel.text = place.name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NearByLocationTableViewCell") as! NearByLocationTableViewCell
        let height = Helper.measureHeightLabel(label: cell.locationNameLabel, width: cell.locationNameLabel.frame.size.width)
        if height < 48{
            return 58
        }else{
            return 12 + height
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let list = likeHoodList{
            let place = list.likelihoods[indexPath.row].place //this is a GMSPlace object
            let postLocationVC = PostsLocationViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.postedBy) as PostsLocationViewController
            postLocationVC.placeName = place.name
            postLocationVC.placeId = place.placeID ?? ""
            postLocationVC.lattitude = place.coordinate.latitude
            postLocationVC.longitude = place.coordinate.longitude
            postLocationVC.isPresented = true
            let navigationController = UINavigationController(rootViewController: postLocationVC)
            self.present(navigationController, animated: true, completion: nil)
        }
    }
}

extension CurrentLocationListViewController : CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            let alert = UIAlertController.init(title: Strings.locationServicesDisabled.localized, message: Strings.reEnableLocationsMessage.localized, preferredStyle: .alert)
            let alertAction = UIAlertAction.init(title: "OK".localized, style: .cancel, handler: nil)
            alert.addAction(alertAction)
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
