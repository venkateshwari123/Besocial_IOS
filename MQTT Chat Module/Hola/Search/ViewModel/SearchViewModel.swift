//
//  SearchViewModel.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 03/09/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps

/// To determine api type
///
/// - people: people api
/// - channel: channel api
/// - tag: hashtag api
enum TableType {
    case people
    case channel
    case tag
}

class SearchViewModel: NSObject {

    let socialApi = SocialAPI()
    var searchModelArray = [SocialModel]()
    var peopleOffset: Int = -40
    var channelOffset: Int = -40
    var tagOffset: Int = -40
    let limit: Int = 40
    let placesClient:GMSPlacesClient = GMSPlacesClient.shared()
    var currentLatitude = 13.028694
    var currentLongitude = 77.589561

    
    var peopleArray = [PeopleModel]()
    var channelArray = [ChannelListModel]()
    var hashTagArray = [HashTagModel]()
    var locationArray = [LocationModel]()
    var recentSearchLocationArray = [LocationModel]()
    let couchbaseObj = Couchbase.sharedInstance

//    var placeDetails = GMSPlace()
    
    override init() {
        super.init()
    }
    
    
    /// service call of people, channel and hastag
    ///
    /// - Parameters:
    ///   - url: url of api
    ///   - type: type of api
    ///   - finished: complitation handler
    func getSearchData(with url: String, type: TableType, finished: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
        Helper.showPI()
        let strURl = getStringUrl(url: url, type: type)
        
        socialApi.getSocialData(withURL: strURl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!, params: [:]) { (modelArray, customError) in
            if let modelData = modelArray as? [Any]{
                print(modelData)
                self.setDataInModel(type: type, response: modelData)
                let canServiceCall: Bool = (modelData.count == self.limit) ? true : false
                finished(true, nil, canServiceCall)
            }
            if let error = customError{
                if error.code == 204{
                    self.handleSearchResult(type: type)
                    finished(true, error, false)
                }else{
                    finished(false, error, true)
                }
            }
            DispatchQueue.main.async {
            Helper.hidePI()
            }
        }
    }
    
    
    func handleSearchResult(type: TableType){
        switch type {
        case .people:
            if peopleOffset == 0{
                peopleArray.removeAll()
            }
            break
        case .channel:
            if channelOffset == 0{
                channelArray.removeAll()
            }
            break
        case .tag:
            if tagOffset == 0{
                hashTagArray.removeAll()
            }
        }
    }
    
    /// To get string Url according to tableview type
    ///
    /// - Parameters:
    ///   - url: base url
    ///   - type: type of table view
    /// - Returns: string url
    func getStringUrl(url: String, type: TableType)-> String{
        switch type {
        case .people:
            peopleOffset = peopleOffset + limit
            return url + "offset=\(peopleOffset)&limit=\(limit)"
        case .channel:
            channelOffset = channelOffset + limit
            return url + "skip=\(channelOffset)&limit=\(limit)"
        case .tag:
            tagOffset = tagOffset + limit
            return url + "skip=\(tagOffset)&limit=\(limit)"
        }
    }
    
    /// To set data in differnet model array
    ///
    /// - Parameters:
    ///   - type: type of api
    ///   - response: response of api
    func setDataInModel(type: TableType, response: [Any]){
        
        switch type {
        case .people:
           setPeopleModel(dataArray: response)
            break
        case .channel:
           setChannelModel(dataArray: response)
            break
        case .tag:
            setTagModel(dataArray: response)
            break
        }
    }
    
    /// To set data in people model array
    ///
    /// - Parameter dataArray: data array to set
    func setPeopleModel(dataArray: [Any]){
        if peopleOffset == 0{
            self.peopleArray.removeAll()
        }
        for data in dataArray{
            guard let modelData = data as? [String : Any] else {continue}
            let model = PeopleModel(modelData: modelData)
            self.peopleArray.append(model)
        }
    }
    
    /// To set data in channle array
    ///
    /// - Parameter dataArray: data array to set
    func setChannelModel(dataArray: [Any]){
        if channelOffset == 0{
            self.channelArray.removeAll()
        }
        for data in dataArray{
            guard let modelData = data as? [String : Any] else {continue}
            let model = ChannelListModel(modelData: modelData)
            self.channelArray.append(model)
        }
    }
    
    /// To set data in hastag array
    ///
    /// - Parameter dataArray: data array to set
    func setTagModel(dataArray: [Any]){
        if tagOffset == 0{
            self.hashTagArray.removeAll()
        }
        for data in dataArray{
            guard let modelData = data as? [String : Any] else {continue}
            let model = HashTagModel(modelData: modelData)
            self.hashTagArray.append(model)
        }
    }
    
