//
//  AudioSentCollectionViewCell.swift
//  MQTT Chat Module
//
//  Created by Sachin Nautiyal on 26/02/2018.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import JSQMessagesViewController

protocol AudioPlayerDelegate {
    func playing(withInstance : AudioPlayerManager, playButton: UIButton)
    func audioForwardActionCliked(_ cell:AudioSentCollectionViewCell)
    func receiveAudioForwardActionClicked(_ cell:AudioReceivedCollectionViewCell)
}

class AudioSentCollectionViewCell: JSQMessagesCollectionViewCell {
    
    @IBOutlet weak var playButtonOutlet: UIButton!
    @IBOutlet weak var audioProgressOutlet: UIProgressView!
    @IBOutlet weak var forwardButtonOutlet: UIButton!
    
    @IBOutlet weak var deleteBtnOutlet: UIButton!
    @IBOutlet weak var senderImageView: UIImageView!
    
    var audioPlayer = AudioPlayerManager()
    var chatDocID : String!
    var isGroup: Bool = false
    var groupMembers:[[String:Any]]?
    var gpImage:String?
    var deleteDelegate: DeleteChatMessageCellDelegate? = nil
    var index = IndexPath()
    
    var msgObj : Message! {
        didSet {
            self.audioPlayer.setMaximumVolume()
        }
    }
    var audioPlayerDelegate : AudioPlayerDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.delegate = self
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(deleteOptions(_:)))
        longPress.minimumPressDuration = 1.0
        self.deleteBtnOutlet.addGestureRecognizer(longPress)

    }
    
    /// To handle double tap of cell
    ///
    /// - Parameter gesture: tap gesture
    @objc func deleteOptions(_ gesture: UILongPressGestureRecognizer){
        print("doubletapped")
        deleteDelegate?.deleteChatMessage(index: self.index, msg: self.msgObj)
    }
    
    func startPlaying(withURL audioURL : String) {
        
        self.audioPlayerDelegate?.playing(withInstance: self.audioPlayer, playButton: self.playButtonOutlet)
        Utility.setSessionPlayerOn()
        //        self.audioPlayer.play(urlString : audioURL)
        self.playdownload(strUrl: audioURL)
        print("play audio URL \(audioURL)")
        
        self.audioPlayer.addPlayStateChangeCallback(self, callback: { [weak self] (track: AudioTrack?) in
            self?.updateButtonStates()
            self?.updatePlaybackTime(track)
            
        })
        self.audioPlayer.addPlaybackTimeChangeCallback(self, callback: { [weak self] (track: AudioTrack?) in
            DispatchQueue.main.async {
                self?.updatePlaybackTime(track)
            }
        })
    }
    
    func playdownload(strUrl: String) {
        
        guard let url = self.getAudioUrl(strUrl: strUrl) else{return}
        self.audioPlayer.play(url: url)
        
    }
    
    private func getAudioUrl(strUrl: String) -> URL?{
        if let audioUrl = URL(string: strUrl) {
            
            // then lets create your document folder url
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            
            //let url = Bundle.main.url(forResource: destinationUrl, withExtension: "mp3")!
            
            return destinationUrl
        }else{
            return nil
        }
    }
    
    
    func playAudioInitially(withAudioURL audURL : String) {
        guard let url = self.getAudioUrl(strUrl: audURL) else{return}
        let playerPlaying = audioPlayer.isPlaying(url: url)
        if playerPlaying {
            audioPlayer.togglePlayPause()
        } else {
            self.startPlaying(withURL: audURL)
        }
    }
    
    private func updateButtonStates() {
        print("is playing  \(audioPlayer.isPlaying())")
        self.playButtonOutlet?.isSelected = audioPlayer.isPlaying()
        //self.playButtonOutlet.isSelected = false
    }
    
    private func updatePlaybackTime(_ track: AudioTrack?) {
        self.audioProgressOutlet.progress = track?.currentProgress() ?? 0
    }
    
    @IBAction func playButtonAction(_ sender: UIButton) {
        
        if let audioURL = msgObj.messagePayload {
            if audioURL.count>0 {
                self.downloadFile(stringUrl: audioURL)
//                self.playAudioInitially(withAudioURL : audioURL)
            } else if let audioURL = msgObj.mediaURL {
                self.playAudioInitially(withAudioURL : audioURL)
            }
        }
    }
    
    @IBAction func forwardButtonAction(_ sender: UIButton) {
        self.audioPlayerDelegate?.audioForwardActionCliked(self)
    }
    
    
    func downloadFile(stringUrl: String) {
        
        if let audioUrl = URL(string: stringUrl) {
            
            // then lets create your document folder url
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            print(destinationUrl)
            
            // to check if it exists before downloading it
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                print("The file already exists at path")
                self.playButtonOutlet.isSelected = !self.playButtonOutlet.isSelected
                self.playAudioInitially(withAudioURL : destinationUrl.path)
                // if the file doesn't exist
            } else {
                
                // you can use NSURLSession.sharedSession to download the data asynchronously
                Helper.showPI(_message: "Downloading".localized + "...")
                URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) -> Void in
                    guard let location = location, error == nil else { return }
                    do {
                        // after downloading your file you need to move it to your destination url
                        try FileManager.default.moveItem(at: location, to: destinationUrl)
                        print("File moved to documents folder")
                        DispatchQueue.main.async{
                            Helper.hidePI()
                        }
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }).resume()
            }
        }
        
    }
}

extension AudioSentCollectionViewCell : JSQMessagesCollectionViewCellDelegate {
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

/// SentAudioMediaItem inherites the JSQMessageMediaData properties
class SentAudioMediaItem : NSObject, JSQMessageMediaData {
    
    /// Used for the instance of SentLocationCell
    let audioCell = AudioSentCollectionViewCell(frame:CGRect(x: 0, y: 0, width: 290, height: 50))
    
    func mediaView() -> UIView? {
        return audioCell
    }
    
    func mediaPlaceholderView() -> UIView {
        return audioCell
    }
    
    func mediaViewDisplaySize() -> CGSize {
        return CGSize(width: 290, height: 50)
    }
    
    func mediaHash() -> UInt {
        return UInt(60000 + arc4random_uniform(1000))
    }
}
