//
//  SearchLocationVCTableViewMethodsExt.swift
//  LiveM
//
//  Created by Rahul Sharma on 20/11/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import Foundation
import GoogleMaps
import GooglePlaces


extension SearchLocationViewController:UITableViewDataSource,UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
//        if addressSearchBar.text?.count == 0 {
//
//            return 2
//        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if addressSearchBar.text?.count == 0 {
            
            if let likeHoodList = likeHoodList {
                return likeHoodList.likelihoods.count
            }
            return 0
            
//            switch section {
//
//            case 0:
//                return managedAddress.count
//
//            default:
//                return previouslySelectedAddress.count
//
//            }
            
        }
        
        return arrayOfCurrentSearchResult.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let searchAddressCell:SearchLocationTableViewCell = tableView.dequeueReusableCell(withIdentifier:"searchLocationCell") as! SearchLocationTableViewCell
        
        searchAddressCell.removeAddressButton.tag = indexPath.row
        
//        var height1:CGFloat
//        var height2:CGFloat
        
        if(addressSearchBar.text?.count == 0){
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NearByLocationTableViewCell") as? NearByLocationTableViewCell else{fatalError()}
            if let list = likeHoodList{
                let place = list.likelihoods[indexPath.row].place //this is a GMSPlace object
                cell.locationNameLabel.text = place.name
            }
            return cell
            
        }
//        {
//            if(indexPath.section == 0)
//            {
//                //For Managed Address Cell
//                let addressModel:AddressModel = AddressModel.init(manageAddressDetails: managedAddress[indexPath.row])
//
//                if addressModel.tagAddress.count > 0 {
//
//                    searchAddressCell.addressLabel1?.text = "\(addressModel.tagAddress)"
//                }
//                else{
//
//                    searchAddressCell.addressLabel1?.text = ""
//                }
//
//                if addressModel.addressLine1.count > 0 {
//
//                    searchAddressCell.addressLabel2?.text = "\(addressModel.addressLine1)"
//                    height2 = Helper.measureHeightLabel(label: searchAddressCell.addressLabel2, width: self.view.frame.size.width - 97)
//
//                }
//                else
//                {
//                    searchAddressCell.addressLabel2?.text = ""
//                    height2 = 0
//                }
//
//
//            }
//            else//For Previously Selected Address Cell
//            {
//                let addressModel:AddressModel = AddressModel.init(addressDetails: previouslySelectedAddress[indexPath.row])
//
//                searchAddressCell.addressLabel1?.text = addressModel.addressLine1
//                searchAddressCell.addressLabel2?.text = addressModel.addressLine2
//
//                height2 = Helper.measureHeightLabel(label: searchAddressCell.addressLabel2, width: self.view.frame.size.width - 97)
//            }
//
//            searchAddressCell.removeAddressButton.isHidden = false
//            searchAddressCell.removeAddressButtonWidthConstraint.constant = 30
//
//            height1 = Helper.measureHeightLabel(label: searchAddressCell.addressLabel1, width: self.view.frame.size.width - 97)
//
//            searchAddressCell.addressLabel1HeightConstraint.constant = height1 + 4
//
//           // searchAddressCell.addressImageButton.setImage(#imageLiteral(resourceName: "checked_icon"), for: UIControlState.normal)
//
//        }
        else//For Currently Searched Address Cell
        {
            var height1:CGFloat
            let searchResult:GMSAutocompletePrediction = arrayOfCurrentSearchResult[indexPath.row] as! GMSAutocompletePrediction
            searchAddressCell.addressLabel1?.text = searchResult.attributedPrimaryText.string
            searchAddressCell.addressLabel2?.text = searchResult.attributedSecondaryText?.string
            
            searchAddressCell.removeAddressButton.isHidden = true
            searchAddressCell.removeAddressButtonWidthConstraint.constant = 0
            
            height1 =  Helper.measureHeightLabel(label: searchAddressCell.addressLabel1, width: self.view.frame.size.width - 67)
            
            searchAddressCell.addressLabel1HeightConstraint.constant = height1 + 4
            
//            height2 = Helper.measureHeightLabel(label: searchAddressCell.addressLabel2, width: self.view.frame.size.width - 67)
            
          //  searchAddressCell.addressImageButton.setImage(#imageLiteral(resourceName: "7"), for: UIControlState.normal)
            
        }
        
        
        
//        Helper.setShadowFor(searchAddressCell.topView, andWidth:self.view.frame.size.width-20, andHeight:height1 + height2 + 30 - 10)
        
        return searchAddressCell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let searchAddressCell:SearchLocationTableViewCell = tableView.dequeueReusableCell(withIdentifier:"searchLocationCell") as! SearchLocationTableViewCell
        
