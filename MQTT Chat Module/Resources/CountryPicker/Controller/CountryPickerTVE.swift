//
//  CountryPickerTVE.swift
//  Shoppd
//
//  Created by Rahul Sharma on 01/10/19.
//  Copyright © 2019 Nabeel Gulzar. All rights reserved.
//

import UIKit

extension CountryPickerVC:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchCountriesData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CountryPickerTVC.reuseIdentifier, for: indexPath) as? CountryPickerTVC else{return UITableViewCell()}
        cell.fromVC = .countryPicker
        cell.checkMarkImageView.image = currentCountryCode ?? "" == searchCountriesData[indexPath.row].countryCode ? UIImage(named: "radio_filled") : UIImage(named: "radio_empty")
        selectedIndexPath = currentCountryCode ?? "" == searchCountriesData[indexPath.row].countryCode ? indexPath : selectedIndexPath
        cell.updateCell(celldata: searchCountriesData[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CountryPickerTVC,selectedIndexPath != indexPath else{
            return
        }
        if let selectedindex = selectedIndexPath,let cell = tableView.cellForRow(at: selectedindex) as? CountryPickerTVC{
            cell.checkMarkImageView.image = UIImage(named: "radio_empty")
        }
        DispatchQueue.main.async {
            cell.checkMarkImageView.image = UIImage(named: "radio_filled")
        }
        countryDataDelegate?.countryData(countryName: searchCountriesData[indexPath.row].countryName!, phoneCode: searchCountriesData[indexPath.row].countryCode!, countryCode: searchCountriesData[indexPath.row].countryNameCode!, countryFlag: Helper.countryFlagImage(code: searchCountriesData[indexPath.row].countryNameCode!.lowercased()))
        backButtonActionClosure?()
        dismissVC()
    }
    
}
