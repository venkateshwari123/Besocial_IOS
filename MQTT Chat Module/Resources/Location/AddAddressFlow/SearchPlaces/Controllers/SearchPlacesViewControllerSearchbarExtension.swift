//
//  SearchPlacesViewControllerSearchbarExtension.swift
//  Location
//
//  Created by dattaphani on 23/04/21.
//

import Foundation
import UIKit
let DELAY_DURATION_FOR_CANCELPREVIOUS_SEARCHREQUEST = 0.8 //in milli secondss
let SEARCH_STRING_LENGTH = 3
extension SearchPlacesViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
 
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
         return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.becomeFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText.count == 0) {
            searchAddressVM.currentSearchAddresses.removeAll()
           }else
        {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(fetchPlaces), object: nil)
        self.perform(#selector(fetchPlaces), with: nil, afterDelay: DELAY_DURATION_FOR_CANCELPREVIOUS_SEARCHREQUEST)
        }
       
    }
 
    @objc func fetchPlaces(){
        guard let searchPlaceName = searchAddressField.text, searchPlaceName.count >= SEARCH_STRING_LENGTH else {
            return
        }
        let latitudeTemp = 12.97//LocationManager.shared.latitute
        let longitudeTemp = 77.59//LocationManager.shared.longitude
        let language = "en"
        let placeAPI = String(format: ServiceManager.PlacesAPILink ,searchPlaceName,latitudeTemp,longitudeTemp,language)
        ServiceManager.fetchLocations(from: placeAPI) { (searchlocs : [Places]) in
            DispatchQueue.main.async {
                self.searchAddressVM.currentSearchAddresses = searchlocs
                self.placesTableView.reloadData()
            }
        }
    }
    
     
}
