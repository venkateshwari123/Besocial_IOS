//
//  SearchViewController.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 31/08/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import GooglePlaces

protocol SearchViewControllerDelegate: class{
    func didFollowOrUnfollowUser()
}

class SearchViewController: UIViewController {
    
    
    
    
    @IBOutlet weak var searchShadowView: UIView!
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var searchBarOutlet: UISearchBar!
    
    @IBOutlet weak var peopleButtonOutlet: UIButton!
    @IBOutlet weak var channelButtonOutlet: UIButton!
    @IBOutlet weak var tagButtonOutlet: UIButton!
    @IBOutlet weak var locationButtonOutlet: UIButton!
    @IBOutlet weak var scrollingViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var peopleTableView: UITableView!
    @IBOutlet weak var noPeopleView: UIView!
    
    @IBOutlet weak var channelTableView: UITableView!
    @IBOutlet weak var noChannelView: UIView!
    
    @IBOutlet weak var tagTableView: UITableView!
    @IBOutlet weak var noTagView: UIView!
    
    @IBOutlet weak var locationTableView: UITableView!
    
    @IBOutlet weak var noLocationView: UIView!
    var searchViewModel = SearchViewModel()
    var canPeopleServiceCall: Bool = true
    var canChannelServiceCall: Bool = true
    var canTagServiceCall: Bool = true
    
    var searchString: String = ""
    var tap: UITapGestureRecognizer?
    var isSearchActive: Bool = false
    
    var selectedIndex: Int = 0
    var searchChangeForPeople: Bool = true
    var searchChangeForChannel: Bool = true
    var searchChangeForTags: Bool = true
    var searchChangeForLocation: Bool = true
    
    var locationManager: CLLocationManager!
    let placesClient:GMSPlacesClient = GMSPlacesClient.shared()
    var likeHoodList: GMSPlaceLikelihoodList?
    
    
    var delegate: SearchViewControllerDelegate?
    var isFollowUnfollowChange: Bool = false
    
    
    struct cellIdentifier {
        static let searchTableViewCell = "searchTableViewCell"
        static let PeopleSearchTableViewCell = "PeopleSearchTableViewCell"
        static let searchLocationCell = "searchLocationCell"
        static let CurrentLocationTableViewCell = "CurrentLocationTableViewCell"
    }
    struct Controlleridentifier {
        static let postedByController = "postedByController"
    }
    
    struct storyboardId {
        static let profileViewController = "ProfileViewController"
        static let CurrentLocationListViewController = "CurrentLocationListViewController"
    }
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewUI()
        self.searchBarOutlet.becomeFirstResponder()
        self.searchChangeForPeople = true
        self.canChannelServiceCall = true
        self.enableAllServiceCall()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        self.navigationController?.isNavigationBarHidden = true

        //        if let userImage = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userImage) as? String{
        //            self.userProfileImageOutlet.setImageOn(imageUrl: userImage, defaultImage:#imageLiteral(resourceName: "defaultImage"))
        //        }else{
        //            self.userProfileImageOutlet.image = #imageLiteral(resourceName: "defaultImage")
        //        }
        //        self.navigationController?.navigationBar.layer.zPosition = 0
        //        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
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
    
