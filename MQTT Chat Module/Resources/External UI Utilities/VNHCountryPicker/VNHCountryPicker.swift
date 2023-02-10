//
//  VNHCountryPicker.swift
//  Trustpals
//
//  Created by Rahul Sharma on 02/12/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

import UIKit

protocol VNHCountryPickerDelegate:class {
    func didPickedCountry(country: VNHCounty, flag: UIImage)
}

/// Country Class
class VNHCounty: NSObject {
    
    let dialCode: String
    let code: String
    let name: String
//    let flag: UIImage
    
    init(dialCode: String, code: String, name: String/*, flag: UIImage*/) {
        self.dialCode = dialCode
        self.code = code
        self.name = name
//        self.flag = flag
    }
    
    override init() {
        self.dialCode = ""
        self.code = ""
        self.name = ""
//        self.flag = UIImage()
    }
}

class VNHCountryPicker: UIViewController {
    
    open weak var delegate: VNHCountryPickerDelegate?
    
    @IBOutlet weak var CPSearchBar: UISearchBar!
    @IBOutlet weak var CPTableView: UITableView!
    
    var arrayOfCountry: [VNHCounty] = []
    var arrayOfSearch = [VNHCounty]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.CPTableView.delegate = self
        self.CPTableView.dataSource = self
        self.CPSearchBar.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        arrayOfCountry = getCountry()
        self.CPTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonActn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /// Get County Code
    ///
    /// - Returns: Returns Array
    fileprivate func getCountry() -> [VNHCounty] {
        
        let path = Bundle.main.path(forResource: "CallingCodes", ofType: "plist")
        let array = NSArray(contentsOfFile: path!) as! [[String: String]]
        
        let temp: NSMutableArray = []
        for dict in array {
            temp.add(VNHCounty(dialCode: dict["dial_code"]!,
                               code: dict["code"]!,
                               name: dict["name"]!))
//                               flag: countryImage(code: dict["code"]!)))
        }
        return temp as Array as! [VNHCounty]
    }
    
    /// Country Flag Based on country code
    ///
    /// - Parameter code: country code
    /// - Returns: Flag Image
    fileprivate func countryImage(code: String) -> UIImage {
        let bundle = "assets.bundle/"
        return UIImage(named: bundle + code.lowercased() + ".png") ?? UIImage()
    }
    
    
    /// Get Counrty DialCode Based on Country code
    ///
    /// - Parameter code: Country Code
    /// - Returns: Dial Code Ex +91, +1
    class func dialCode(code: String) -> VNHCounty {
        
        let path = Bundle.main.path(forResource: "CallingCodes", ofType: "plist")
        let array = NSArray(contentsOfFile: path!) as! [[String: String]]
        
        // Populate the results
        for dict: [String: String] in array {
            
            // Check for Dial Code
            if code == dict["code"] {
                let bundle = "assets.bundle/"
//                let flag = UIImage(named: bundle + code.lowercased() + ".png")!
                
                // Return All the object
                return VNHCounty(dialCode: dict["dial_code"]!,
                                 code: dict["code"]!,
                                 name: dict["name"]!)
//                                 flag: flag)
            }
        }
        return VNHCounty()
    }
    
    class func getCountryImage(code: String) ->UIImage{
        let path = Bundle.main.path(forResource: "CallingCodes", ofType: "plist")
        let array = NSArray(contentsOfFile: path!) as! [[String: String]]
        // Populate the results
        for dict: [String: String] in array {
            
            // Check for Dial Code
            if code == dict["code"] {
                let bundle = "assets.bundle/"
                let flag = UIImage(named: bundle + code.lowercased() + ".png")!
                return flag
            }else if code == dict["dial_code"] {
                let bundle = "assets.bundle/"
                let flag = UIImage(named: bundle + dict["code"]!.lowercased() + ".png")!
                return flag
            }
        }
        return UIImage()
    }
}

extension VNHCountryPicker: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - UItableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Check Array has Search result
        if arrayOfSearch.count != 0 {
            return arrayOfSearch.count
        }
        return arrayOfCountry.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: VNHCountryPickerCell = tableView.dequeueReusableCell(withIdentifier: "VNHCountryPickerCell", for: indexPath) as! VNHCountryPickerCell
        
        // If Array has Search result
        // Load cell with Search results
        var country: VNHCounty? = nil
        if arrayOfSearch.count != 0 {
            country = arrayOfSearch[indexPath.row]
        }
        else {
            // Else all the Countries
            country = arrayOfCountry[indexPath.row]
        }
        // Update UI
//        cell.countryImage.image = country?.flag
        cell.countryImage.image = countryImage(code: country!.code)
        cell.countryName.text = String(format: "%@",(country?.name)!)
        cell.countryCode.text = String(format: "%@",(country?.dialCode)!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    //MARK: - UItableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        
        // If Array has Search result
        // Get selected data from Search results
        var country: VNHCounty? = nil
        if arrayOfSearch.count != 0 {
            country = arrayOfSearch[indexPath.row]
        }
        else {
            // Else Get selected data from All Countries results
            country = arrayOfCountry[indexPath.row]
        }
        delegate?.didPickedCountry(country: country!, flag:countryImage(code: country!.code))
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }
}

extension VNHCountryPicker: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContent(searchBar.text!)
    }
    
    
    /// Filter Content
    ///
    /// - Parameter searchText: Search String
    fileprivate func filterContent(_ searchText: String) {
        
        arrayOfSearch.removeAll()
        // Populate the results
        for country: VNHCounty in arrayOfCountry {
            
            let countryName = country.name.lowercased()
            if (countryName.range(of: searchText.lowercased()) != nil) {
                arrayOfSearch.append(country)
            }
        }
        self.CPTableView.reloadData()
    }
}