    //MARK:- Location search
    func getLocationSearch(search: String?, finished: @escaping(Bool, Error?)->Void){
        guard let searchString = search else{return}
        let filter = GMSAutocompleteFilter()
        filter.type =  GMSPlacesAutocompleteTypeFilter.noFilter
        
        let visibleRegion: GMSVisibleRegion = GMSVisibleRegion.init(nearLeft: CLLocationCoordinate2DMake(currentLatitude, currentLongitude), nearRight: CLLocationCoordinate2DMake(currentLatitude, currentLongitude), farLeft: CLLocationCoordinate2DMake(currentLatitude, currentLongitude), farRight: CLLocationCoordinate2DMake(currentLatitude, currentLongitude))
        
        let bounds = GMSCoordinateBounds(coordinate: visibleRegion.farLeft, coordinate: visibleRegion.nearRight)
        
        placesClient.autocompleteQuery(searchString,
                                       bounds: bounds,
                                       filter: filter,
                                       callback: { (results, error) in
                                        self.locationArray.removeAll()
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
        for data in result{
            let locationModel = LocationModel(modelData: data)
            self.locationArray.append(locationModel)
        }
    }
    
    /// To get place information which is get selected
    ///
    /// - Parameters:
    ///   - location: location model data
    ///   - finished: complitaion block
    func getPlaceInformation(location: LocationModel, isStored: Bool, finished: @escaping(GMSPlace?, Error?)->Void) {
        guard let id = location.placeId else{return}
        if !isStored{
            self.updateLocationDataInDatabase(location: location)
        }
        placesClient.lookUpPlaceID(id) { (result, error) in
             if let place = result{
//                print(result)
//                self.placeDetails = place
                finished(place, nil)
            } else {
                finished(nil, nil)
            }
        }
    }
    
    
    /// To get location history from database
    func getLocationDataFromDataBase(finished: @escaping()->Void){
        if let docId = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.locationDocumentId) as? String{
            let locationData = couchbaseObj.getLocationData(docId: docId)
            print(locationData)
            guard let dbData = locationData else{return}
            guard let locationArr = dbData["location"] as? [[String : Any]] else{return}
            self.makeArrayOfLocationModel(locationData: locationArr)
            finished()
        }
    }
    
    
    /// To make array location model arrya from databse data
    ///
    /// - Parameter locationData: location data from database
    func makeArrayOfLocationModel(locationData: [[String : Any]]){
        self.recentSearchLocationArray.removeAll()
        for data in locationData{
            let locationModel = LocationModel(dataBaseData: data)
            self.recentSearchLocationArray.append(locationModel)
        }
    }
    
    
    /// To update location data indatabase
    ///
    /// - Parameter location: location data
    func updateLocationDataInDatabase(location: LocationModel){
        if let docId = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.locationDocumentId) as? String{
            if self.recentSearchLocationArray.count == 10{
                self.recentSearchLocationArray.removeLast()
            }
            self.recentSearchLocationArray.insert(location, at: 0)
            let arr = self.makeArrayOflocationForDataBase(locations: self.recentSearchLocationArray)
            couchbaseObj.updateLocationData(docId: docId, location: arr)
        }else{
            let arr = self.makeArrayOflocationForDataBase(locations: [location])
            let docId = couchbaseObj.createLocationDocument(with: arr)
            UserDefaults.standard.setValue(docId, forKey: AppConstants.UserDefaults.locationDocumentId)
        }
    }
    
    
    /// To make array location data to store in database
    ///
    /// - Parameter locations: location model array
    /// - Returns: array on dict
    func makeArrayOflocationForDataBase(locations: [LocationModel]) ->[[String : Any]]{
        var locationArray = [[String : Any]]()
        for data in locations{
            var dict = [String : Any]()
            dict["primarytext"] = data.primarytext
            dict["secondaryText"] = data.secondaryText
            dict["placeId"] = data.placeId
            locationArray.append(dict)
        }
        return locationArray
    }
    
    //MARK:- follow and unfollow update database and Service call
    
    /// To update user follow status in database and server
    ///
    /// - Parameters:
    ///   - contact: contact to be updated
    ///   - isFollow: follow or unfollow
    func FollowPeopleService(isFollow: Bool, peopleId: String, privicy: Int){
    
        ContactAPI.followAndUnfollowService(with: isFollow, followingId: peopleId, privicy: privicy)
    }
    
    func subseribeChannleService(url: String, channleId: String){
//        let strUrl = url + "?channelId=\(channleId)"
        let params: [String : Any] = ["channelId" : channleId]
        socialApi.putSocialData(with: url, params: params) { (response, error) in
            if let result = response{
                print(result)
            }else if let error = error{
                print(error.localizedDescription)
            }
        }
    }
}