    func setUpViewUI(){
        
        self.searchContainerView.makeCornerRadious(readious: 5)
        if !Utility.isDarkModeEnable(){
            self.searchShadowView.makeShadowForSearchView()
        }
        self.searchBarOutlet.placeholder = "Search".localized + " " + "people".localized + ", " + "hashtags".localized + ", " + "place".localized
        self.navigationItem.title = "Explore".localized
        self.peopleButtonOutlet.setTitle("People".localized, for: .normal)
        self.tagButtonOutlet.setTitle("Hashtag".localized, for: .normal)
        self.locationButtonOutlet.setTitle("Places".localized, for: .normal)
        //  self.userProfileImageOutlet.makeCornerRadious(readious: self.userProfileImageOutlet.frame.size.width / 2)
        let backButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "back_arrow"), style: .plain, target: self, action: #selector(self.backButtonAction(_:)))
        self.navigationItem.title = "Explore"
        self.navigationController?.navigationBar.titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary([NSAttributedString.Key.font.rawValue : Utility.Font.Bold.ofSize(17)])
        self.navigationItem.leftBarButtonItem = backButton
        backButton.tintColor = UIColor.setColor(lightMode: "292929", darkMode: "FFFFFF")
        //        self.navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: "")
        self.peopleButtonOutlet.isSelected = true
        self.peopleTableView.tableFooterView = UIView()
        self.channelTableView.tableFooterView = UIView()
        self.tagTableView.tableFooterView = UIView()
        self.noLocationView.isHidden = true
        //Looks for single or multiple taps.
        tap = UITapGestureRecognizer(target: self, action: #selector(SearchViewController.dismissKeyboard(_:)))
        tap?.cancelsTouchesInView = true
        tap?.delegate = self
        view.addGestureRecognizer(tap!)
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    //MARK:- Button action
    @IBAction func backButtonAction(_ sender: Any) {
        if self.isFollowUnfollowChange && self.delegate != nil{
            self.delegate?.didFollowOrUnfollowUser()
        }
        
        // Use Fade transition instead of default present animation
        //        self.applyFadeAnimationOnController()
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func peopleAction(_ sender: Any) {
        setSelectedButton(index: 0)
        self.selectedIndex = 0
        //        self.callApiAccordingToCurrentFrame(scrollView: self.mainScrollView)
    }
    
    @IBAction func channelAction(_ sender: Any) {
        /*
         Refactor Name:- Hide Channel
         Refactor Date:- 30/03/21
         Refactor By  :- Nikunj C
         Discription of Refactor:- comment channel button action
         */
        
        
//        setSelectedButton(index: 1)
//        self.selectedIndex = 1
        //        self.callApiAccordingToCurrentFrame(scrollView: self.mainScrollView)
    }
    
    @IBAction func tagAction(_ sender: Any) {
        
        /*
         Refactor Name:- Hide Channel
         Refactor Date:- 30/03/21
         Refactor By  :- Nikunj C
         Discription of Refactor:- change selected index to 1
         */
        
        setSelectedButton(index: 1)
        self.selectedIndex = 1
        //        self.callApiAccordingToCurrentFrame(scrollView: self.mainScrollView)
    }
    
    @IBAction func locationAction(_ sender: Any) {
        /*
         Refactor Name:- Hide Channel
         Refactor Date:- 30/03/21
         Refactor By  :- Nikunj C
         Discription of Refactor:- change selected index to 2
         */
        
        setSelectedButton(index: 2)
        self.selectedIndex = 2
        //        self.callApiAccordingToCurrentFrame(scrollView: self.mainScrollView)
    }
    
    
    @IBAction func walletButtonAction(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Services, bundle: nil)
        let walletVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.walletVcId) as! WalletViewController
//        walletVc.isPresented = true
        let navigationVC = UINavigationController(rootViewController: walletVc)
        self.present(navigationVC, animated: true, completion: nil)
    }
    
