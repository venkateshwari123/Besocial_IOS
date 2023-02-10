//
//  SearchLocationVCSearchBarMethodsExt.swift
//  LiveM
//
//  Created by Rahul Sharma on 20/11/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import Foundation
import GooglePlaces
import GoogleMaps

extension SearchLocationViewController:UISearchBarDelegate {
    
    //MARK: - Autocomplete SearchBar methods -
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        autoCompleteTimer.invalidate()
        searchAutocompleteLocations()
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let searchWordProtection: String = searchBar.text!.replacingOccurrences(of: " ", with: "")
        
        if searchWordProtection.count > 0 {
            runScript()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        searchString = searchBar.text
        searchString = searchString.replacingOccurrences(of: " ", with: "+")
        searchString = (searchString as NSString).replacingCharacters(in: range, with: text)
        if searchString.hasPrefix("+") && searchString.count > 1 {
            searchString = (searchString as NSString?)?.substring(from: 1)
        }
        return true
    }
    
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    
    //MARK: - Search Methods -
    
    /// Method to maintain some interval between each search
    func runScript() {
        
        autoCompleteTimer.invalidate()
        autoCompleteTimer = Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(self.searchAutocompleteLocations), userInfo: nil, repeats: false)
        
    }
    
    
    /// Intermediate method to check the search word is already having some suggestions (previous search word or not)
    @objc func searchAutocompleteLocations() {
        
        let containtsBoolValue:Bool = arrayOfPastSearchWords.contains(where: { ($0 as! String) == searchString })
        
        if !containtsBoolValue {
            
            arrayOfCurrentSearchResult.removeAll()
            tableView.reloadData()
            arrayOfPastSearchWords.append(searchString)
            
            autoComplete(usingGMS:searchString, withCompletion: {(_ results: [Any]) -> Void in
                
                if results.count > 0 {
                    
                    self.arrayOfCurrentSearchResult += results
                    
                    let searchResult: [String: Any] = [
                        "keyword": self.searchString,
                        "results": results
                    ]
                    
                    self.arrayOfPastSearchResults.append(searchResult)
                    self.tableView.reloadData()
                }
                else {
                    
                }
            })
            
            
        } else if containtsBoolValue {
            
            arrayOfCurrentSearchResult.removeAll()
            
            for pastSearchResult in arrayOfPastSearchResults {
                
                if ((pastSearchResult as! [String:Any])["keyword"] as! String) == searchString {
                    
                    arrayOfCurrentSearchResult += ((pastSearchResult as! [String:Any])["results"] as! [Any])
                    tableView.reloadData()
                }
            }
            
        } else {
            
           // loadsManageAndPreviouslySelectedAddress()
        }
    }
    
    
    
    /// Method to get Autocomplete addresses using Google Places
    ///
    /// - Parameters:
    ///   - searchWord: searh word user as entered
    ///   - complete: array list of suggestion addresses
    func autoComplete(usingGMS searchWord: String,
                      withCompletion complete: @escaping (_ result: [Any]) -> Void) {
        
        NSObject.cancelPreviousPerformRequests(withTarget: placesClient, selector: #selector(GMSPlacesClient.autocompleteQuery(_:bounds:filter:callback:)), object: self)
        
        let emptyArray = [Any]()
        
        if (searchWord.count ) > 0 {
            
            let filter = GMSAutocompleteFilter()
            filter.type =  GMSPlacesAutocompleteTypeFilter.noFilter
            
            let visibleRegion: GMSVisibleRegion = GMSVisibleRegion.init(nearLeft: CLLocationCoordinate2DMake(currentLatitude, currentLongitude), nearRight: CLLocationCoordinate2DMake(currentLatitude, currentLongitude), farLeft: CLLocationCoordinate2DMake(currentLatitude, currentLongitude), farRight: CLLocationCoordinate2DMake(currentLatitude, currentLongitude))
            
            let bounds = GMSCoordinateBounds(coordinate: visibleRegion.farLeft, coordinate: visibleRegion.nearRight)
            
            placesClient.autocompleteQuery(searchWord,
                                           bounds: bounds,
                                           filter: filter,
                                           callback: { (results, error) in
                                            
                                            if error != nil {
                                                
                                                //DDLogDebug("Search Address Autocomplete Error: \(String(describing: error?.localizedDescription))")
                                                
                                                complete(emptyArray)
                                                
                                                return
                                            }
                                            if (results?.count)! > 0 {
                                                
                                                complete(results!)
                                            }
                                            else {
                                                
                                                complete(emptyArray)
                                            }
                                            
                                            
            })
            
        } else {
            
            complete(emptyArray)
        }
    }
    
    
}
