//
//  DocumentSentCollectionViewCell.swift
//  MQTT Chat Module
//
//  Created by Sachin Nautiyal on 28/02/2018.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Kingfisher
import EVURLCache
import WebKit
class RepliedDocumentSentCollectionViewCell: JSQMessagesCollectionViewCell {
    
    @IBOutlet weak var replyViewOutlet: ReplyView!
    @IBOutlet weak var fileTypeLabelOutlet: UILabel!
    @IBOutlet weak var webViewOutlet: WKWebView! {
        didSet {
            self.webViewOutlet.navigationDelegate = self
            self.progressIndicatorOutlet.hidesWhenStopped = true
        }
    }
    @IBOutlet weak var progressIndicatorOutlet: UIActivityIndicatorView!
    @IBOutlet weak var fileTypeImageOutlet: UIImageView!
    @IBOutlet weak var fileTitleLabelOutlet: UILabel!
    @IBOutlet weak var senderImageView: UIImageView!
    
    var documentMessageDelegate : DocumentMessageDelegate? = nil
    var chatDocID : String!
    var deleteDelegate: DeleteChatMessageCellDelegate? = nil
    var index = IndexPath()
    var documentMVMObj : DocumentMessageViewModal! {
        didSet {
            self.setupDoc(withDocMVMObj: documentMVMObj)
            replyViewOutlet.selectedMessage = documentMVMObj.message
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
    }
    
    func setupDoc(withDocMVMObj docMVMObj: DocumentMessageViewModal) {
        if let fileURL = docMVMObj.getFileURL() {
            self.setupDoc(withURL: fileURL)
        }
        
        if let fileName = docMVMObj.getFileName() {
            self.fileTitleLabelOutlet.text = fileName
        }
        
        if let fileExtension = docMVMObj.getDocTypeText() {
            self.fileTypeLabelOutlet.text = fileExtension
        }
        self.fileTypeImageOutlet.image = docMVMObj.getDocTypeImage()
    }
    
    func setupDoc(withURL docURL: String) {
        if let url = URL(string: docURL) {
            self.progressIndicatorOutlet.startAnimating()
            webViewOutlet.load(URLRequest(url: url))
        }
    }
    
    @IBAction func documentViewAction(_ sender: UIButton) {
        if (documentMessageDelegate != nil) {
            self.documentMessageDelegate?.openDocumentDelegate(withDocumentVMObj : documentMVMObj)
        }
    }
}

extension RepliedDocumentSentCollectionViewCell : JSQMessagesCollectionViewCellDelegate {
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

extension RepliedDocumentSentCollectionViewCell : WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.progressIndicatorOutlet.stopAnimating()

    }
     
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.progressIndicatorOutlet.stopAnimating()
    }
    
}

/// RepliedSentDocumentMediaItem inherites the JSQMessageMediaData properties
class RepliedSentDocumentMediaItem : NSObject, JSQMessageMediaData {
    
    /// Used for the instance of SentDocument Cell
    let docCell = RepliedDocumentSentCollectionViewCell(frame:CGRect(x: 0, y: 0, width: 240, height: 260))
    
    func mediaView() -> UIView? {
        return docCell
    }
    
    func mediaPlaceholderView() -> UIView {
        return docCell
    }
    
    func mediaViewDisplaySize() -> CGSize {
        return CGSize(width: 240, height: 260)
    }
    
    func mediaHash() -> UInt {
        return UInt(60000 + arc4random_uniform(1000))
    }
}
