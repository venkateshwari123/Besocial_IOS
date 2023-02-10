//
//  GifStickerCollectionViewController.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 13/12/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher

let kGiphyPublicAPIKey = "gH9jtlC5lOhna"


protocol giphyDelegate {
    
    func didSendGiphyCliked(_ url:URL )
    func didSendStickerCliked(_ url:URL )
}

class GifStickerCollectionViewController: UIViewController {
    @IBOutlet weak var giphyCollectionView: UICollectionView!
    var giphyUrls = [URL?]()
    var isGiphy:Bool?
    var giphy : Giphy?
    var selectIndex:Int?
    var delegate:giphyDelegate?
    
    @IBOutlet weak var gifsearchBar: UISearchBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        giphyCollectionView.delegate = self
        giphyCollectionView.dataSource = self
        
        gifsearchBar.delegate = self
        self.gifsearchBar.placeholder = self.isGiphy! ? "Search".localized + " " + "Giphy".localized : "Search".localized + " " + "Stickers".localized
        giphy = Giphy.init(apiKey:kGiphyPublicAPIKey)
        self.getTrendingGiphys()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    
    //search Giphy here
    
    func getTrendingGiphys(){
        giphy?.trending(nil, offset: nil, rating: nil, isGiphy: isGiphy!) { gifs, pagination, err in
            DispatchQueue.main.async {
                guard let gifarr = gifs else {return}
                self.giphyUrls.removeAll()
                for git in gifarr {
                    let gitff = git.gifMetadataForType(.FixedHeight, still: !(self.isGiphy!))
                    self.giphyUrls.append(gitff.URL)
                }
                self.giphyCollectionView.reloadData()
            }
        }
    }
}


extension GifStickerCollectionViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return giphyUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gifStickerCell", for: indexPath) as! GitStickerCollectionViewCell
        cell.setCell()
        
        let url = giphyUrls[indexPath.row]
        if url == nil {
            cell.stickerImageView.image = #imageLiteral(resourceName: "Default logo")
        }else {
            cell.stickerImageView.kf.setImage(with:url , placeholder: #imageLiteral(resourceName: "Default logo") , options: [.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: { (image, error, CacheType, url) in
                
                if image == nil{cell.stickerImageView.image = #imageLiteral(resourceName: "Default logo")}else{cell.stickerImageView.image = image}
            })
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        view.backgroundColor = UIColor.black
        view.tag = 111
        
        let imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 64, width:self.view.frame.size.width, height: self.view.frame.size.height - 64 - 64 ))
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        
        let url = giphyUrls[indexPath.row]
        imageView.kf.setImage(with:url , placeholder: #imageLiteral(resourceName: "Default logo") , options: [.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: { (image, error, CacheType, url) in
            if image == nil{imageView.image = #imageLiteral(resourceName: "Default logo")}else{imageView.image = image}
        })
        
        selectIndex = indexPath.row
        let cancelbtn = UIButton.init(frame: CGRect.init(x: 15, y: 30, width: 60, height: 40))
        cancelbtn.setTitle("Cancel".localized, for: .normal)
        cancelbtn.setTitleColor(UIColor.white, for: .normal)
        if #available(iOS 13.0, *) {
            cancelbtn.setTitleColor(UIColor.label, for: .highlighted)
        } else {
            cancelbtn.setTitleColor(UIColor.black, for: .highlighted)
            // Fallback on earlier versions
        }
        cancelbtn.addTarget(self, action: #selector(cancelCliked), for: .touchUpInside)
        view.addSubview(cancelbtn)
        
        let sendbtn = UIButton.init(frame: CGRect.init(x: self.view.frame.size.width - 15 - 60 , y: 30, width: 60, height: 40))
        sendbtn.setTitle("Send".localized, for: .normal)
        sendbtn.setTitleColor(UIColor.white, for: .normal)
        if #available(iOS 13.0, *) {
            sendbtn.setTitleColor(UIColor.label, for: .highlighted)
        } else {
            cancelbtn.setTitleColor(UIColor.black, for: .highlighted)
        }
        sendbtn.addTarget(self, action: #selector(sendCliked), for: .touchUpInside)
        view.addSubview(sendbtn)
        self.navigationController?.navigationBar.isHidden = true
        self.view.addSubview(view)
    }
    
    
    
    @objc func  collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if self.view.frame.size.width == 375 { return CGSize(width: self.view.frame.size.width/3 - 15, height: 90)  }else {
            return CGSize(width: self.view.frame.size.width/3 - 14, height: 87) } //110
    }
    
    
    @objc func cancelCliked(){
        self.navigationController?.navigationBar.isHidden = false
        let view = self.view.viewWithTag(111)
        view?.removeFromSuperview()
    }
    
    @objc func sendCliked(){
        self.navigationController?.navigationBar.isHidden = false
        let view = self.view.viewWithTag(111)
        let url = giphyUrls[selectIndex!]
        if isGiphy! {
            delegate?.didSendGiphyCliked(url!)
        } else {
            delegate?.didSendStickerCliked(url!)
        }
        view?.removeFromSuperview()
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}


extension GifStickerCollectionViewController: UISearchBarDelegate{
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.gifsearchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.gifsearchBar.showsCancelButton = false
        self.gifsearchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.gifsearchBar.showsCancelButton = false
        self.gifsearchBar.resignFirstResponder()
    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count == 0{
            self.getTrendingGiphys()
            return
        }
        
        
        let when = DispatchTime.now() + 2 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            // Your code with delay
            self.getSearchGiphys(searchText)
        }
    }
    
    func getSearchGiphys(_ searchText : String){
        giphy?.search(searchText, limit: 25, offset: nil, rating: nil, isGiphy: isGiphy!, completionHandler: { (gifs, pagination, error) in
            DispatchQueue.main.async {
                guard let gifarr = gifs else {return}
                self.giphyUrls.removeAll()
                for git in gifarr {
                    let gitff = git.gifMetadataForType(.FixedHeight , still: !(self.isGiphy!))
                    self.giphyUrls.append(gitff.URL)
                }
                self.giphyCollectionView.reloadData()
            }
        })
    }
    
    
}

