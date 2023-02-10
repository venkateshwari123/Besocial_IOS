//
//  ExploerStarPagesVCExtension.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 27/04/20.
//  Copyright © 2020 Rahul Sharma. All rights reserved.
//

import Foundation
extension ExploreStarPagesViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchStarUsersViewModelObj.peopleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        if isSearchingStarPages {
        guard let starUsersCell = tableView.dequeueReusableCell(withIdentifier:  AppConstants.CellIds.ExploreStarPagesCellId) as? ExploreStarPagesCell else{fatalError()}
        starUsersCell.delegate = self
        starUsersCell.verifiedImageView.isHidden = false
        starUsersCell.setPeopleData(modelData: self.searchStarUsersViewModelObj.peopleArray[indexPath.row])
        return starUsersCell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let profileVC = ProfileViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Profile) as ProfileViewController
        profileVC.isNotFromTabBar = true
        let data = self.searchStarUsersViewModelObj.peopleArray[indexPath.row]
        profileVC.memberId = data.peopleId
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
}
extension ExploreStarPagesViewController: UITextFieldDelegate,ExploreStarUsersCellDelegate {
    
    func followingButtonAction(cell: ExploreStarPagesCell) {
        guard let indexPath = self.usersTableView.indexPath(for: cell) else{ return }
        let modelArray = self.searchStarUsersViewModelObj.peopleArray
        if modelArray.count > indexPath.row{
            let modelData = modelArray[indexPath.row]
            updatePeopleModelArray(modelData: modelData, index: indexPath)
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshHomeScreen"), object: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var txtAfterUpdate : String = ""
        if let text = textField.text as NSString? {
            txtAfterUpdate = text.replacingCharacters(in: range, with: string)
        }
        self.getStarUsersList(searchtext: txtAfterUpdate)
        return true
    }
}
