//
//  AddAddress.swift
//  AddAddress
//
//  Created by Rahul Sharma on 15/04/21.
//

import Foundation

enum AddAddressFields : Int , CaseIterable,Codable{
    case name
    case phonenumber
    case addressLine
    case houseNumber
    case city
    case state
    case country
    case postcode
    case landmark
    case addressType
    var placeholder : String{
        switch self {
        case .name:
            return "Name*"
        case .phonenumber:
            return "Phone*"
        case .addressLine:
            return "Address Line"
        case .houseNumber :
            return "House no. / Flat no. / Building name*"
        case .city:
            return "City*"
        case .state:
            return "State*"
        case .country:
            return "Country*"
        case .postcode:
            return "Post Code*"
        case .landmark:
            return "Landmark"
        case .addressType:
            return "AddressType"
        }
    }
    
    static func getAddAddressFields() -> [AddAddressFields] {
        return [.name,.phonenumber,.addressLine,.houseNumber,.city,.state,.postcode,.landmark,.addressType]
    }
    
}
enum SearchAddressType : Int , CaseIterable {
    case fromsearch
    case fromMap
    
}

enum AddressTypes : Int , CaseIterable {
    case Home
    case Work
    case Other
    
}
enum SearchAddressSection : Int , CaseIterable {
    case currentLocation
    case placeResults
    
}