    @IBAction func userProfileButtonAction(_ sender: Any) {
        let profileVC = ProfileViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Profile) as ProfileViewController
        profileVC.isSelf = true
        profileVC.isPresented = true
        profileVC.isNotFromTabBar = true
        profileVC.followedAction = {
            self.searchViewModel.peopleOffset = -40
            self.getPeopleService()
        }
        let navigationVC = UINavigationController(rootViewController: profileVC)
        self.present(navigationVC, animated: true, completion: nil)
    }
    
    
    //MARK:- Service call
    func getPeopleService(){
        var strUrl: String = AppConstants.searchPeople + "?"
        if self.searchString != ""{
            strUrl = AppConstants.searchPeople + "?username=\(self.searchString)&"
            print("people url: \(strUrl)")
        }else{
            if self.searchViewModel.peopleOffset == -40{
                Helper.showPI()
            }
        }
        print("API \(strUrl)")
        print("*********Search people")
        searchViewModel.getSearchData(with: strUrl, type: .people) { (success, error, canServiceCall) in
            if success{
                self.setNoPeopleViewUI()
                self.peopleTableView.reloadData()
            }
            if let error = error{
                print(error.localizedDescription)
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: (error.localizedDescription))
                }else if error.code == 204{
                    self.peopleTableView.reloadData()
                }
                self.searchViewModel.peopleOffset = self.searchViewModel.peopleOffset - 40
            }
            self.canPeopleServiceCall = canServiceCall
        }
    }
    
    func getChannelService(){
        
        var strUrl: String = AppConstants.channelList + "?"
        if self.searchString != ""{
            strUrl = AppConstants.channelList + "?searchText=\(self.searchString)&"
        }else{
            if self.searchViewModel.channelOffset == -40{
                Helper.showPI()
            }
        }
        searchViewModel.getSearchData(with: strUrl, type: .channel) { (success, error, canServiceCall) in
            if success{
                self.setNoChannelViewUI()
                self.channelTableView.reloadData()
            }
            if let error = error{
                print(error.localizedDescription)
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: (error.localizedDescription))
                }
                else if error.code == 204{
                    self.channelTableView.reloadData()
                }
                self.searchViewModel.channelOffset = self.searchViewModel.channelOffset - 40
            }
            self.canChannelServiceCall = canServiceCall
        }
    }
    
    func getTagsService(){
        var strUrl: String = AppConstants.hashTagList + "?"
        if self.searchString != ""{
            strUrl = AppConstants.hashTagList + "?hashtag=\(self.searchString)&"
        }else{
            if self.searchViewModel.tagOffset == -40{
                Helper.showPI()
            }
        }
        print("*********Search hashtags")
        searchViewModel.getSearchData(with: strUrl, type: .tag) { (success, error, canServiceCall) in
            if success{
                self.setNoTagViewUI()
                self.tagTableView.reloadData()
            }
            if let error = error{
                print(error.localizedDescription)
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: (error.localizedDescription))
                }else if error.code == 204{
                    self.tagTableView.reloadData()
                }
                self.searchViewModel.tagOffset = self.searchViewModel.tagOffset - 40
            }
            self.canTagServiceCall = canServiceCall
        }
    }
    
    
    func getLocationApi(){
        self.searchViewModel.getLocationDataFromDataBase {
            self.setNoLocationViewUI()
            self.locationTableView.reloadData()
        }
        print("*********Search locations")
        self.searchViewModel.getLocationSearch(search: self.searchBarOutlet.text) { (success, error) in
            //            if success{
            DispatchQueue.main.async {
                Helper.hidePI()
            }
            self.setNoLocationViewUI()
            self.locationTableView.reloadData()
            //            }
        }
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
//MARK:- Scroll view Delegate
extension SearchViewController: UIScrollViewDelegate{
    
    /*
     Refactor Name:- Hide Channel
     Refactor Date:- 30/03/21
     Refactor By  :- Nikunj C
     Discription of Refactor:- now only 3 button people, tag and location selected
     */
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.mainScrollView{
            let offset = scrollView.contentOffset
            self.scrollingViewLeadingConstraint.constant = scrollView.contentOffset.x / 3
            if offset.x < (self.view.frame.size.width * 4) / 5{
                ///select people selected and channel and tag deselect
                self.peopleButtonOutlet.isSelected = true
                self.channelButtonOutlet.isSelected = false
                self.tagButtonOutlet.isSelected = false
                self.locationButtonOutlet.isSelected = false
                
            }
            else if offset.x >= (self.view.frame.size.width * 4) / 5 && offset.x < (self.view.frame.size.width * 6) / 5{
                ///select tag selected and people and channel deselect
                self.peopleButtonOutlet.isSelected = false
                self.channelButtonOutlet.isSelected = false
                self.tagButtonOutlet.isSelected = true
                self.locationButtonOutlet.isSelected = false
            }
            else if offset.x >= (self.view.frame.size.width * 6) / 5 && offset.x < (self.view.frame.size.width * 5) / 2{
                ///select channel selected and people and tag deselect
                self.peopleButtonOutlet.isSelected = false
                self.channelButtonOutlet.isSelected = false
                self.tagButtonOutlet.isSelected = false
                self.locationButtonOutlet.isSelected = true
            }
//            else{
//                ///select location selected and people, tag and channel deselect
//                self.peopleButtonOutlet.isSelected = false
//                self.channelButtonOutlet.isSelected = false
//                self.tagButtonOutlet.isSelected = false
//                self.locationButtonOutlet.isSelected = true
//            }
            scrollView.contentOffset = offset
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.callApiAccordingToCurrentFrame(scrollView: scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.callApiAccordingToCurrentFrame(scrollView: scrollView)
    }
    
    func callApiAccordingToCurrentFrame(scrollView: UIScrollView){
        if scrollView == self.mainScrollView{
            let xPosition = scrollView.bounds.origin.x
            let width = self.view.frame.size.width
            if xPosition == 0{
                self.selectedIndex = 0
            }else if xPosition == width{
                self.selectedIndex = 1
            }else if xPosition == width * 2{
                self.selectedIndex = 2
            }else if xPosition == width * 3{
                self.selectedIndex = 3
            }
            self.makeAllServiceCall()
        }
    }
    
    /// To move frame according to selected button (0 for People, 1 for channel and 2 for tags)
    ///
    /// - Parameter index: selected button number
    func setSelectedButton(index: Int8){
        var frame = self.mainScrollView.bounds
        switch index {
        case 0:
            frame.origin.x = 0.0
            break
        case 1:
            frame.origin.x = self.view.frame.size.width
            break
            
        /*
         Refactor Name:- Hide Channel
         Refactor Date:- 30/03/21
         Refactor By  :- Nikunj C
         Discription of Refactor:- for selectedIndex 2 set location configuration
         */
            
//        case 2:
//            frame.origin.x = self.view.frame.size.width * 2
//            break
        case 2:
            frame.origin.x = self.view.frame.size.width * 2
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            self.locationManager?.requestWhenInUseAuthorization()
            self.checkLocationPermission()
            
            break
        default: break
        }
        self.mainScrollView.scrollRectToVisible(frame, animated: true)
    }
    
    func checkLocationPermission(){
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .restricted, .denied:
                let alert = UIAlertController.init(title: Strings.locationServicesDisabled.localized, message: Strings.reEnableLocationsMessage.localized, preferredStyle: .alert)
                let alertAction = UIAlertAction.init(title: "Ok".localized, style: .cancel, handler: nil)
                let alertSettingsAction = UIAlertAction.init(title: "Settings".localized, style: .default) { (settings) in
                    UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
                }
                alert.addAction(alertAction)
                alert.addAction(alertSettingsAction)
                self.present(alert, animated: true, completion: nil)
                break
                break
            case .authorizedAlways, .authorizedWhenInUse:
                self.nearbyPlaces()
                break
            case .notDetermined:
                break
            }
        } else {
            print("Location services are not enabled")
        }
    }
    
    func nearbyPlaces() {
        Helper.showPI()
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                Helper.hidePI()
                return
            }
            
            if let placeLikelihoodList = placeLikelihoodList {
                self.likeHoodList = placeLikelihoodList
                self.locationTableView.reloadData()
            }
            Helper.hidePI()
        })
        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue))!
        placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: fields, callback: {
            (placeLikelihoodList: Array<GMSPlaceLikelihood>?, error: Error?) in
            if let error = error {
                print("An error occurred: \(error.localizedDescription)")
                return
            }
            
            if let placeLikelihoodList = placeLikelihoodList {
                print("nearby locations")
                //                self.likeHoodList = placeLikelihoodList
                //                self.currentLocationListTableView.reloadData()
            }
        })
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchBarOutlet.resignFirstResponder()
    }
}

