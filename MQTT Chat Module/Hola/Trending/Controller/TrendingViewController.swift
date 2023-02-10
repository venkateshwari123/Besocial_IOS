 //
 //  TrendingViewController.swift
 //  MQTT Chat Module
 //
 //  Created by Rahul Sharma on 06/09/18.
 //  Copyright © 2018 Rahul Sharma. All rights reserved.
 //
 
 import UIKit
 import Kingfisher
 import QuiltView
 import DGElasticPullToRefresh
 class TrendingViewController: UIViewController {
    
    
    /// All Outlets
    @IBOutlet weak var exploreTableViewOutlet: UITableView!
    @IBOutlet weak var searchShadowView: UIView!
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var noActivityView: UIView!
    @IBOutlet weak var cameraButtonContainerView: UIView!
    @IBOutlet weak var cameraButtonOutlet: UIButton!
    @IBOutlet weak var balanceLabelOutlet: UILabel!
    @IBOutlet weak var searchBarOutlet: UISearchBar!
    @IBOutlet weak var noTrendingPostLbl: UILabel!

    @IBOutlet weak var coinBackView: UIView!
    
    /// Variables and Declarations
    var showSearch : Bool = false
    let bottomEdge: CGFloat = 60
    var lastContentOffset: CGFloat = 0
    var selectedIndex: Int = 0
    var largeCellIndex: Int = 1
    var canTrendingServiceCall: Bool = false
    var categoryModel: CategoryModel?
    var isLoadedOnce: Bool = false
    var trendingViewModel = TrendingViewModel()
    let socialViewModel = SocialViewModel()
    var canCategoryServiceCall:Bool = false
    var onStreamModel = ONStreamModel()
    var needToRefresh:Bool = true
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setViewUI()
        getCategoriesService()
        getTrendingPosts()
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTrendingPage), name: NSNotification.Name(rawValue: "refreshTrendingPage"), object: nil)
    }
    
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /*
         Bug Name:- if a image is locked and I have subscribed to that user than those images should not appear with a locked sign on explore page
         Fix Date:- 24/06/21
         Fix By  :- Jayaram G
         Description of Fix:- Updating trending data if user purchased post or subcribed a user
         */
        if Utility.isDarkModeEnable(){
            UIApplication.shared.statusBarStyle = .lightContent
        }else{
            UIApplication.shared.statusBarStyle = .darkContent
            self.searchShadowView.makeShadowForSearchView()
        }
        if #available(iOS 13.0, *) {
            self.tabBarController?.tabBar.backgroundColor = UIColor.systemBackground
            self.tabBarController?.tabBar.backgroundImage = UIImage.init(color: UIColor.systemBackground)
        } else {
            self.tabBarController?.tabBar.backgroundColor = UIColor.white
            self.tabBarController?.tabBar.backgroundImage = UIImage.init(color: UIColor.white)
            // Fallback on earlier versions
        }
        self.tabBarController?.tabBar.isTranslucent = false

        if let trendingUpdate = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.trendingUpdate) as? Bool , trendingUpdate {
            self.trendingViewModel.trendingOffset = -20
            getTrendingPosts()
        }
        let walletData = Double(KeychainHelper.sharedInstance.getCoinWalletBalance())?.formatUsingAbbrevation()
        
        self.balanceLabelOutlet.text = " \(walletData ?? "") "
