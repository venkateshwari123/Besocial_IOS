//
//  ServiceManager.swift
//  Location
//
//  Created by dattaphani on 20/04/21.
//

import UIKit

enum JSONError: String, Error {
    case NoData = "ERROR: no data"
    case ConversionFailed = "ERROR: conversion from JSON failed"
}


class ServiceManager: NSObject {
    //https://maps.googleapis.com/maps/api/geocode/json?latlng=44.4647452,7.3553838&key=YOUR_API_KEY
  
    static let PlacesAPILink                            = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&location=%f,%f&radius=100000&amplanguage=%@&key=\(AppConstants.googleMapKey)"
    static let PlaceEnlarge                             = "https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=\(AppConstants.googleMapKey)"
    
    //  Preventing initialisation from any other source.
    private override init() {
    }
    
    //  Function to execute GET request and pass data from escaping closure
    class   func executeGetRequest(with urlString: String, completion: @escaping (Data?) -> ()) {
        
        guard let urlPath  = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let requestUrl = URL.init(string: urlPath) else{
            return
        }
        var urlRequest = URLRequest.init(url: requestUrl)
        urlRequest.httpMethod = "GET"
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            //  Log errors (if any)
            
            if let str =  error?.localizedDescription, error != nil {
                Helper.showAlert(head: "Error", message: "\(str)")
                print(error.debugDescription)
            } else {
                //  Passing the data from closure to the calling method
                completion(data)
            }
        }.resume()  // Starting the dataTask
    }
    
    //  Function to perform a task - Calls executeGetRequest(with urlString:) and receives data from the closure.
    class  func fetchLocations(from urlString: String, completion: @escaping ([Places]) -> ()) {
        //  Calling executeGetRequest(with:)
        executeGetRequest(with: urlString) { (data) in  // Data received from closure
            do {
                guard let data = data else {
                    throw JSONError.NoData
                }
                //  JSON parsing
                guard let responseDict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary else {
                    throw JSONError.ConversionFailed
                }
                if let results = responseDict["predictions"] as? [[String:Any]] {
                    var currentSearchAddresses: [Places] = []
                    ( )
                    //(name: , placeId: , latlong: "")
                    for eachAddress in results {
                        currentSearchAddresses.append(Places(name: eachAddress["description"] as? String, placeId: eachAddress["place_id"] as? String, latlong: "", latitude: 0.0, longitude: 0.0, structured_formatting: eachAddress["structured_formatting"] as? [String:Any]))
                    }
                    
                    completion(currentSearchAddresses)
                }
            } catch let error as JSONError {
                print(error.rawValue)
            } catch let error as NSError {
                print(error.debugDescription)
            }
        }
    }
    
    class    func fetchLocationwithplaceId(from urlString: String, completion: @escaping (NSDictionary) -> ()) {
        //  Calling executeGetRequest(with:)
        executeGetRequest(with: urlString) { (data) in  // Data received from closure
            do {
                //  JSON parsing
                
                guard let data = data else {
                    throw JSONError.NoData
                }
                guard let responseDict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                else {
                    return
                    
                }
                let status = responseDict["status"] as! String
                if status != "NOT_FOUND" && status != "REQUEST_DENIED" && status != "OVER_QUERY_LIMIT" {
                  
                    if let results = responseDict["result"] as? NSDictionary {
                        completion(results)
                    }
                   
                }else if status == "OVER_QUERY_LIMIT" || status == "REQUEST_DENIED" {
                    
                }else{
                }
                
                
                
            } catch let error as JSONError {
                print(error.rawValue)
            } catch let error as NSError {
                Helper.showAlert(head: "Error", message: "\(error.debugDescription)")
                print(error.debugDescription)
            }
        }
    }
}
extension UIApplication {
    
    class func topViewController(_ viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(presented)
        }
        return viewController
    }
}
