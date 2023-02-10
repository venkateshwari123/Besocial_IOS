//
//  AboutViewController.swift
//  Starchat
//
//  Created by Rahul Sharma on 4/19/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G

import UIKit
import WebKit
class AboutViewController: UIViewController,WKNavigationDelegate {
    
    //MARK:- Variables
    var i:Int!
    
    //MARK:- Outlets
    @IBOutlet weak var webView: WKWebView!
    
    //MARK:-View Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        webView.navigationDelegate = self
        LoadingWebView()
        
        
    }
    
    
    
    /// Loading Web View
    func LoadingWebView(){
        Helper.showPI()
        switch i {
        case 1: // about page
            let url = URL(string: AppConstants.About)
            let request = URLRequest(url: url!)
            navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: Strings.about.localized)
            webView.load(request)
            
        case 2: // privacy and policy
            let url = URL(string: AppConstants.PrivacyPolicy)
            let request = URLRequest(url: url!)
            webView.load(request)
            navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: Strings.NavigationTitles.privacyPolicy.localized)
            
        case 3: // terms and conditions
            let url = URL(string: AppConstants.termsConditionUrl)
            let request = URLRequest(url: url!)
            webView.load(request)
            navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: Strings.NavigationTitles.termsAndConditions.localized)
        case 4: // general
            let url = URL(string: AppConstants.general)
            let request = URLRequest(url: url!)
            webView.load(request)
            navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: Strings.NavigationTitles.general.localized)
        case 5: // help and feedback
            let url = URL(string: AppConstants.helpAndFeedback)
            let request = URLRequest(url: url!)
            webView.load(request)
            navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: Strings.NavigationTitles.helpAndFeedBack.localized)
        case 6: // services
            let url = URL(string: AppConstants.servicesUrl)
            let request = URLRequest(url: url!)
            webView.load(request)
            navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: Strings.NavigationTitles.services.localized)
        case 7: // payment security
            let url = URL(string: AppConstants.paymentSecurity)
            let request = URLRequest(url: url!)
            webView.load(request)
            navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: Strings.NavigationTitles.paymentSecurity.localized)
        case 8: // Help Center
            let url = URL(string: AppConstants.paymentHelpCenter)
            let request = URLRequest(url: url!)
            webView.load(request)
            navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: Strings.NavigationTitles.helpCentre.localized)
        default:
            break
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Helper.hidePI()

    }
     
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Helper.hidePI()
    }
    
    
    
    
    //MARK:-Button Actions
    
    /// popping to ViewController
    ///
    /// - Parameter sender: BackButton
    @IBAction func backToServiceVc(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

