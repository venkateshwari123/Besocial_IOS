//
//  SearchPlacesViewController.swift
//  AddAddress
//
//  Created by Rahul Sharma on 15/04/21.
//

import UIKit
class SearchPlacesViewController: UIViewController {
    @IBOutlet weak var headView: UIView!
    @IBOutlet weak var placesTableView: UITableView!
    @IBOutlet weak var searchAddressField: UISearchBar!
    @IBOutlet weak var emptyPlaceHolder: UIView!
    @IBOutlet weak var separator: UIView!
    
    @IBOutlet weak var emptyText: UILabel!
    typealias selectedplace = (Places) -> ()
    var notifier: selectedplace?
    var searchAddressVM = SearchAddressViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        LocationService.sharedInstance.delegate = self
        setUI()
    }
    func setUI()
    {
        searchAddressField.configureSearchTextfied(color: Helper.getUIColor(color: "#242A4B"), backgroundColor: Helper.getUIColor(color: "#F5F4F4"))
        self.searchAddressField.tintColor = .darkGray
        searchAddressField.setImage(UIImage(named: "search_ecom"), for: .search, state: .normal)
        searchAddressField.setImage(UIImage(named: "address_clear"), for: .clear, state: .normal)
        searchAddressField?.textField?.attributedPlaceholder = NSAttributedString(string: "Search Address", attributes: [NSAttributedString.Key.font:UIFont(name: "Poppins-Regular", size: 12.0) ?? UIFont.boldSystemFont(ofSize: 14.0),NSAttributedString.Key.foregroundColor:Helper.getUIColor(color: "#BCBFD1")])
        headView.updateConstraints()
        headView.layoutIfNeeded()
        Helper.addShadowToCustomView(view: headView, radius: 5, opacity: 0.9, color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.06))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated:Bool)
    {
        super.viewWillAppear(animated)
        self.searchBarSearchButtonClicked(searchAddressField)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    @IBAction func backButtonAction(){
        if let notifier = notifier {
            notifier(Places(name: "", placeId: "", latlong: ""))
            self.dismiss(animated: true, completion: nil)
        }
    }
}

