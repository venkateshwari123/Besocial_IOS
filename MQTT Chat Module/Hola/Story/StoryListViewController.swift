//
//  StoryListViewController.swift
//  dub.ly
//
//  Created by Shivansh on 1/9/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class StoryListViewController: UIViewController {

    @IBOutlet weak var storyListTableView: UITableView!
    @IBOutlet weak var descriptionLbl: UILabel!
    var myStories:userStory = userStory(storiesDetails:[:])
    let storyAPIObj = StoryAPI()
    
    struct Controlleridentifier {
        static let ViewStoryID = "viewStoryID"
        static let CameraViewController = "CameraViewController"
        
    }
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "My Stories".localized
        descriptionLbl.text = "Your story updates will disappear after 24 hours".localized + "."
        // Do any additional setup after loading the view.
        storyListTableView.reloadData()
        self.storyListTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 90, right: 0)
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.storyListTableView.reloadData()
    }
    
    
    
    //MARK:- Buttons action
    
    @IBAction func addNewStorieAction(_ sender: Any) {
        Route.navigateToCamera(navigationController:self.navigationController,isPresent:true, isForStory : true,isFromStoryListVC:true, color : .white, delegate:self)
    }
    
    
    @IBAction func moreBtnAction(_ sender: Any) {
        
        let button = sender as! UIButton
        let selectedStory = self.myStories.userStories[button.tag]
        self.deleteStoryConfirmation(selectedStory:selectedStory)
        
        /*
        let alert = UIAlertController(title:nil, message:nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "View story", style: .default , handler:{ (UIAlertAction)in
            let button = sender as! UIButton
            let singleStory = self.myStories.userStories[button.tag]
            var userDetails = self.myStories
            userDetails.userStories = [singleStory]
            self.openStoriesScreenWithStories(stories:[userDetails])
        }))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .default , handler:{ (UIAlertAction)in
            let button = sender as! UIButton
            let selectedStory = self.myStories.userStories[button.tag]
            self.deleteStoryConfirmation(selectedStory:selectedStory)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel , handler:{ (UIAlertAction)in
            
        }))
        
        self.present(alert, animated: true, completion:nil)
        
        */
    }
    
    
    func deleteStoryConfirmation(selectedStory:StoryModel){
        let alert = UIAlertController(title:"Delete this story update".localized + "? " + "It will also be deleted for everyone who received it".localized + ".", message:"", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Delete".localized, style: .default , handler:{ (UIAlertAction)in
            self.deleteStory(selectedStory: selectedStory)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel , handler:{ (UIAlertAction)in
            
        }))
        
        self.present(alert, animated: true, completion:nil)
    }
    
    func updateDataAfterDeleteStory(deletedStory:StoryModel) {
        var allMyStories = self.myStories.userStories
        
        for eachStory in allMyStories.enumerated() {
            if(eachStory.element.storyID == deletedStory.storyID) {
                allMyStories.remove(at:eachStory.offset)
            }
        }
        
        self.myStories.userStories = allMyStories
        self.storyListTableView.reloadData()
        
        NotificationCenter.default.post(name: NSNotification.Name("updateMyStories"), object: self.myStories)
        NotificationCenter.default.post(name: NSNotification.Name("updateMyChatStories"), object: self.myStories)
        
        Helper.hidePI()
        if(self.myStories.userStories.count == 0) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func deleteStory(selectedStory:StoryModel) {
        Helper.showPI()
        let deleteApi = "story?storyId="+selectedStory.storyID!
        
        storyAPIObj.deleteStory(with:deleteApi , params:[:], complitation: { (response, error) in
            print("responce")
            print("error")
            
            if error != nil {
                Helper.hidePI()
                return
            }
            if response != nil ,let respDict = response as? [String:Any]{
                if let resultMsg = respDict["message"] as? String {
                    if resultMsg == "success" {
                        self.updateDataAfterDeleteStory(deletedStory: selectedStory)
                    }
                }
            }
        })
    }
    
    @IBAction func openWatchUsersPage(_ sender: Any) {
        let selectedStory = sender as! UIButton
        let singleStory = myStories.userStories[selectedStory.tag]
        var userDetails = myStories
        userDetails.userStories = [singleStory]
        openStoriesScreenWithStories(stories:[userDetails], openWatchUsers: true)
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
         self.navigationController?.popViewController(animated: true)
    }
    
    
    func addEmptyBackGroundView() {
        let messageLabel = UILabel(frame:CGRect(x: 30, y: self.view.frame.size.height/2 - 50, width:self.view.frame.size.width - 60, height:100))
        messageLabel.numberOfLines = 0
        messageLabel.text = "No stories."
        messageLabel.textAlignment = .center
        self.storyListTableView.backgroundView = messageLabel
    }
    
}


extension StoryListViewController: CameraViewDelegate{
    func popAfterStoryUpdate() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
}

extension StoryListViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.myStories.userStories.count == 0 {
            self.addEmptyBackGroundView()
        } else {
            self.storyListTableView.backgroundView = nil
        }
        
        return self.myStories.userStories.count
    }
 
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        if(myStories.userStories.count > 0) {
//            return 60
//        }
//        return 0
//    }
    
    

//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        
//        let superView = UIView()
//        superView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height:
//        40)
//        
//        let messageLabel = UILabel(frame:CGRect(x: 30, y: 10, width:self.view.frame.size.width - 60, height:40))
//        messageLabel.frame = superView.frame
//        messageLabel.numberOfLines = 0
//        messageLabel.text = "Your story updates will disappear after 24 hours."
//        messageLabel.font =  Utility.Font.Regular.ofSize(15.0)
//        messageLabel.textAlignment = .center
//        superView.addSubview(messageLabel)
//        return superView
//    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let storyCell = tableView.dequeueReusableCell(withIdentifier: "StoryListTableViewCell") as! StoryListTableViewCell
        let respStory = myStories.userStories[indexPath.row]
        if let timeStamp = respStory.createdOn {
            let date = Date(timeIntervalSince1970:timeStamp)
            storyCell.statusTimeLabel.text = Date().offsetFrom(date:date)
        }
        
        storyCell.watchStoriesBtn.tag = indexPath.row
        storyCell.viewCount.text = String(respStory.viewCount)
    storyCell.statusImageView.setImageOn(imageUrl:respStory.thumbNailUrl, defaultImage:#imageLiteral(resourceName: "defaultPicture"))
        storyCell.moreButton.tag = indexPath.row
        return storyCell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let singleStory = myStories.userStories[indexPath.row]
        var userDetails = myStories
        userDetails.userStories = [singleStory]
        openStoriesScreenWithStories(stories:[userDetails], openWatchUsers: false)
    }
    
    func openStoriesScreenWithStories(stories:[userStory],openWatchUsers:Bool) {
        let viewStoryVc = ViewStoryViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Main) as ViewStoryViewController
        viewStoryVc.allStories = stories
        viewStoryVc.viewStoryDeleg = self
        viewStoryVc.openWatchedUsers = openWatchUsers
        viewStoryVc.modalPresentationStyle = .overFullScreen
        self.present(viewStoryVc, animated: true, completion:nil)
    }
}

extension StoryListViewController:viewStoryDelegate {
    func storyDeleted(deletedStory: StoryModel) {
        self.updateDataAfterDeleteStory(deletedStory: deletedStory)
    }
    
    
}