//MARK:- Search Bar delegate
extension SearchViewController: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("search text: \(searchText)")
        self.searchString = searchText
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(callSearchService), object: nil)
    self.perform(#selector(callSearchService), with: nil, afterDelay: 0.7)
        Helper.showPI()
    }
    
    @objc func callSearchService(){
        self.enableAllServiceCall()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchString = ""
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.perform(#selector(callSearchService), with: nil, afterDelay: 0.1)
        Helper.showPI()
        searchBar.resignFirstResponder()
    }
    
    
    /// To enable all service call and call api accroding to selected tab
    func enableAllServiceCall(){
        self.searchChangeForPeople = true
        self.searchChangeForChannel = true
        self.searchChangeForTags = true
        self.searchChangeForLocation = true
        makeAllServiceCall()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        if #available(iOS 13.0, *) {
            let searchBarStyle = searchBarOutlet.searchTextField
            let cancelBtn = UIButton()
            cancelBtn.contentMode = .scaleAspectFill
            cancelBtn.setImage(#imageLiteral(resourceName: "close_btn"), for: UIControl.State.normal)
            cancelBtn.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
            searchBarStyle.rightView = cancelBtn
            searchBarStyle.rightViewMode = UITextField.ViewMode.always
            searchBarStyle.clearButtonMode = .never
            self.isSearchActive = true
        }else {
            let searchBarStyle = searchBar.value(forKey: "_searchField") as? UITextField
            let cancelBtn = UIButton()
            cancelBtn.contentMode = .scaleAspectFill
            cancelBtn.setImage(#imageLiteral(resourceName: "close_btn"), for: UIControl.State.normal)
            cancelBtn.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
            searchBarStyle?.rightView = cancelBtn
            searchBarStyle?.rightViewMode = UITextField.ViewMode.always
            searchBarStyle?.clearButtonMode = .never
            self.isSearchActive = true
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.isSearchActive = false
    }
    
    /// To make all service calls with offset -40
    func makeAllServiceCall(){
        switch self.selectedIndex {
        case 0:
            self.searchViewModel.peopleOffset = -40
            if self.searchChangeForPeople{
                getPeopleService()
                self.searchChangeForPeople = false
            }
            break
        case 1:
            self.searchViewModel.tagOffset = -40
            if self.searchChangeForTags{
                getTagsService()
                self.searchChangeForTags = false
            }
            break
        case 2:
            if self.searchChangeForLocation{
                self.getLocationApi()
                self.searchChangeForLocation = false
            }
            break
        default:
            break
        }
    }
    
    
    /// To set no people view
    fileprivate func setNoPeopleViewUI(){
        if self.searchViewModel.peopleArray.count == 0{
            self.noPeopleView.isHidden = false
        }else{
            self.noPeopleView.isHidden = true
        }
    }
    /// To set no channle view
    fileprivate func setNoChannelViewUI(){
        if self.searchViewModel.channelArray.count == 0{
            self.noChannelView.isHidden = false
        }else{
            self.noChannelView.isHidden = true
        }
    }
    /// To set no hashtag view
    fileprivate func setNoTagViewUI(){
        if self.searchViewModel.hashTagArray.count == 0{
            self.noTagView.isHidden = false
        }else{
            self.noTagView.isHidden = true
        }
    }
    
    /// To set no hashtag view
    fileprivate func setNoLocationViewUI(){
        if self.searchViewModel.locationArray.count == 0 && self.searchBarOutlet.text != ""{
            self.noLocationView.isHidden = false
        }else{
            self.noLocationView.isHidden = true
        }
    }
}

//MARK:- Table View delegate
extension SearchViewController: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.locationTableView {
            if self.searchBarOutlet.text == "" {
                return 2
            }else {
                return 1
            }
        }else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case self.peopleTableView:
            return self.searchViewModel.peopleArray.count
        case self.channelTableView:
            return self.searchViewModel.channelArray.count
        case self.tagTableView:
            return self.searchViewModel.hashTagArray.count
        case self.locationTableView:
            
            if section == 0{
                if self.searchBarOutlet.text != ""{
                    return self.searchViewModel.locationArray.count
                }else{
                    return self.searchViewModel.recentSearchLocationArray.count + 1
                }
            }else {
                if let likeHoodList = likeHoodList {
                    return likeHoodList.likelihoods.count
                }
                return 0
            }
            
        default:
            return self.searchViewModel.hashTagArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch tableView {
        case self.peopleTableView:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier.PeopleSearchTableViewCell) as? PeopleSearchTableViewCell else {fatalError()}
            cell.setPeopleData(modelData: self.searchViewModel.peopleArray[indexPath.row])
            cell.delegate = self
            return cell
        case self.channelTableView:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier.searchTableViewCell) as? SearchTableViewCell else {fatalError()}
            cell.setChannelModel(modelData: self.searchViewModel.channelArray[indexPath.row])
            cell.delegate = self
            return cell
        case self.tagTableView:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier.searchTableViewCell) as? SearchTableViewCell else {fatalError()}
            if self.searchViewModel.hashTagArray.count > indexPath.row {
                cell.setTagData(modelData: self.searchViewModel.hashTagArray[indexPath.row])
            }
            cell.delegate = self
            return cell
        case self.locationTableView:
            if self.searchBarOutlet.text == ""{
            if indexPath.section == 0 {
                if indexPath.row == 0{
                    guard let currentLocationCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier.CurrentLocationTableViewCell) as? CurrentLocationTableViewCell else{fatalError()}
                    return currentLocationCell
                }else{
                    guard let searchAddressCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier.searchLocationCell) as? SearchLocationTableViewCell else{fatalError()}
                    if self.searchViewModel.recentSearchLocationArray.count > indexPath.row {
                        let searchResult = self.searchViewModel.recentSearchLocationArray[indexPath.row - 1]
                        searchAddressCell.setCellData(placeData: searchResult)
                    }
                return searchAddressCell
                }
            }else {
                guard let searchAddressCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier.searchLocationCell) as? SearchLocationTableViewCell else{fatalError()}
                if let list = likeHoodList{
                    if list.likelihoods.count > indexPath.row {
                    let place = list.likelihoods[indexPath.row].place //this is a GMSPlace object
                    searchAddressCell.addressLabel1.text = place.name
                    searchAddressCell.addressLabel2.text = place.formattedAddress
                    }
                }
                return searchAddressCell
            }
            }else {
                guard let searchAddressCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier.searchLocationCell) as? SearchLocationTableViewCell else{fatalError()}
                let searchResult = self.searchViewModel.locationArray[indexPath.row]
                searchAddressCell.setCellData(placeData: searchResult)
                return searchAddressCell
            }
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.locationTableView{
            if self.searchBarOutlet.text == ""{
                if indexPath.section == 0 {
                    if indexPath.row == 0{
                        return 0
                    }else{
                        var height1:CGFloat
                        var height2:CGFloat
                        let searchResult = self.searchViewModel.recentSearchLocationArray[indexPath.row - 1]
                        let searchAddressCell:SearchLocationTableViewCell = tableView.dequeueReusableCell(withIdentifier:cellIdentifier.searchLocationCell) as! SearchLocationTableViewCell
                        searchAddressCell.addressLabel1?.text = searchResult.primarytext
                        searchAddressCell.addressLabel2?.text = searchResult.secondaryText
                        
                        height1 = Helper.measureHeightLabel(label: searchAddressCell.addressLabel1, width: self.view.frame.size.width - 67)
                        height2 = Helper.measureHeightLabel(label: searchAddressCell.addressLabel2, width: self.view.frame.size.width - 67)
                        searchAddressCell.layoutIfNeeded()
                        return height1+height2 + 30
                    }
                }else {
                    return 60
                }
                
            }else{
                var height1:CGFloat
                var height2:CGFloat
                let searchResult = self.searchViewModel.locationArray[indexPath.row]
                let searchAddressCell:SearchLocationTableViewCell = tableView.dequeueReusableCell(withIdentifier:cellIdentifier.searchLocationCell) as! SearchLocationTableViewCell
                searchAddressCell.addressLabel1?.text = searchResult.primarytext
                searchAddressCell.addressLabel2?.text = searchResult.secondaryText
                
                height1 = Helper.measureHeightLabel(label: searchAddressCell.addressLabel1, width: self.view.frame.size.width - 67)
                height2 = Helper.measureHeightLabel(label: searchAddressCell.addressLabel2, width: self.view.frame.size.width - 67)
                searchAddressCell.layoutIfNeeded()
                return height1+height2 + 30
            }
        }
        return 65.0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == self.peopleTableView{
            let indexPassed: Bool = indexPath.row >= self.searchViewModel.peopleArray.count - 10
            if canPeopleServiceCall && indexPassed{
                self.canPeopleServiceCall = false
                getPeopleService()
            }
        }else if tableView == self.channelTableView{
            let indexPassed: Bool = indexPath.row >= self.searchViewModel.channelArray.count - 10
            if canChannelServiceCall && indexPassed{
                self.canChannelServiceCall = false
                getChannelService()
            }
        }else{
            let indexPassed: Bool = indexPath.row >= self.searchViewModel.hashTagArray.count - 10
            if canTagServiceCall && indexPassed{
                self.canTagServiceCall = false
                getTagsService()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected row: \(indexPath.row)")
        switch tableView {
        case peopleTableView:
            let profileVC = ProfileViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Profile) as ProfileViewController
            let data = self.searchViewModel.peopleArray[indexPath.row]
            profileVC.memberId = data.peopleId
            profileVC.isNotFromTabBar = true
            profileVC.hidesBottomBarWhenPushed = true
            profileVC.followedAction = {
                self.searchViewModel.peopleOffset = -40
                self.getPeopleService()
            }
            self.navigationController?.pushViewController(profileVC, animated: true)
            break
        case channelTableView:
            let postedbyController = PostedByViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.postedBy) as PostedByViewController
            let modelData = searchViewModel.channelArray[indexPath.row]
            postedbyController.isChannel = true
            postedbyController.channelName = modelData.channelName
            postedbyController.hashTagName = modelData.channelId
            self.navigationController?.pushViewController(postedbyController, animated: true)
            break
        case tagTableView:
            let postedbyController = PostedByViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.postedBy) as PostedByViewController
            let modelData = searchViewModel.hashTagArray[indexPath.row]
            postedbyController.isHashTag = true
            postedbyController.hashTagName = modelData.hashTag
            postedbyController.noofPostsCount = modelData.totalPublicPost
            postedbyController.hashTagImageUrl = modelData.hashTagImage
            self.navigationController?.pushViewController(postedbyController, animated: true)
            break
        default:
            if searchBarOutlet.text == ""{
                if indexPath.section == 0 {
                    if indexPath.row == 0{
                        let storyBoardObj = UIStoryboard.init(name: AppConstants.StoryBoardIds.Main, bundle: nil)
                        guard let navigatioVC = storyBoardObj.instantiateViewController(withIdentifier: storyboardId.CurrentLocationListViewController) as? UINavigationController else{return}
                        self.present(navigatioVC, animated: true, completion: nil)
                    }else{
                        let locationData = self.searchViewModel.recentSearchLocationArray[indexPath.row - 1]
                        self.getPlcaeDetails(location: locationData, isStored: true)
                    }
                }else {
                    if let list = likeHoodList{
                        let place = list.likelihoods[indexPath.row].place //this is a GMSPlace object
                        let postLocationVc = PostsLocationViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.postedBy) as PostsLocationViewController
                        var placeType = ""
                        if let firstType = place.types?[0] as? String {
                            placeType = firstType
                        }
                        if let secondType = place.types?[1] as? String {
                            placeType = placeType + " , " + secondType
                        }
                        
                        postLocationVc.placeType = placeType
                        if place.photos?[0] != nil {
                            self.placesClient.loadPlacePhoto((place.photos?[0])!, callback: { (image, error) in
                                if let imageObj = image {
                                    postLocationVc.placeImage = imageObj
                                }
                                
                            })
                        }
                        //                let place = self.searchViewModel.placeDetails
                        postLocationVc.placeName = place.name
                        postLocationVc.placeId = place.placeID ?? ""
                        postLocationVc.lattitude = place.coordinate.latitude
                        postLocationVc.longitude = place.coordinate.longitude
                        postLocationVc.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(postLocationVc, animated: true)
                    }
                    
                }
            }else{
                let locationData = self.searchViewModel.locationArray[indexPath.row]
                self.getPlcaeDetails(location: locationData, isStored: false)
            }
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    func getPlcaeDetails(location: LocationModel, isStored: Bool){
        self.searchViewModel.getPlaceInformation(location: location, isStored: isStored) { (result, error) in
            if let place = result{
                let postLocationVc = PostsLocationViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.postedBy) as PostsLocationViewController
                postLocationVc.placeName = place.name
                postLocationVc.placeId = place.placeID ?? ""
                
                var placeType = ""
                if let firstType = place.types?[0] {
                    placeType = firstType
                }
                if let secondType = place.types?[1] {
                    placeType = placeType + " , " + secondType
                }
                
                postLocationVc.placeType = placeType
                if place.photos?[0] != nil {
                    self.placesClient.loadPlacePhoto((place.photos?[0])!, callback: { (image, error) in
                        if let imageObj = image {
                            postLocationVc.placeImage = imageObj
                        }
                    })
                }
                
                postLocationVc.lattitude = place.coordinate.latitude
                postLocationVc.longitude = place.coordinate.longitude
                postLocationVc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(postLocationVc, animated: true)
            }
        }
    }
}