//        var height1:CGFloat
//        var height2:CGFloat
        
        if(addressSearchBar.text?.count == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "NearByLocationTableViewCell") as! NearByLocationTableViewCell
            let height = Helper.measureHeightLabel(label: cell.locationNameLabel, width: cell.locationNameLabel.frame.size.width)
            if height < 48{
                return 58
            }else{
                return 12 + height
            }
        }
//        {
//            //For Managed Address Cell
//            if(indexPath.section == 0)
//            {
//                //For Managed Address Cell
//                let addressModel:AddressModel = AddressModel.init(manageAddressDetails: managedAddress[indexPath.row])
//
//                if addressModel.tagAddress.count > 0 {
//
//                    searchAddressCell.addressLabel1?.text = "\(addressModel.tagAddress)"
//                }
//                else{
//
//                    searchAddressCell.addressLabel1?.text = ""
//                }
//
//                height1 = Helper.measureHeightLabel(label: searchAddressCell.addressLabel1, width: self.view.frame.size.width - 97)
//
//                if addressModel.addressLine1.count > 0 {
//
//                    searchAddressCell.addressLabel2?.text = "\(addressModel.addressLine1)"
//
//                    height2 = Helper.measureHeightLabel(label: searchAddressCell.addressLabel2, width: self.view.frame.size.width - 97)
//                }
//                else
//                {
//                    searchAddressCell.addressLabel2?.text = ""
//                    height2 = 0
//                }
//
//            }
//            else//For Previously Selected Address Cell
//            {
//                let addressModel:AddressModel = AddressModel.init(addressDetails: previouslySelectedAddress[indexPath.row])
//
//                searchAddressCell.addressLabel1?.text = addressModel.addressLine1
//                searchAddressCell.addressLabel2?.text = addressModel.addressLine2
//
//                height1 = Helper.measureHeightLabel(label: searchAddressCell.addressLabel1, width: self.view.frame.size.width - 97)
//                height2 = Helper.measureHeightLabel(label: searchAddressCell.addressLabel2, width: self.view.frame.size.width - 97)
//            }
//
//        }
        else//For Currently Searched Address Cell
        {
            var height1:CGFloat
            var height2:CGFloat
            let searchResult:GMSAutocompletePrediction = arrayOfCurrentSearchResult[indexPath.row] as! GMSAutocompletePrediction
            searchAddressCell.addressLabel1?.text = searchResult.attributedPrimaryText.string
            searchAddressCell.addressLabel2?.text = searchResult.attributedSecondaryText?.string
            
            height1 = Helper.measureHeightLabel(label: searchAddressCell.addressLabel1, width: self.view.frame.size.width - 67)
            height2 = Helper.measureHeightLabel(label: searchAddressCell.addressLabel2, width: self.view.frame.size.width - 67)
            searchAddressCell.layoutIfNeeded()
            
            return height1+height2 + 30
        }
        
//        searchAddressCell.layoutIfNeeded()
//
//        return height1+height2 + 30
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.view.endEditing(true)
        
        if addressSearchBar.text?.count == 0 && indexPath.section == 0 {
            
//            let addressModel:AddressModel = AddressModel.init(manageAddressDetails: managedAddress[indexPath.row])
//
//            //For Managed Address
//            passTheSelectedAddressToDelegate(addressModel: addressModel)
            if let list = likeHoodList{
                let placeID = list.likelihoods[indexPath.row].place.placeID //this is a GMSPlace object
                
                getPlaceInformation(placeId: placeID ?? "")
            }
        }
        else
        {
            var placeID :String!
            
            if addressSearchBar.text?.count == 0 && indexPath.section == 1 {
                
                //For Previously Selected Address
                let addressModel:AddressModel = AddressModel.init(addressDetails: previouslySelectedAddress[indexPath.row])
                
                passTheSelectedAddressToDelegate(addressModel: addressModel)
            }
            else
            {
                //For New Search Address
                let searchResult:GMSAutocompletePrediction = arrayOfCurrentSearchResult[indexPath.row] as! GMSAutocompletePrediction
                placeID = searchResult.placeID
                
                getPlaceInformation(placeId: placeID)
                
            }
            
//            addressSearchBar.resignFirstResponder()
            
        }
        
        
    }
    
    func passTheSelectedAddressToDelegate(addressModel:AddressModel) {
        
        if  delegate != nil {
            
            delegate?.searchAddressDelegateMethod(addressModel)
        }
        
        navigationBackButtonAction(navigationBackButton)
        
    }
}
