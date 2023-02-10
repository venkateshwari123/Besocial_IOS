//
//  DocumentMediaCollectionViewCell.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 17/04/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import UIKit
import WebKit
protocol DocumentMediaCollectionViewCellDelegate {
    func openDocument(urlStr: String)
}
class DocumentMediaCollectionViewCell: UICollectionViewCell,WKNavigationDelegate {
    
    @IBOutlet weak var webViewOutlet: WKWebView!
    
    var delegateObj:DocumentMediaCollectionViewCellDelegate? = nil
    
    var msgObject : Message! {
        didSet {
            if let tData = msgObject.messagePayload {
                DispatchQueue.global(qos: .default).async {
                    self.setupDoc(payload: tData)
                }
            }
        }
    }
    
    func setupDoc(payload: String) {
        if let fileURL = payload as? String{
            self.setupDoc(withURL: fileURL)
        }
        
    }
    
    func setupDoc(withURL docURL: String) {
        if let url = URL(string: docURL) {
            DispatchQueue.main.async {
                self.webViewOutlet.load(URLRequest(url: url))
            }
        }
    }
    
    
    @IBAction func openDocumentButtonAction(_ sender: Any) {
        self.delegateObj?.openDocument(urlStr: self.msgObject.messagePayload ?? "")
    }
}
