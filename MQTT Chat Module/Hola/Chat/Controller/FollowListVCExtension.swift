//
//  FollowListVCExtension.swift
//  Starchat
//
//  Created by 3Embed Software Tech Pvt Ltd on 24/07/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import Foundation


//MARK:- Collection view delegate and datasource
extension FollowListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.followListViewModel.selectedMember.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier.SelectedUserCollectionViewCell, for: indexPath) as? SelectedUserCollectionViewCell else{fatalError()}
        let data = self.followListViewModel.selectedMember[indexPath.item]
        /*
         Bug Name:- Show the intials for default profile pic
         Fix Date:- 12/05/21
         Fix By  :- Jayram G
         Description of Fix:- setting initials image when user not uploaded profile pic
         */
        Helper.addedUserImage(profilePic: data.profilePic, imageView: cell.userImageView, fullName: data.fullName)
        cell.userNameLabel.text = data.userName
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}


extension FollowListViewController: UISearchBarDelegate{
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        self.isSearchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        self.isSearchActive = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBarOutlet.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.followListViewModel.offset = 0
        self.searchText = searchBar.text
        if searchBar.text!.count > 0 {
            let arr = self.followListViewModel.followersFolloweeModelArray.filter({(($0.firstName.lowercased() ) + ($0.userName?.lowercased() ?? "")).contains(self.searchText?.lowercased() ?? "")})
            self.followListViewModel.followersFolloweeModelArray = arr
            if arr.count == 0{
                setTableViewOrCollectionViewBackground(tableView: followListTableview, collectionView: nil, image: #imageLiteral(resourceName: "chat"), labelText: "No Results Found".localized + ".", labelWithImage: true, yPosition: self.view.center.y - 150 )
            }
            self.followListTableview.reloadData()
        }else {
            self.followFolloweServiceCall(strUrl: AppConstants.followersFollowee + "?")
        }
        
//        }
    }
}
