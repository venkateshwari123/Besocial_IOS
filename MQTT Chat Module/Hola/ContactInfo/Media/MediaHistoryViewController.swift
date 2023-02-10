//
//  MediaHistoryViewController.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 21/04/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import UIKit

class MediaHistoryViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var segment: UISegmentedControl!
    var selectImageCollectionView : UICollectionView?
    var chatdocID : String?
    var sections = Dictionary<String, Array<Message>>()
    var sortedSections = [String]()
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    @IBOutlet weak var collectionFlowLayoutOutlet: UICollectionViewFlowLayout!
    
    @IBOutlet weak var noPostView: UIView!
    @IBOutlet weak var noPostImageOutlet: UIImageView!
    @IBOutlet weak var sentBtnOutlet: UIButton!
    @IBOutlet weak var receivedBtnOutlet: UIButton!
    @IBOutlet weak var bottomViewLeadingConstraint: NSLayoutConstraint!
    var isSentSelected:Bool = true
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mediaCollectionView.delegate = self
        self.mediaCollectionView.dataSource = self
        getMediaMsgs(withChatDocID: chatdocID)
        self.sentBtnOutlet.setTitle("Sent".localized, for: .normal)
        self.sentBtnOutlet.setTitle("Sent".localized, for: .selected)
        self.receivedBtnOutlet.setTitle("Received".localized, for: .normal)
        self.receivedBtnOutlet.setTitle("Received".localized, for: .selected)
        self.segment.setTitle("Media".localized, forSegmentAt: 0)
        self.segment.setTitle("Documents".localized, forSegmentAt: 1)
        self.noPostImageOutlet.image = #imageLiteral(resourceName: "media_sent")
    }
    
    @IBAction func segmentCliked(_ sender: Any) {
        self.mediaCollectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
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
    
    private func getMediaMsgs(withChatDocID chatDocID: String?) {
        
        /*
         Bug Name:- place holder not appear for no media
         Fix Date:- 08/04/21
         Fixed By:- Nikunj C
         Description of fix:- if msgs is nil then pass [Message]()
         */
        
        let msgs = self.getAllMediaMessages(withChatDocID : chatDocID)
        self.addDataIntoArray(withMessages: msgs ?? [Message]())
    }
    
    private func getAllMediaMessages(withChatDocID chatDocID: String?) -> [Message]? {
        guard let chatDocID = chatDocID else { return nil }
        let chatDocVMObj = ChatsDocumentViewModel(couchbase: Couchbase.sharedInstance)
        return chatDocVMObj.getMediaMessages(withChatDocID: chatDocID)
    }
    
    func addDataIntoArray(withMessages messages: [Message]) {
        for msg in messages {
            if let dateObj = msg.messageSentDate {
                let dateStr = dateObj.getMonthFormatted()
                if self.sections.index(forKey: dateStr) != nil {
                    if var msgs = self.sections[dateStr] {
                        msgs.append(msg)
                        self.sections[dateStr] = msgs
                    }
                } else {
                    self.sections[dateStr] = [msg]
                }
            }
        }
        //we are storing our sections in dictionary, so we need to sort it
        self.sortedSections = self.sections.keys.sorted(by:<)
        if sections.count == 0 {
            /*
             Bug Name:- place holder not appear for no media
             Fix Date:- 08/04/21
             Fixed By:- Nikunj C
             Description of fix:- change place holder and enter message
             */
            self.noPostView.isHidden = false
            self.noPostImageOutlet.image = #imageLiteral(resourceName: "media_sent")
        }
        self.mediaCollectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setTableViewOrCollectionViewBackground(tableView: UITableView? , collectionView: UICollectionView?,image : UIImage?,labelText: String?,labelWithImage:Bool , yPosition: CGFloat){
        
        let backgroundView = UIView()
        backgroundView.frame = self.view.bounds
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 25))
        
        if let image = image{
            imageView.image = image
            imageView.center.y = yPosition
            imageView.center.x = self.view.center.x
            imageView.contentMode = .scaleAspectFill
            backgroundView.addSubview(imageView)
        }
        
        if let labelText = labelText{
            label.text = labelText
            label.textAlignment = .center
            label.font = Theme.getInstance().noLabelStyle.getFont()
            
            if labelWithImage{
                label.center.y = imageView.frame.maxY + 30
                imageView.center.x = self.view.center.x
                backgroundView.addSubview(label)
            }else{
                imageView.center.y = self.view.center.y
                imageView.center.x = self.view.center.x
                backgroundView.addSubview(label)
            }
        }
        
        if let tableView = tableView{
            tableView.backgroundView = backgroundView
        }
        
        if let collectionView = collectionView{
            collectionView.backgroundView = backgroundView
        }
    }
    
    /*
     Bug Name:- place holder inage for media screen not in sync with rest of app Media should load , both sent and received
     Fix Date:- 21/04/21
     Fix By  :- Jayaram G
     Description of Fix:- Added Sent media button action
     */
    @IBAction func sentBtnAction(_ sender: Any) {
        self.bottomViewLeadingConstraint.constant = 0
        isSentSelected = true
        self.noPostImageOutlet.image = #imageLiteral(resourceName: "media_sent")
        self.mediaCollectionView.reloadData()
    }
    
    
    /*
     Bug Name:- place holder inage for media screen not in sync with rest of app Media should load , both sent and received
     Fix Date:- 21/04/21
     Fix By  :- Jayaram G
     Description of Fix:- Added received media button action
     */
    @IBAction func receivedBtnAction(_ sender: Any) {
        self.bottomViewLeadingConstraint.constant = self.view.frame.width / 2
        isSentSelected = false
        self.noPostImageOutlet.image = #imageLiteral(resourceName: " media_received")
        self.mediaCollectionView.reloadData()
    }
    
    
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        /*
         Bug Name:- place holder inage for media screen not in sync with rest of app Media should load , both sent and received
         Fix Date:- 21/04/21
         Fix By  :- Jayaram G
         Description of Fix:- Added sorting for array and handling placeholders accordingly
         */
        if self.segment.selectedSegmentIndex == 1 {
            if isSentSelected {
                if sections[sortedSections[section]]?.filter({$0.messageType == MessageTypes.document}).filter({$0.isSelfMessage == true}).count == 0 {
                    setPlaceHolder(isHide: true)
                }else{
                    setPlaceHolder(isHide: false)
                }
                return sections[sortedSections[section]]?.filter({$0.messageType == MessageTypes.document}).filter({$0.isSelfMessage == true}).count ?? 0
                
            }else{
                if sections[sortedSections[section]]?.filter({$0.messageType == MessageTypes.document}).filter({$0.isSelfMessage != true}).count == 0 {
                    setPlaceHolder(isHide: true)
                }else{
                    setPlaceHolder(isHide: false)
                }
                return sections[sortedSections[section]]?.filter({$0.messageType == MessageTypes.document}).filter({$0.isSelfMessage != true}).count ?? 0
            }
            
        }else{
            if isSentSelected {
                if sections[sortedSections[section]]?.filter({$0.messageType != MessageTypes.document}).filter({$0.isSelfMessage == true}).count == 0 {
                    setPlaceHolder(isHide: true)
                }else{
                    setPlaceHolder(isHide: false)
                }
                return sections[sortedSections[section]]?.filter({$0.messageType != MessageTypes.document}).filter({$0.isSelfMessage == true}).count ?? 0
            }else{
                if sections[sortedSections[section]]?.filter({$0.messageType != MessageTypes.document}).filter({$0.isSelfMessage != true}).count == 0 {
                    setPlaceHolder(isHide: true)
                }else{
                    setPlaceHolder(isHide: false)
                }
                return sections[sortedSections[section]]?.filter({$0.messageType != MessageTypes.document}).filter({$0.isSelfMessage != true}).count ?? 0

            }
        }
        
    }
    
    func setPlaceHolder(isHide: Bool) {
        print("*******isHidded = \(!isHide)")
        self.noPostView.isHidden = !isHide
    }

    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let msgSection = sections[sortedSections[indexPath.section]]
        
        /*
         Bug Name:- place holder inage for media screen not in sync with rest of app Media should load , both sent and received
         Fix Date:- 21/04/21
         Fix By  :- Jayaram G
         Description of Fix:- Added sorting for array and handling data for sent and received for media and document
         */
        if self.segment.selectedSegmentIndex == 1 {
            if isSentSelected {
                let documentArrar = sections[sortedSections[indexPath.section]]?.filter({$0.messageType == MessageTypes.document}).filter({$0.isSelfMessage == true})
                let documentMsgItem = documentArrar![indexPath.row]
                if documentMsgItem.messageType == MessageTypes.document {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DocumentMediaCollectionViewCell", for: indexPath) as! DocumentMediaCollectionViewCell
                    cell.msgObject = documentMsgItem
                    cell.delegateObj = self
                    return cell
                }
            }else{
                let documentArrar = sections[sortedSections[indexPath.section]]?.filter({$0.messageType == MessageTypes.document}).filter({$0.isSelfMessage != true})
                let documentMsgItem = documentArrar![indexPath.row]
                if documentMsgItem.messageType == MessageTypes.document {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DocumentMediaCollectionViewCell", for: indexPath) as! DocumentMediaCollectionViewCell
                    cell.msgObject = documentMsgItem
                    cell.delegateObj = self
                    return cell
                }
            }
        }else{
            if isSentSelected {
                let mediaArray = sections[sortedSections[indexPath.section]]?.filter({$0.messageType != MessageTypes.document}).filter({$0.isSelfMessage == true})
                let mediaMsgItem = mediaArray![indexPath.row]
                if mediaMsgItem.messageType == MessageTypes.video { // Message type is Video
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaVideoCollectionViewCell", for: indexPath) as! MediaVideoCollectionViewCell
                    cell.msgObject = mediaMsgItem
                    return cell
                } else if mediaMsgItem.messageType == MessageTypes.replied {
                    if let repliedMsg = mediaMsgItem.repliedMessage {
                        if repliedMsg.replyMessageType == MessageTypes.video { // Message type is Video
                            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaVideoCollectionViewCell", for: indexPath) as! MediaVideoCollectionViewCell
                            cell.msgObject = mediaMsgItem
                            return cell
                        } else {
                            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mediaImageS", for: indexPath) as! MediaImageCollectionViewCell
                            cell.msgObject = mediaMsgItem
                            if repliedMsg.replyMessageType == MessageTypes.gif { // Message type is gif
                                cell.gifIconOutlet.isHidden = false
                            } else {
                                cell.gifIconOutlet.isHidden = true
                            }
                            return cell
                        }
                    }
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mediaImageS", for: indexPath) as! MediaImageCollectionViewCell
                    cell.msgObject = mediaMsgItem
                    if mediaMsgItem.messageType == MessageTypes.gif { // Message type is gif
                        cell.gifIconOutlet.isHidden = false
                    } else {
                        cell.gifIconOutlet.isHidden = true
                    }
                    return cell
                }
            }else {
                let mediaArray = sections[sortedSections[indexPath.section]]?.filter({$0.messageType != MessageTypes.document}).filter({$0.isSelfMessage != true})
                let mediaMsgItem = mediaArray![indexPath.row]
                if mediaMsgItem.messageType == MessageTypes.video { // Message type is Video
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaVideoCollectionViewCell", for: indexPath) as! MediaVideoCollectionViewCell
                    cell.msgObject = mediaMsgItem
                    return cell
                } else if mediaMsgItem.messageType == MessageTypes.replied {
                    if let repliedMsg = mediaMsgItem.repliedMessage {
                        if repliedMsg.replyMessageType == MessageTypes.video { // Message type is Video
                            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaVideoCollectionViewCell", for: indexPath) as! MediaVideoCollectionViewCell
                            cell.msgObject = mediaMsgItem
                            return cell
                        } else {
                            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mediaImageS", for: indexPath) as! MediaImageCollectionViewCell
                            cell.msgObject = mediaMsgItem
                            if repliedMsg.replyMessageType == MessageTypes.gif { // Message type is gif
                                cell.gifIconOutlet.isHidden = false
                            } else {
                                cell.gifIconOutlet.isHidden = true
                            }
                            return cell
                        }
                    }
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mediaImageS", for: indexPath) as! MediaImageCollectionViewCell
                    cell.msgObject = mediaMsgItem
                    if mediaMsgItem.messageType == MessageTypes.gif { // Message type is gif
                        cell.gifIconOutlet.isHidden = false
                    } else {
                        cell.gifIconOutlet.isHidden = true
                    }
                    return cell
                }
            }
        }
         
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 35)
    }
    
    @objc func  collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.view.frame.size.width == 375 {
            return CGSize(width: self.view.frame.size.width/4 - 9, height: 80)
        } else {
            return CGSize(width: self.view.frame.size.width/4 - 9, height: self.view.frame.size.width/4 - 9)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        /*
         Bug Name:- place holder inage for media screen not in sync with rest of app Media should load , both sent and received
         Fix Date:- 21/04/21
         Fix By  :- Jayaram G
         Description of Fix:- Handling media data according to selection
         */
        if isSentSelected {
            let mediaArray = sections[sortedSections[indexPath.section]]?.filter({$0.messageType != MessageTypes.document}).filter({$0.isSelfMessage == true})
            let mediaMsgItem = mediaArray![indexPath.row]
            let showMediaViewCntroller = ShowMediaViewController(nibName: "ShowMediaViewController", bundle: nil)
            guard let msgs = self.getAllMediaMessages(withChatDocID: chatdocID) else { return }
            showMediaViewCntroller.messages = msgs
            showMediaViewCntroller.selectedMessageUrl = mediaMsgItem.getVideoFileName()
            self.present(showMediaViewCntroller, animated: false, completion: nil)
        }else {
            let mediaArray = sections[sortedSections[indexPath.section]]?.filter({$0.messageType != MessageTypes.document}).filter({$0.isSelfMessage != true})
            let mediaMsgItem = mediaArray![indexPath.row]
            let showMediaViewCntroller = ShowMediaViewController(nibName: "ShowMediaViewController", bundle: nil)
            guard let msgs = self.getAllMediaMessages(withChatDocID: chatdocID) else { return }
            showMediaViewCntroller.messages = msgs
            showMediaViewCntroller.selectedMessageUrl = mediaMsgItem.getVideoFileName()
            self.present(showMediaViewCntroller, animated: false, completion: nil)
            
            
        }
    }
    
     func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "timeHeaderView", for: indexPath) as! MediaHeaderCollectionReusableView
        
        view.timeLbl.text = sortedSections[indexPath.section]
        return view
    }
}

extension MediaHistoryViewController: DocumentMediaCollectionViewCellDelegate {
    func openDocument(urlStr: String) {
        if  let webView =  UIStoryboard.init(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "DocumentViewerViewController") as? DocumentViewerViewController{
            webView.isComingfromSetting = true
            webView.webURL =  urlStr
            webView.titleName = ""
            self.navigationController?.pushViewController(webView, animated: true)
            self.navigationController?.navigationBar.isHidden = false
        }
    }
    
    
}
