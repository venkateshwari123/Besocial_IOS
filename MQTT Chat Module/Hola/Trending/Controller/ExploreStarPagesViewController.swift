//
//  ExploreStarPagesViewController.swift
//  PicoAdda
//
//  Created by 3Embed on 02/11/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class ExploreStarPagesViewController: UIViewController {
    
    let searchStarUsersViewModelObj = SearchStarUsersViewModel()
    
    @IBOutlet weak var searchTf: UITextField!
    @IBOutlet weak var usersTableView: UITableView!
    @IBOutlet weak var noPeopleView: UIView!
    @IBOutlet weak var topMostInfluentialStars: UIButton!
    @IBOutlet weak var TopBestActors: UIButton!
    @IBOutlet weak var topBestActresses: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usersTableView.tableFooterView = UIView()
        getStarUsersList(searchtext: "")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "back_arrow"), style: .plain, target: self, action: #selector(dismissSelf))
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    
    func getStarUsersList(searchtext: String) {
        let strUrl: String = AppConstants.starUsers
        searchStarUsersViewModelObj.getStarUsersDataService(strUrl: strUrl, searchText: searchtext) { (success, error, canServiceCall) in
            if success{
                self.usersTableView.reloadData()
            }else if let error = error{
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }else{
                    self.usersTableView.reloadData()
                }
                if error.code == 412 {
                    Helper.showAlertViewOnWindow(Strings.warning.localized, message: Strings.profileDeleted.localized)
                }
            }
            Helper.hidePI()
        }
    }
    
    
    ///To update people table view according to selected or unselected follow button and put to server
    func updatePeopleModelArray(modelData: PeopleModel, index: IndexPath){
        if modelData.followStatus == 0{
            modelData.followStatus = 1
            if modelData.privicy == 1{
                modelData.followStatus = 2
            }
            self.searchStarUsersViewModelObj.FollowPeopleService(isFollow: true, peopleId: modelData.peopleId!, privicy: modelData.privicy)
        }else{
            modelData.followStatus = 0
            self.searchStarUsersViewModelObj.FollowPeopleService(isFollow: false, peopleId: modelData.peopleId!, privicy: modelData.privicy)
        }
        self.searchStarUsersViewModelObj.peopleArray[index.row] = modelData
        self.usersTableView.beginUpdates()
        self.usersTableView.reloadRows(at: [index], with: .none)
        self.usersTableView.endUpdates()
    }
    
    
    @IBAction func topMostInfluentialStarsAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: AppConstants.StoryBoardIds.Main, bundle: nil)
        guard let exploreStarPagesVc = storyboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.TopStarsViewControllerVcId) as? TopStarsViewController else{return}
        exploreStarPagesVc.isTopMostInfluentialStars = true
        exploreStarPagesVc.navigationItem.title = "Top 10 Most Influential Stars"
        self.navigationController?.pushViewController(exploreStarPagesVc, animated: true)
    }
    
    
    @IBAction func topBestActorsAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: AppConstants.StoryBoardIds.Main, bundle: nil)
        guard let exploreStarPagesVc = storyboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.TopStarsViewControllerVcId) as? TopStarsViewController else{return}
        exploreStarPagesVc.isTopBestActors = true
        exploreStarPagesVc.navigationItem.title = "Top 50 Best Actors"
        self.navigationController?.pushViewController(exploreStarPagesVc, animated: true)
    }
    
    
    @IBAction func topBestActressesAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: AppConstants.StoryBoardIds.Main, bundle: nil)
        guard let exploreStarPagesVc = storyboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.TopStarsViewControllerVcId) as? TopStarsViewController else{return}
        exploreStarPagesVc.isTopBestActresses = true
        exploreStarPagesVc.navigationItem.title = "Top 50 Best Actresses"
        self.navigationController?.pushViewController(exploreStarPagesVc, animated: true)
    }
    
}
