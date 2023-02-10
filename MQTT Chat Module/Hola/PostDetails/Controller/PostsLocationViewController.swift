//
//  PostsLocationViewController.swift
//  dub.ly
//
//  Created by 3Embed Software Tech Pvt Ltd on 08/01/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class PostsLocationViewController: UIViewController {

    
    @IBOutlet weak var postsLocationCollectionView: UICollectionView!
    @IBOutlet weak var placetypeLabel: UILabel!
    @IBOutlet weak var placeImageOutlet: UIImageView!

    
    @IBOutlet weak var noPostView: UIView!
    
    var placeName: String?
    var placeId:String = ""
    var lattitude: Double?
    var longitude: Double?
    var isPresented: Bool = false
    var placeType:String = ""
    var placeImage:UIImage?


    
    var postsLocationViewModel = PostsLocationViewModel()
    var canServiceCall: Bool = false
    
    struct cellIdentifier {
        static let postsLocationCollectionViewCell = "postsLocationCollectionViewCell"
        static let postedByCollectionCell = "postedByCollectionCell"
    }
    
    struct storyboardId {
        static let LocationViewerViewController = "LocationViewerViewController"
    }
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = placeName
        
        placetypeLabel.text = placeType
        placeImageOutlet.makeImageCornerRadius(placeImageOutlet.frame.size.width/2)
        if placeImage != nil {
            placeImageOutlet.image = placeImage
        }else {
            placeImageOutlet.image = #imageLiteral(resourceName: "searchLocation")
        }
        self.navigationController?.navigationBar.tintColor = .black
        self.getPostByLocationService()
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
    
    /// To hide and unhide no post view
    private func setNoPostViewUI(){
        self.noPostView.isHidden = (self.postsLocationViewModel.postedByArray.count == 0) ? false : true
    }
    
    @objc func onMapClicked(){
        let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.chat, bundle: nil)
        guard let locationViewerVC = mainStoryboard.instantiateViewController(withIdentifier: storyboardId.LocationViewerViewController) as? LocationViewerViewController else{return}
        let locationString = "(\(lattitude!),\(longitude!))@@\(placeName!)@@"
        locationViewerVC.currentLatLong = locationString
        self.navigationController?.pushViewController(locationViewerVC, animated: true)
    }
    
    
    @IBAction func viewInfoBtnAction(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let placeInfo = mainStoryboard.instantiateViewController(withIdentifier: "PlaceInfoViewController") as? PlaceInfoViewController else{return}
        placeInfo.place = self.placeName ?? ""
        placeInfo.placeInfo = self.placeType
        self.navigationController?.pushViewController(placeInfo, animated: true)
    }
    
    //MARK:- Button Action
    
    @IBAction func backButtonAction(_ sender: Any) {
        if isPresented{
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK:- Service call
    func getPostByLocationService(){
        postsLocationViewModel.getPostedByService(place: self.placeId) { (success, error, canServiceCall) in
            if success{
                self.setNoPostViewUI()
                self.postsLocationCollectionView.reloadData()
            }else if let error = error{
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
                self.postsLocationViewModel.offset = self.postsLocationViewModel.offset - 20
            }
            self.canServiceCall = canServiceCall
        }
    }

}

//MARK:- Collection view datasource and delegate
extension PostsLocationViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else{
            return self.postsLocationViewModel.postedByArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier.postsLocationCollectionViewCell, for: indexPath) as? PostsLocationCollectionViewCell else { fatalError() }
            cell.setMapViewData(lattitude: self.lattitude, longitude: self.longitude)
            let singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onMapClicked))
            cell.mapView.addGestureRecognizer(singleTapRecognizer)
            return cell
        }else{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier.postedByCollectionCell, for: indexPath) as? PostedByCollectionViewCell else { fatalError() }
            let data = self.postsLocationViewModel.postedByArray[indexPath.item]
            cell.setCellDataFrom(modelData: data)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.section == 1{
            let indexPassed: Bool = indexPath.item >= self.postsLocationViewModel.postedByArray.count - 10
            if canServiceCall && indexPassed{
                canServiceCall = false
                getPostByLocationService()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = self.view.frame.size.width
        if indexPath.section == 0{
            return CGSize(width: width, height: 120)
        }
        return Utility.makePostsSize(frame: self.view.frame)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0{
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        return UIEdgeInsets(top: 2, left: 2, bottom: 0, right: 2)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if AppConstants.appType == .picoadda {
            Route.navigateToInstaDetailsVc(navigationController: self.navigationController, postsArray: self.postsLocationViewModel.postedByArray, needToCallApi: false, postId: nil)
        }else{
            Route.navigateToAllPostsVertically(navigationController: self.navigationController,postsArray:self.postsLocationViewModel.postedByArray,selectedIndex: indexPath.item ,isCommingFromChat:true,isFromProfilePage:true,delegate:self)

        }
    }
}

//MARK:- Post details view controller delegate
extension PostsLocationViewController: PostDetailsViewControllerDelegate{
    
    func homeDataChanged() {
        self.getPostByLocationService()
    }
}
