//
//  SearchPlacesViewControllerLocationExtension.swift
//  Location
//
//  Created by dattaphani on 23/04/21.
//

import Foundation
import CoreLocation

extension SearchPlacesViewController: LocationServiceDelegate
{
    // MARK: LocationService Delegate
    func tracingLocation(currentLocation: CLLocation) {
        let lat = currentLocation.coordinate.latitude
        let lon = currentLocation.coordinate.longitude
        LocationService.sharedInstance.stopUpdatingLocation()
        let place = Places.init(name: "", placeId: "", latlong: "", latitude: lat, longitude: lon)
        if let notifier = notifier {
            notifier(place)
            self.dismiss(animated: true, completion: nil)
                }
    }
    
    func tracingLocationDidFailWithError(error: NSError) {
        print("tracing Location Error : \(error.description)")
    }
}
