//
//  FollowViewControllerSearchExtension.swift
//  Starchat
//
//  Created by 3Embed Software Tech Pvt Ltd on 07/06/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//
import Foundation
extension DublyFollowViewController: UISearchBarDelegate{
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //        self.chatListViewModel.searchPeopleName(name: searchBar.text)
        //        self.followViewModel.offset = -40
        //        self.searchText = searchBar.text
        //        self.followServiceCall(searchString: searchBar.text)
        self.isSearchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.isSearchActive = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.followSearchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //        self.chatListViewModel.searchPeopleName(name: searchText)
        self.followViewModel.offset = -40
        self.searchText = searchBar.text ?? ""
        if (searchBar.text?.count)! >= 3 || (searchBar.text?.count)! == 0 {
            self.followServiceCall(searchBar.text)
            self.followTableView.reloadData()
        }
    }
}


