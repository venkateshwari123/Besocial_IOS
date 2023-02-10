//
//  CountryPickerVC.swift
//  Shoppd
//
//  Created by Rahul Sharma on 30/09/19.
//  Copyright © 2019 Nabeel Gulzar. All rights reserved.
//

import UIKit

protocol CountryDataDelegate:class {
    func countryData(countryName:String,phoneCode:String,countryCode:String,countryFlag:UIImage)
}

class CountryPickerVC: UIViewController {
    @IBOutlet weak var selectCountryLabel: UILabel!
    @IBOutlet weak var countryPickerSearchBar: UISearchBar!
    @IBOutlet weak var searchBarBGView: UIView!
    @IBOutlet weak var searchBarTableView: UITableView!
    var backButtonActionClosure:(()->Void)?
    var currentCountryCode:String?
    var selectedIndexPath:IndexPath?
    weak var countryDataDelegate:CountryDataDelegate?
    var searchCountriesData:[CountryPicker] = []
    override func loadView() {
        super.loadView()
        initialSetUp()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.endEditing(true)
        countryPickerSearchBar.textField?.becomeFirstResponder()
        if #available(iOS 13.0, *) {
            countryPickerSearchBar.searchTextField.becomeFirstResponder()
        } else {
            // Fallback on earlier versions
            countryPickerSearchBar.textField?.becomeFirstResponder()
        }
        searchBarTableView.register(CountryPickerTVC.nib, forCellReuseIdentifier: CountryPickerTVC.reuseIdentifier)
            CountryPickerVM.getCountry(completeion: { [weak self] finish in
                if finish{
                    self?.searchCountriesData = CountryPickerVM.countries
                    DispatchQueue.main.async {
                        self?.searchBarTableView.reloadData()
                    }
                }
            })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObserver()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeObserver()
    }

    @IBAction func backButtonAction(_ sender: Any) {
        dismissVC()
    }
    
    func dismissVC(){
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    override func keyboardDidShow(_ notification: Notification) {
        guard let keyboardFrame = notification.keyboardFrame else{return}
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height + 25, right: 0)
        searchBarTableView.contentInset = insets
            UIView.animate(withDuration: 0.25) {
                let insets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
                self.searchBarTableView.scrollIndicatorInsets = insets
            }
    }
    
    override func keyboardWillHide(_ notification: Notification) {
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        searchBarTableView.contentInset = insets
        UIView.animate(withDuration: 0.25) {
            self.searchBarTableView.scrollIndicatorInsets = insets
        }
    }
}
