//
//  VideoReceivedCollectionViewCell.swift
//
//
//  Created by Sachin Nautiyal on 22/01/2018.
//

import UIKit
import JSQMessagesViewController
import UICircularProgressRing
import Kingfisher

protocol VideoCellTappedDelegate {
    func videoCellTapped(withVideoMVModal videoMVModalObect: VideoMessageViewModal)
    func videoForwardActionCliked(_ cell: VideoSentCollectionViewCell)
    func receivedVideoForwardClicked(_ cell: VideoReceivedCollectionViewCell)
}

class VideoReceivedCollectionViewCell: JSQMessagesCollectionViewCell {
    
    @IBOutlet weak var replyViewOutlet: ReplyView!
    @IBOutlet weak var reloadButtonOutlet: UIButton!
    @IBOutlet var videoTappedButtonOutlet: UIButton!
    @IBOutlet var videoThumbnailViewOutlet: UIImageView!
    @IBOutlet weak var progressRingOutlet: UICircularProgressRing!
    
    @IBOutlet weak var senderImageView: UIImageView!
    
    
    var videoTappedDelegate : VideoCellTappedDelegate? = nil
    var chatDocID : String!
    var deleteDelegate: DeleteChatMessageCellDelegate? = nil
    var index = IndexPath()
    
    var msgVMObj : VideoMessageViewModal! {
        didSet {
            msgVMObj.downloadVideo(withChatDocID: chatDocID, progress: { [weak self] (progress) in
                self?.showDownloading(withProgress: progress)
                }, completion: { [weak self] (image) in
                    DispatchQueue.main.async {
                        self?.videoThumbnailViewOutlet.image = image
                    }
            })
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.delegate = self
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(deleteOptions(_:)))
        longPress.minimumPressDuration = 1.0
        self.videoTappedButtonOutlet.addGestureRecognizer(longPress)

    }
    
    /// To handle double tap of cell
    ///
    /// - Parameter gesture: tap gesture
    @objc func deleteOptions(_ gesture: UILongPressGestureRecognizer){
        print("doubletapped")
        deleteDelegate?.deleteChatMessage(index: self.index, msg: self.msgVMObj.message)
    }
    
    @IBAction func forwardButtonAction(_ sender: UIButton) {
        self.videoTappedDelegate?.receivedVideoForwardClicked(self)
    }
    
    @IBAction func reloadButtonAction(sender: UIButton) {
        
    }
    
    @IBAction func openVideoButtonAction(_ sender: UIButton) {
        if let delegate = videoTappedDelegate {
            delegate.videoCellTapped(withVideoMVModal : msgVMObj)
        }
    }
    
    func wifiCheck() -> Bool {
        //Check current reachablity status
        //check network status given by user in Setting ..default is both
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let status = appdelegate.reachability.connection //Wifi or cell network
        guard let value = UserDefaults.standard.object(forKey: "Photos") as? Int else { return true }
        
        if value == 0 { // Never - 0
            return false
        }
        else if value == 1 { // WIFI - 1
            if status == .wifi {
                return true
            } else { return false }
        }
        else if value == 2 { // WIFI and Cell - 2
            if status == .none {
                return false
            } else {
                return true
            }
        }
        return false
    }
    
    private func showDownloading(withProgress progress : Progress) {
        let pgValue = progress.fractionCompleted
        if progress.fractionCompleted == 1 {
            self.progressRingOutlet.isHidden = true
        } else {
            self.progressRingOutlet.isHidden = false
            self.progressRingOutlet.startProgress(to: CGFloat(pgValue), duration: 1)
        }
    }
    
    private func downloadVideo(fromURL videoURL: URL) {
        let msgCopy = self.msgVMObj.message
        msgCopy.mediaStates = .downloading
        // After getting video from cache, changing the message status and starting upload.
        self.msgVMObj.updateMediaStates(forMessage: msgCopy, andDocID: self.chatDocID)
        let videoFetcher = VideoFetcher()
        let name  = arc4random_uniform(900000) + 100000
        let mediaName = "\(msgCopy.messageId)000\(name).mp4"
        
        videoFetcher.downloadAndSave(videoUrl: videoURL, fileName: mediaName, progress: { (progress) in
            DispatchQueue.main.async {
                self.showDownloading(withProgress : progress)
            }
        }, completionBlock: { (videoUrl) in
            let msgCopy = self.msgVMObj.message
            msgCopy.mediaStates = .downloaded
            msgCopy.mediaURL = videoUrl?.absoluteString
            // After getting video from cache, changing the message status and starting upload.
            self.msgVMObj.updateMediaStates(forMessage: msgCopy, andDocID: self.chatDocID)
        })
    }
}

extension VideoReceivedCollectionViewCell : JSQMessagesCollectionViewCellDelegate {
    func messagesCollectionViewCellDidTapAvatar(_ cell: JSQMessagesCollectionViewCell) {
    }
    
    func messagesCollectionViewCellDidTapMessageBubble(_ cell: JSQMessagesCollectionViewCell) {
        
    }
    
    func messagesCollectionViewCellDidTap(_ cell: JSQMessagesCollectionViewCell, atPosition position: CGPoint) {
        
    }
    
    func messagesCollectionViewCell(_ cell: JSQMessagesCollectionViewCell, didPerformAction action: Selector, withSender sender: Any) {
        if let collectionView = self.superview as? UICollectionView {
            if let indexPath = collectionView.indexPathForItem(at: self.center) {
                collectionView.delegate?.collectionView!(collectionView, performAction: action, forItemAt: indexPath, withSender: nil)
            }
        }
    }
    
    func messagesCollectionViewCellDidTapAccessoryButton(_ cell: JSQMessagesCollectionViewCell) {
        
    }
}

/// ReceivedVideoMediaItem inherites the JSQMessageMediaData properties
class ReceivedVideoMediaItem : NSObject, JSQMessageMediaData {
    
    /// Used for the instance of ReceivedVideoCell
    let videoCell = VideoReceivedCollectionViewCell(frame:CGRect(x: 0, y: 0, width: 290, height: 200))
    
    func mediaView() -> UIView? {
        return videoCell
    }
    
    func mediaPlaceholderView() -> UIView {
        return videoCell
    }
    
    func mediaViewDisplaySize() -> CGSize {
        return CGSize(width: 290, height: 200)
    }
    
    func mediaHash() -> UInt {
        return UInt(60000 + arc4random_uniform(1000))
    }
}