extension SearchViewController : CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            let alert = UIAlertController.init(title: Strings.locationServicesDisabled.localized, message: Strings.reEnableLocationsMessage.localized, preferredStyle: .alert)
            let alertAction = UIAlertAction.init(title: "OK".localized, style: .cancel, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            break
        case .authorizedAlways, .authorizedWhenInUse:
            self.checkLocationPermission()
            break
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
}

//MARK:- Search table view cell delegate
extension SearchViewController: SearchTableViewCellDelegate, PeopleSearchTableViewCellDelegate{
    
    func followingButtonAction(cell: PeopleSearchTableViewCell, tableType: TableType){
        self.isFollowUnfollowChange = true
        guard let indexPath = self.peopleTableView.indexPath(for: cell) else{ return }
        let modelArray = self.searchViewModel.peopleArray
        if modelArray.count > indexPath.row{
            let modelData = modelArray[indexPath.row]
            updatePeopleModelArray(modelData: modelData, index: indexPath)
        }

    }
    
    
    func followingButtonAction(cell: SearchTableViewCell, tableType: TableType) {
        self.isFollowUnfollowChange = true
        switch tableType {
        case .people:
            guard let indexPath = self.peopleTableView.indexPath(for: cell) else{ return }
            let modelArray = self.searchViewModel.peopleArray
            if modelArray.count > indexPath.row{
                let modelData = modelArray[indexPath.row]
                updatePeopleModelArray(modelData: modelData, index: indexPath)
            }
            break
        case .channel:
            guard let indexPath = self.channelTableView.indexPath(for: cell) else{ return }
            let modelArray = self.searchViewModel.channelArray
            if modelArray.count > indexPath.row{
                let modelData = modelArray[indexPath.row]
                updateChannelModelArray(modelData: modelData, index: indexPath)
            }
            break
        case .tag:
            break
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
            self.searchViewModel.FollowPeopleService(isFollow: true, peopleId: modelData.peopleId!, privicy: modelData.privicy)
        }else{
            modelData.followStatus = 0
            //            self.searchViewModel.FollowPeopleService(url: AppConstants.unfollow, peopleId: modelData.peopleId!)
            self.searchViewModel.FollowPeopleService(isFollow: false, peopleId: modelData.peopleId!, privicy: modelData.privicy)
        }
        self.searchViewModel.peopleArray[index.row] = modelData
        self.peopleTableView.beginUpdates()
        self.peopleTableView.reloadRows(at: [index], with: .none)
        self.peopleTableView.endUpdates()
    }
    ///To update channel table view according to selected or unselected Subscribe button and put to server
    func updateChannelModelArray(modelData: ChannelListModel, index: IndexPath){
        if modelData.subscribeStatus == 0{
            modelData.subscribeStatus = 1
            if modelData.privicy == 1{
                modelData.subscribeStatus = 2
            }
            self.searchViewModel.subseribeChannleService(url: AppConstants.subscribeChannel, channleId: modelData.channelId!)
        }else{
            modelData.subscribeStatus = 0
            self.searchViewModel.subseribeChannleService(url: AppConstants.unSubscribeChannel, channleId: modelData.channelId!)
        }
        self.searchViewModel.channelArray[index.row] = modelData
        self.channelTableView.beginUpdates()
        self.channelTableView.reloadRows(at: [index], with: .none)
        self.channelTableView.endUpdates()
    }
}

extension SearchViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool{
        guard let _ = touch.view?.isKind(of: SearchTableViewCell.self) else{
            return true
        }
        if isSearchActive{
            return true
        }
        return false
    }
}
// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
