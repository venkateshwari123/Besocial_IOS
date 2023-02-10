
//
//  TermsAndConditions.swift
//  Shoppd
//
//  Created by 3Embed on 5/23/20.
//  Copyright © 2020 Nabeel Gulzar. All rights reserved.
//

import UIKit
import WebKit
struct InnerAttributes:Codable{
    let value:String
    let name:String
}
class TermsAndConditions: UIViewController,WKNavigationDelegate {

    lazy var webView: WKWebView = {
        let view = WKWebView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var urlString:String?
    var titleHeader:String?
    var loadSpecialData:InnerAttributes?
    var isTerms:displayType = .terms
   // let loginVM = LoginVM()
    
    /// Property for VC from Articles
    var bookMarkSelected:((String,Bool)->Void)?
    var value:String?
    var isBookMark:Bool = false
    
    enum displayType{
        case terms
        case privacy
        case blog
        case other
    }
    
    override func loadView() {
        super.loadView()
        navigationController?.navigationBar.isHidden = false
        
        webView.navigationDelegate = self
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if isTerms == .blog{
            navigationItem.rightBarButtonItems = [bookMarkButton,shareButton]
//            bookMarkButton.setBackgroundImage(UIImage(named: isBookMark ? "fillBookmark" : "emptyBookmark"), for: .normal, barMetrics: .default)
            bookMarkButton.image = UIImage(named: isBookMark ? "fillBookmark" : "emptyBookmark")
        }
        loadData()
         webView.allowsBackForwardNavigationGestures = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /*
         Bug Name:- network handling
         Refactor Date:- 20/04/21
         Refactor By  :- Nikunj C
         Description of Refactor:- check connectivity and show popup for no internet
         */
        
        Helper.checkConnectionAvaibility(view: self.view)
    }
    

    lazy var bookMarkButton:UIBarButtonItem = {
        let bookMark = UIBarButtonItem(image: UIImage(named: "emptyBookmark"), style: .plain, target: self, action: #selector(bookMarkAction(_:)))
        return bookMark
    }()
    
    lazy var shareButton:UIBarButtonItem = {
        let share = UIBarButtonItem(image: UIImage(named: "share_product"), style: .plain, target: self, action: #selector(shareButtonAction(_:)))
        return share
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        title = isTerms  == .terms ? "Terms & Conditions" : isTerms  == .privacy ? "Privacy Policies" : loadSpecialData?.name ?? titleHeader ?? ""
        Helper.addShadowToNavigationBar(controller: navigationController!)
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "go-back-left-arrow")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "go-back-left-arrow")
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font:(UIFont(name: FontFamily.primary(.SemiBold).value, size: FontSize.standard(.h18).value)) ?? UIFont.systemFont(ofSize: 18),
            NSAttributedString.Key.foregroundColor:UIColor.Dark.black
        ]
    }
    
    @objc func shareButtonAction(_ share:UIBarButtonItem){
        let items: [Any] = [titleHeader ?? "", URL(string: urlString ?? "")!]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
    
    @objc func bookMarkAction(_ button:UIBarButtonItem){

    }
    
    func loadData(){
        if isTerms == .other,let htmlData = loadSpecialData{
            loadHtmlContent(htmlData:htmlData.value)
        }else if isTerms == .blog || isTerms == .other, let url = urlString{
            webView.load(url)
        }else{
//            loginVM.getTermsAndConditions { [weak self] login in
//                guard let self = self else{return}
//                if let login = login{
//                    self.loadHtmlContent(htmlData: self.isTerms == .terms ? login.data.termsObj : login.data.privacyObj)
//                }
//            }
        }
    }
    
    func loadHtmlContent(htmlData:String){
        let headerString = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>"
        webView.loadHTMLString(headerString + htmlData, baseURL: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension WKWebView {
    func load(_ urlString: String) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            load(request)
        }
    }
}
