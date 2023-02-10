//
//  SearchPlacesViewControllerTableviewExtension.swift
//  Location
//
//  Created by dattaphani on 23/04/21.
//

import Foundation
import UIKit

extension SearchPlacesViewController : UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SearchAddressSection.allCases.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch SearchAddressSection.init(rawValue: section) {
        case .currentLocation:
            return 1
        case .placeResults where searchAddressVM.currentSearchAddresses.count == 0 :
            return 1
        default:
            return searchAddressVM.currentSearchAddresses.count
        }
       
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch SearchAddressSection.init(rawValue: indexPath.section) {
        case .currentLocation:
            guard let cell  = tableView.dequeueReusableCell(withIdentifier: "SearchPlacesTableViewCell", for: indexPath) as? SearchPlacesTableViewCell  else { return UITableViewCell() }
            cell.locationNameLabel.text = "Use my current location".localized
            cell.locationNameLabel.textColor = Helper.getUIColor(color: "#7059EC")
            cell.arrowIcon.isHidden = true
            cell.locationIcon.image = UIImage(named: "current_location")
            cell.locationIcon.image = cell.locationIcon.image?.withRenderingMode(.alwaysTemplate)
            cell.locationIcon.tintColor = Helper.getUIColor(color: "#7059EC")
            cell.backgroundColor = .systemBackground
            return cell
        case .placeResults where searchAddressVM.currentSearchAddresses.count == 0 :
            guard let cell  = tableView.dequeueReusableCell(withIdentifier: "SearchPlacesTableViewCell1", for: indexPath) as? SearchPlacesTableViewCell  else { return UITableViewCell() }
            cell.locationNameLabel.text = "No Results Found".localized
            cell.setPlaceHolder()
            cell.backgroundColor = .systemBackground

            return cell
        default:
            
            guard let cell  = tableView.dequeueReusableCell(withIdentifier: "SearchPlacesTableViewCell3", for: indexPath) as? SearchPlacesTableViewCell , let name = searchAddressVM.currentSearchAddresses[indexPath.row].maintext ,let subtext = searchAddressVM.currentSearchAddresses[indexPath.row].secondarytext  else { return UITableViewCell() }
            cell.locationtitleLabel.text = name
            cell.locationNameLabel.text = subtext
            cell.backgroundColor = .white

            return cell
        }
        
    }
  
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
 
        switch SearchAddressSection.init(rawValue: section) {
        case .currentLocation :
            guard let header = tableView.dequeueReusableCell(withIdentifier: "SearchPlacesTableViewCell") as? SearchPlacesTableViewCell else { return UITableViewCell() }
            header.locationNameLabel.text = "Current Location".localized
            header.setHeaderData()
            return header
            
        default:
            guard let header = tableView.dequeueReusableCell(withIdentifier: "SearchPlacesTableViewCell") as? SearchPlacesTableViewCell else { return UITableViewCell() }
            header.setHeaderData()
            header.locationNameLabel.text = "Search Results".localized
            return header
            
        }
     }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch SearchAddressSection.init(rawValue: indexPath.section) {
        case .currentLocation :
            return 0.0

        default:
            return UITableView.automaticDimension
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch SearchAddressSection.init(rawValue: section) {
        case .currentLocation :
            return 0.0

        default:
        return 45.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch SearchAddressSection.init(rawValue: indexPath.section) {
        case .currentLocation :
            LocationService.sharedInstance.startUpdatingLocation()
        case .placeResults where searchAddressVM.currentSearchAddresses.count == 0:
        break

        default:
            if let notifier = notifier {
                notifier(searchAddressVM.currentSearchAddresses[indexPath.row])
                self.dismiss(animated: true, completion: nil)
                    }
        }
    }
}
