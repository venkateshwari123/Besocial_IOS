//
//  ChatsListVCSearchExtension.swift
//  Starchat
//
//  Created by 3Embed Software Tech Pvt Ltd on 08/04/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import Foundation


extension ChatsListViewController: UISearchBarDelegate{
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let searchString = searchBar.text?.lowercased()
        self.chatListViewModel.searchPeopleNameAndMessage(searchText: searchString)
        self.isSearchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        self.isSearchActive = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBarOutlet.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchString = searchText.lowercased()
        self.chatListViewModel.searchPeopleNameAndMessage(searchText: searchString)
        if self.chatListViewModel.searchedChats.count == 0 && self.chatListViewModel.searchedMessageArray.count == 0{
            setTblOrCollectionViewBackground(tableView: tableViewOutlet, collectionView: nil, image: #imageLiteral(resourceName: "chat"), labelText: "No Results Found".localized + ".", labelWithImage: true, yPosition: self.view.center.y - 50)
        }else{
            self.tableViewOutlet.backgroundView = nil
        }
//        self.noSearchFoundLabel.isHidden = self.chatListViewModel.isNoSearchFound()
        self.tableViewOutlet.reloadData()
    }
}
