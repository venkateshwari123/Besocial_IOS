//
//  OnGoingStreamVC.swift
//  Stream
//
//  Created by Vengababu Maparthi on 15/11/18.
//  Copyright © 2018 Vengababu Maparthi. All rights reserved.
//

import UIKit
import Kingfisher
//import AntMediaSDK
import Locksmith
import Alamofire

class OnGoingStreamVC: UIViewController {
    
    ///outlets
    var refreshControl = UIRefreshControl()
    @IBOutlet weak var streamingPeople: UICollectionView!
    @IBOutlet weak var vwNoData: UIView!
    @IBOutlet weak var goLiveButtonOutlet: UIButton!
    @IBOutlet weak var noLiveUser: UILabel!
    
    ///variables
//    var streamData = [StreamData]()
    
    var onStreamModel = ONStreamModel()
    
    let client = AntMediaClient.init()
    var clientUrl: String!
    var clientRoom: String!
    var clientToken: String!
    var isConnected = false
    var index : Int = 0
    
    //constant
    enum segueIdentifier: String {
        case toStartLiveStream = "toStartLiveStream"
    }
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Live Users".localized
        self.navigationController?.navigationBar.tintColor = .black
        noLiveUser.text = "No live users found".localized + "\n" + "Please check after some time".localized
        goLiveButtonOutlet.setTitle("Go live".localized, for: .normal)
        refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        streamingPeople.refreshControl = self.refreshControl
        
        self.goLiveButtonOutlet.makeCornerRadious(readious: self.goLiveButtonOutlet.frame.size.height / 2)
        self.goLiveButtonOutlet.makeGradientToUserView()

        NotificationCenter.default.addObserver(self, selector: #selector(self.getSubscribeStreamData(notification: )), name: NSNotification.Name(rawValue: AppConstants.notificationCenterName.streamNow.rawValue), object: nil)
        //live stream
        MQTT.sharedInstance.subscribeTopic(withTopicName: AppConstants.MQTT.streamNow, withDelivering: .atLeastOnce)
        
    }
    
    @objc func refresh() {
        getTheStreamingData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        MQTT.sharedInstance.createConnection()
        getTheStreamingData()
        /*need to check*/
//        MQTT.sharedInstance.delegate = self
//        client.delegate = self
        client.setDebug(true)
//        onStreamModel.getWalletBalanceService()
//        UserDefaults.standard.value(forKey: AppConstants.UserDefaults.streamID)
        UserDefaults.standard.removeObject(forKey: AppConstants.UserDefaults.streamID)
    }
    
    /*
     Bug Name:- network handling
     Fix Date:- 20/04/21
     Fix By  :- Nikunj C
     Description of Fix:- check connectivity and show popup for no internet
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Helper.checkConnectionAvaibility(view: self.view)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        MQTT.sharedInstance.unsubscribeTopic(topic: AppConstants.MQTT.streamNow)
    }
    
    
    //MARK:- Service call
    func getTheStreamingData() {
        Helper.showPI()
//        streamData = [StreamData]()
        self.streamingPeople.reloadData()
        onStreamModel.getTheOnLineStreamPPL { [weak self] (streamingPPL) in
            Helper.hidePI()
            guard let strongSelf = self else {return}
//            strongSelf.streamData = streamingPPL
            strongSelf.streamingPeople.reloadData()
            strongSelf.vwNoData.isHidden = streamingPPL.count > 0
            strongSelf.refreshControl.endRefreshing()
        }
    }
    
    @objc func getSubscribeStreamData(notification: Notification){
         self.getTheStreamingData()
    }
    
    
    
    ///Service call to remove strem data in stream list
    func removerActiveStreamServiceCall(){
        guard (UserDefaults.standard.value(forKey: AppConstants.UserDefaults.activeStreamId) as? String) != nil else{return}
        
        let url = AppConstants.endStream
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lan": Utility.getSelectedLanguegeCode()]
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: url, requestType: .delete, parameters: nil,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.endStream.rawValue)
        apiCall.subject_response
            .subscribe(onNext: {response in
                
                UserDefaults.standard.removeObject(forKey: AppConstants.UserDefaults.activeStreamId)
            }, onError : {error in
                
            })
    }
    
    
    //MARK:- navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewViewStream" {
            if let controller = segue.destination as? VideoViewController{
                controller.streamData = self.onStreamModel.streamData[sender as! Int]
                controller.clientUrl = self.clientUrl
                controller.clientStreamId = self.onStreamModel.streamData[sender as! Int].streamID//self.clientRoom
                controller.clientToken = self.clientToken
                controller.clientMode = AntMediaClientMode.play
                controller.varStreamTime = self.onStreamModel.streamData[sender as! Int].started
            }
        }else if segue.identifier == "toStartLiveStream"{
            if let controller = segue.destination as? StreamViewController{
                controller.delegateObj = self
            }
        }
    }
    
    //MARK:- Button action
    @IBAction func goLiveButtonAction(_ sender: Any) {
        self.performSegue(withIdentifier: segueIdentifier.toStartLiveStream.rawValue, sender: nil)
    }
    
}

extension OnGoingStreamVC:UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        index = indexPath.row
        self.connectClient()
    }
    
    func startStream(_ index : Int){
        self.performSegue(withIdentifier: "NewViewStream", sender: index)
    }
}


extension OnGoingStreamVC:UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.onStreamModel.streamData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StreamingCell", for: indexPath) as! StreamingCell
        cell.data = self.onStreamModel.streamData[indexPath.row]
        cell.btnFollow.addTarget(self, action: #selector(self.followButtonAction(_ :)), for: .touchUpInside)
        cell.btnFollow.tag = indexPath.row
        return cell
    }
    
    @objc func followButtonAction(_ button: UIButton){
        let index = button.tag
        self.onStreamModel.followAndUnFollowUserService(index: index) { (success) in
        }
        self.streamingPeople.reloadData()
    }
    
}


// MARK: - UICollectionViewDelegateFlowLayout Methods
extension OnGoingStreamVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width:CGFloat!
        var height:CGFloat!
        
        width = collectionView.bounds.width/2
        height = width + 70
        return  CGSize(width: width, height: height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
}

extension OnGoingStreamVC{
    @IBAction func btnFollow_Tapped(_ sender : UIButton){
        
    }
}

extension OnGoingStreamVC: AntMediaClientDelegate {
    func playStarted() {

    }

    func playFinished() {

    }

    func publishStarted() {

    }

    func publishFinished() {

    }

    func disconnected() {

    }

    
    func connectClient(){
        self.clientUrl = AppConstants.StreamUrl
        self.clientRoom = ""
        self.clientToken = ""
        client.delegate = self
        if client.isConnected() {
            self.startStream(index)
        } else {
            client.setOptions(url: self.clientUrl, streamId: self.clientRoom, token: self.clientToken, mode: AntMediaClientMode.play)
//            client.connect()
            DispatchQueue.main.async {
                self.client.connectWebSocket()
            }
            
        }
    }
    
    func clientDidConnect(_ client: AntMediaClient) {
        self.startStream(index)
    }
    
    func clientDidDisconnect(_ message: String) {
        self.isConnected = false
        Helper.showAlertViewOnWindow(Strings.error.localized, message: "Could not connect".localized + ": \(message)")
    }
    
    func clientHasError(_ message: String) {
        print("clientHasError: \(message)")
    }
    
    func remoteStreamRemoved() {}
    func remoteStreamStarted() {}
    func localStreamStarted() {}
}

extension OnGoingStreamVC: StreamViewControllerDelegate {
    func removeActiveStreams() {
        self.removerActiveStreamServiceCall()
    }
    
    
}