//        getTheStreamingData()
        if #available(iOS 13.0, *) {
            self.navigationController?.navigationBar.barTintColor = .systemBackground
        }
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.layer.zPosition = 0
        
        
        if let isFromFindFriendsAct = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isFromFindFriendsAction) as? Bool {
            if isFromFindFriendsAct {
                UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isFromFindFriendsAction)
                showSearch = false
                self.opneSearchViewAction(self)
            }
        }
        
        
        if showSearch{
            showSearch = false
            self.opneSearchViewAction(self)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view) { [self] (status) in
            if status && !needToRefresh{

            }else{
                needToRefresh = false
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.trendingUpdate)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isLoadedOnce{
            isLoadedOnce = true
        }
    }
    
    
    func presentWelcomeController() {
        let loginVC = LoginVC.instantiate(storyBoardName: "Authentication") as LoginVC
         loginVC.isFromHomeVC = true
         let navVC = UINavigationController(rootViewController: loginVC)
         navVC.modalPresentationStyle = .overCurrentContext
         navVC.navigationBar.isHidden = true
         self.present(navVC, animated: true, completion: nil)
     }
    
    
    @IBAction func proflieVcAction(_ sender: Any) {
        if AppConstants.appType == .dubly,let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus{
            presentWelcomeController()
        }else{
            let profileVC = ProfileViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Profile) as ProfileViewController
            profileVC.isSelf = true
            profileVC.isNotFromTabBar = true
            profileVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(profileVC, animated: true)

        }

    }
    
    
   
    @IBAction func liveAction(_ sender: Any) {
        if AppConstants.appType == .dubly,let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus{
            presentWelcomeController()
        }else{
            let storyboard = UIStoryboard(name: AppConstants.StoryBoardIds.live, bundle: nil)
            guard let onGoingStreamVC = storyboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.OnGoingStreamVC) as? OnGoingStreamVC else{return}
            onGoingStreamVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(onGoingStreamVC, animated: true)
        }
    }
    
    
    @IBAction func activityAction(_ sender: Any) {
        if AppConstants.appType == .dubly,let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus{
            presentWelcomeController()
        }else{
            let activityVc = ActivityViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Activity) as ActivityViewController
            activityVc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(activityVc, animated: true)
        }
    }
    /// To set view UI on view did load
    func setViewUI(){
        self.searchContainerView.makeCornerRadious(readious: 5)
        self.exploreTableViewOutlet.tableFooterView = UIView()
        self.coinBackView.backgroundColor = Utility.appColor()
        self.searchBarOutlet.placeholder = "Search".localized + " " + "people".localized + ", " + "hashtags".localized + ", " + "place".localized
        self.noTrendingPostLbl.text = "There is no trending post".localized
        self.navigationItem.title = "Explore".localized
        self.navigationController?.navigationBar.tintColor = .black
        self.exploreTableViewOutlet.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: bottomEdge, right: 0)
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        exploreTableViewOutlet.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            // Add your logic here

            /* Bug Name :- latest trending post not updated
             Fix Date :- 23/03/2021
             Fixed By :- Nikunj C
             Description Of fix :- add trending offset to -20  */
            
            self?.trendingViewModel.trendingOffset = -20
            self?.getCategoriesService()
            self?.getTrendingPosts()
            }, loadingView: loadingView)
        exploreTableViewOutlet.dg_setPullToRefreshFillColor(Helper.hexStringToUIColor(hex: AppColourStr.secondoryAPPColor))
        exploreTableViewOutlet.dg_setPullToRefreshBackgroundColor(exploreTableViewOutlet.backgroundColor!)
        if #available(iOS 13.0, *) {
            self.exploreTableViewOutlet.tintColor = .systemBackground
        } else {
            self.exploreTableViewOutlet.tintColor = .white
        }
    }
    
    
    /// Setting no post view if post count is 0
    private func setNoPostView(){
        if self.trendingViewModel.trendingModelArray.count == 0{
            self.noActivityView.isHidden = false
        }else{
            self.noActivityView.isHidden = true
        }
    }
    
    deinit {
        if exploreTableViewOutlet != nil{
            self.exploreTableViewOutlet.dg_removePullToRefresh()
        }
    }
    
    
    @objc func refreshTrendingPage() {
        self.trendingViewModel.categorySetValue = 0
        self.trendingViewModel.trendingOffset = -20
        self.getCategoriesService()
        self.getTrendingPosts()
    }
    //MARK:- Button action
    
    @IBAction func walletVcAction(_ sender: Any) {
        if AppConstants.appType == .dubly,let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus{
            presentWelcomeController()
        }else{
            Route.navigateToCoinWallet(navigationController:self.navigationController)
        }
        
    }
    
    
    @IBAction func cameraButtonAction(_ sender: Any) {
        self.presentCameraVC()
    }
    
    
    /// Opening Search bar action
    ///
    /// - Parameter sender: search bar tapping
    @IBAction func opneSearchViewAction(_ sender: Any) {
        if AppConstants.appType == .dubly,let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus{
            presentWelcomeController()
        }else{
            let storyBoard = UIStoryboard(name: AppConstants.StoryBoardIds.Trending, bundle: nil)
            guard let searchViewController = storyBoard.instantiateViewController(withIdentifier: controllerIdentifierName.searchViewController) as? SearchViewController else {return}
            searchViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(searchViewController, animated: false)
        }
    }
    
    //MARK:- Service call
    func getCategoriesService(){
        Helper.showPI()
        trendingViewModel.getCategorys { (success, error, canServiceCall) in
            self.exploreTableViewOutlet.dg_stopLoading()
            if success{
                print("Success ")
                self.exploreTableViewOutlet.reloadSections([0], with: .none)
            }else if let error = error{
                self.trendingViewModel.categorySetValue = 0
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
            }
            self.canCategoryServiceCall = canServiceCall
        }
    }
    
    func getTrendingPosts() {
        DispatchQueue.main.async {
         Helper.showPI()
        }
        self.trendingViewModel.getRecomendedTrending(complitation: { (isFinished, error, canServiceCall) in
            DispatchQueue.main.async {
                Helper.hidePI()
                self.exploreTableViewOutlet.dg_stopLoading()
            }
            if isFinished {
                self.exploreTableViewOutlet.reloadSections([1], with: .none)
            }else if let error = error{
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
                self.trendingViewModel.trendingOffset = self.trendingViewModel.trendingOffset - 20
            }
            self.canTrendingServiceCall = canServiceCall
        })
    }
    
    
    //MARK:- Service call
    func getTheStreamingData() {
        Helper.showPI()
//        streamData = [StreamData]()
        self.exploreTableViewOutlet.reloadSections([0], with: .none)
        onStreamModel.getTheOnLineStreamPPL { [weak self] (streamingPPL) in
            Helper.hidePI()
            guard let strongSelf = self else {return}
//            strongSelf.streamData = streamingPPL
            DispatchQueue.main.async {
                strongSelf.exploreTableViewOutlet.reloadSections([0], with: .none)
            }
        }
    }
    
 }
 
 
 
