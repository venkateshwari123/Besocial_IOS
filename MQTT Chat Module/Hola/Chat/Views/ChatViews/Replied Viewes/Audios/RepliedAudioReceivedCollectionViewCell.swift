//
//  AudioReceivedCollectionViewCell.swift
//  MQTT Chat Module
//
//  Created by Sachin Nautiyal on 26/02/2018.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import JSQMessagesViewController

class RepliedAudioReceivedCollectionViewCell: JSQMessagesCollectionViewCell {
    
    @IBOutlet var audioTappedButtonOutlet: UIButton!
    @IBOutlet weak var replyViewBtn: UIButton!
    @IBOutlet weak var progressBarOutlet: UIProgressView!
    @IBOutlet weak var replyViewOutlet: ReplyView!
    @IBOutlet weak var senderImageView: UIImageView!
    
    var audioPlayer = AudioPlayerManager()
    var chatDocID : String!
    var deleteDelegate: DeleteChatMessageCellDelegate? = nil
    var index = IndexPath()
    var audioPlayerDelegate : AudioPlayerDelegate? = nil
    
    var msgObj : Message! {
        didSet {
            replyViewOutlet.selectedMessage = msgObj
        }
    }
    
    var repliedButtonPressedDelegate : ReplyViewDismissDelegate? {
        didSet {
            replyViewOutlet.replyViewDismissDelegate = repliedButtonPressedDelegate
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.delegate = self
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(deleteOptions(_:)))
        longPress.minimumPressDuration = 1.0
        self.replyViewBtn.addGestureRecognizer(longPress)

    }
    
    /// To handle double tap of cell
    ///
    /// - Parameter gesture: tap gesture
    @objc func deleteOptions(_ gesture: UILongPressGestureRecognizer){
        print("doubletapped")
        deleteDelegate?.deleteChatMessage(index: self.index, msg: self.msgObj)
    }
    
    @IBAction func playAudioButtonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if let audioURL = msgObj.messagePayload {
            let playerPlaying = audioPlayer.isPlaying(url: URL(string: audioURL)!)
            if playerPlaying {
                audioPlayer.togglePlayPause()
            } else {
                self.startPlaying(withURL: audioURL)
            }
        }
    }
    
    func startPlaying(withURL audioURL : String) {
        self.audioPlayer.play(urlString : audioURL)
        self.audioPlayer.addPlayStateChangeCallback(self, callback: { [weak self] (track: AudioTrack?) in
            self?.updateButtonStates()
            self?.updatePlaybackTime(track)
        })
        self.audioPlayer.addPlaybackTimeChangeCallback(self, callback: { [weak self] (track: AudioTrack?) in
            DispatchQueue.main.async {
                self?.updatePlaybackTime(track)
            }
        })
        self.audioPlayerDelegate?.playing(withInstance: self.audioPlayer, playButton: self.audioTappedButtonOutlet)
    }
    
    private func updateButtonStates() {
        self.audioTappedButtonOutlet?.isSelected = audioPlayer.isPlaying()
    }
    
    private func updatePlaybackTime(_ track: AudioTrack?) {
        self.progressBarOutlet.progress = track?.currentProgress() ?? 0
    }
}

extension RepliedAudioReceivedCollectionViewCell : JSQMessagesCollectionViewCellDelegate {
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

/// RepliedReceivedAudioMediaItem inherites the JSQMessageMediaData properties
class RepliedReceivedAudioMediaItem : NSObject, JSQMessageMediaData {
    
    /// Used for the instance of ReceivedAudioCell
    let audioCell = RepliedAudioReceivedCollectionViewCell(frame:CGRect(x: 0, y: 0, width: 240, height: 106))
    
    func mediaView() -> UIView? {
        return audioCell
    }
    
    func mediaPlaceholderView() -> UIView {
        return audioCell
    }
    
    func mediaViewDisplaySize() -> CGSize {
        return CGSize(width: 240, height: 106)
    }
    
    func mediaHash() -> UInt {
        return UInt(60000 + arc4random_uniform(1000))
    }
}
