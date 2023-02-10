//
//  CallHistoryTVCSearchExtension.swift
//  Starchat
//
//  Created by 3Embed Software Tech Pvt Ltd on 08/04/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import Foundation

extension CallHistoryTableViewController : UISearchBarDelegate{
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchPeopleName(name: searchBar.text)
        self.isSearchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        self.isSearchActive = false
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        self.isSearchActive = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBarOutlet.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchPeopleName(name: searchText)
        self.tableView.reloadData()
    }
    
    func searchPeopleName(name: String?){
        guard let text = name else{
            self.searchArr = callLogArr
            return
        }
        if text == ""{
            self.searchArr = callLogArr
        }else{
            self.searchArr.removeAll()
            let predicate = NSPredicate(format: "userName contains[c] %@", text.lowercased())
            self.searchArr = self.callLogArr.filter({predicate.evaluate(with: $0)})
        }
    }
}
