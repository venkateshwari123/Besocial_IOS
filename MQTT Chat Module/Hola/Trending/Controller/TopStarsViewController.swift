//
//  TopStarsViewController.swift
//  PicoAdda
//
//  Created by 3Embed on 04/11/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class TopStarsViewController: UIViewController {
    
    
    @IBOutlet weak var searchTf: UITextField!
    @IBOutlet weak var usersTableView: UITableView!
    @IBOutlet weak var noPeopleView: UIView!
    
    
    let topStarUsersViewModelObj = TopStarsViewModel()
    var isTopMostInfluentialStars: Bool = false
    var isTopBestActors: Bool = false
    var isTopBestActresses: Bool = false
    var canPeopleServiceCall: Bool = true
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usersTableView.tableFooterView = UIView()
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "back_arrow"), style: .plain, target: self, action: #selector(dismissSelf))
        //            UIBarButtonItem.init(title: "Cancel".localized, style: .plain, target: self, action: #selector(dismissSelf))
        self.navigationController?.navigationBar.tintColor = .black
        topStarApiCall(searchText: "")
        self.navigationController?.navigationBar.isHidden = false
 
    }
    
    override func viewDidAppear(_ animated: Bool) {
        searchTf.becomeFirstResponder()
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
    @objc func dismissSelf(){
        self.navigationController?.popViewController(animated: true)
    }
    
 
    func topStarApiCall(searchText: String){
        var strUrl: String = ""
        if isTopMostInfluentialStars {
            strUrl =  AppConstants.getTrendingUsers + "?userType=Star&set=0&limit=10"
        }else if isTopBestActors {
            strUrl =  AppConstants.getTrendingUsers + "?userType=Actor&set=0&limit=50"
        }else if isTopBestActresses {
            strUrl =  AppConstants.getTrendingUsers + "?userType=Actress&set=0&limit=50"
        }
        self.topStarUsersViewModelObj.getStarsUsers(strUrl: strUrl) { (success, error) in
            if success {
                print("Success")
                self.usersTableView.reloadData()
            }else if let error = error{
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }else {
                    self.usersTableView.reloadData()
                }
                
                if error.code == 412 {
                    Helper.showAlertViewOnWindow(Strings.warning.localized, message: Strings.profileDeleted.localized)
                }
            }
        }
    }
    
    ///To update people table view according to selected or unselected follow button and put to server
    func updatePeopleModelArray(modelData: PeopleModel, index: IndexPath){
        if modelData.followStatus == 0{
            modelData.followStatus = 1
            if modelData.privicy == 1{
                modelData.followStatus = 2
            }
            //            self.searchViewModel.FollowPeopleService(url: AppConstants.follow, peopleId: modelData.peopleId!)
                 self.topStarUsersViewModelObj.FollowPeopleService(isFollow: true, peopleId: modelData.peopleId!, privicy: modelData.privicy)
             
        }else{
            modelData.followStatus = 0
            //            self.searchViewModel.FollowPeopleService(url: AppConstants.unfollow, peopleId: modelData.peopleId!)
            self.topStarUsersViewModelObj.FollowPeopleService(isFollow: false, peopleId: modelData.peopleId!, privicy: modelData.privicy)
        }
        
        self.topStarUsersViewModelObj.peopleArray[index.row] = modelData
        self.usersTableView.beginUpdates()
        self.usersTableView.reloadRows(at: [index], with: .none)
        self.usersTableView.endUpdates()
    }
    }

extension TopStarsViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.topStarUsersViewModelObj.peopleArray.count == 0 {
            self.noPeopleView.isHidden = false
        }else {
            self.noPeopleView.isHidden = true
        }
        return self.topStarUsersViewModelObj.peopleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         guard let starUsersCell = tableView.dequeueReusableCell(withIdentifier:  AppConstants.CellIds.TopStarsCellId) as? TopStarsCell else{fatalError()}
        starUsersCell.delegate = self
          starUsersCell.setPeopleData(modelData: self.topStarUsersViewModelObj.peopleArray[indexPath.row])
        return starUsersCell
      
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let profileVC = ProfileViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Profile) as ProfileViewController
        profileVC.isNotFromTabBar = true
        let data = self.topStarUsersViewModelObj.peopleArray[indexPath.row]
        profileVC.memberId = data.peopleId
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
}


extension TopStarsViewController: UITextFieldDelegate,TopStarUsersCellDelegate {
    func followingButtonAction(cell: TopStarsCell) {
        guard let indexPath = self.usersTableView.indexPath(for: cell) else{ return }
        let modelArray = self.topStarUsersViewModelObj.peopleArray
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
        self.topStarApiCall(searchText: txtAfterUpdate)
        return true
    }
}

