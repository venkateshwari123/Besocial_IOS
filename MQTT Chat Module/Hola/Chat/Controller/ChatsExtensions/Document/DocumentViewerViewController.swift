//
//  DocumentViewerViewController.swift
//  MQTT Chat Module
//
//  Created by Sachin Nautiyal on 05/03/2018.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import EVURLCache
import WebKit


class DocumentViewerViewController: UIViewController {
    
    @IBOutlet weak var webViewProgressIndicatorOutlet: UIActivityIndicatorView!
    @IBOutlet weak var webViewOutlet: WKWebView!
    var docMVMObj : DocumentMessageViewModal!
    var isComingfromSetting = false
    var webURL:String?
    var titleName:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        webViewOutlet.navigationDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webViewOutlet.uiDelegate = self
        webViewOutlet.navigationDelegate = self
        if isComingfromSetting == false {
            if let fileName = docMVMObj.getFileName() {
                self.title = fileName
            }
            if let fileURL = docMVMObj.getFileURL() {
                self.setupDoc(withURL: fileURL)
            }
        }else {
             self.setupDoc(withURL: webURL!)
            self.title = titleName
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    func setupDoc(withURL docURL: String) {
        if let url = URL(string: docURL) {
            self.webViewProgressIndicatorOutlet.startAnimating()
            webViewOutlet.load(URLRequest(url: url))
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func openShareScreen(withData dataString: String) {
        let activityViewController = UIActivityViewController(activityItems: [dataString as NSString], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    //MARK:- Buttons Action
    @IBAction func shareButtonAction(_ sender: UIBarButtonItem) {
        if let fileURL = docMVMObj.getFileURL() {
            self.openShareScreen(withData: fileURL)
        }
    }
    
}

extension DocumentViewerViewController : WKUIDelegate, WKNavigationDelegate {
  
     func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
       self.webViewProgressIndicatorOutlet.stopAnimating()
     }
     
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.webViewProgressIndicatorOutlet.stopAnimating()
    }
}
