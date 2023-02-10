//
//  CountryPickerUIE.swift
//  Shoppd
//
//  Created by Rahul Sharma on 30/09/19.
//  Copyright © 2019 Nabeel Gulzar. All rights reserved.
//

import UIKit

extension CountryPickerVC{
    
    func initialSetUp(){
        Fonts.setFont(selectCountryLabel, fontFamiy: .primary(.SemiBold), size: .standard(.h22), color: UIColor.setColor(lightMode: "#1d1a1a", darkMode: AppColourStr.whiteColor))
        //        countryPickerSearchBar.
        countryPickerSearchBar.setImage(UIImage(named: "ClearSearch")?.withTintColor(.systemBackground), for: .clear, state: .normal)
        countryPickerSearchBar.layer.borderWidth = 1
        countryPickerSearchBar.layer.borderColor = UIColor.setColor(lightMode: "#f9f9f9", darkMode: AppColourStr.descriptionLabel).cgColor
        countryPickerSearchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        searchBarBGView.backgroundColor = UIColor.setColor(lightMode: "#f9f9f9", darkMode: AppColourStr.descriptionLabel)
        countryPickerSearchBar.setImage(UIImage(named: "search_ecom")?.withTintColor(.systemBackground), for: .search, state: .normal)
        countryPickerSearchBar.configureSearchTextfied(color: UIColor.setColor(lightMode: "#515c6f", darkMode: AppColourStr.whiteColor), backgroundColor: .clear, fontName: Primary.Regular.rawValue, size: StandardSize.h12.rawValue, placeholdertext: "Search Countries".localized)
        countryPickerSearchBar.placeholder = "Search Countries".localized
    }
    
}

extension CountryPickerVC:UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let string = searchText.filter{$0 != " "}
        print(string)
        if !string.isEmpty{
            searchCountriesData = CountryPickerVM.countries.filter{($0.countryName?.contains(searchText))!}
        }else{
            searchCountriesData = CountryPickerVM.countries
        }
        DispatchQueue.main.async {
            self.searchBarTableView.reloadData()
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}
