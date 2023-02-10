//
//  CreateBusinessProfileViewController.swift
//  Starchat
//  jayaram G
//  Created by Rahul Sharma on 5/23/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G
import UIKit
class CreateBusinessProfileViewController: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var createNewAccountBtn: UIButton!
    @IBOutlet weak var pageControlOutlet: UIPageControl!
    @IBOutlet weak var collectionViewOutlet: UICollectionView!
    
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        uiDesign()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.layer.zPosition = 0;
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
    //MARK:- UI Design
    func uiDesign(){
        createNewAccountBtn.makeCornerRadious(readious: 20)
        createNewAccountBtn.setTitle("Create New Account".localized, for: .normal)
        navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: Strings.NavigationTitles.businessProfile.localized)
    }
    
    //MARK:- Button Actions
    
    /// Pushing To BusinessContactInfoViewController
    ///
    /// - Parameter sender: create business button
    @IBAction func creatNewBusinessAccountAction(_ sender: UIButton) {
        let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
        let businessContactVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.businessContactInfoViewControllerId) as! BusinessContactInfoViewController
        self.navigationController?.pushViewController(businessContactVc, animated: true)
    }
}


//MARK:- Extensions

// Collection View Extension

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout
extension CreateBusinessProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout{
    
    //No.Of Items
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    // cellForRow At Method
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AppConstants.CellIds.createBusinessCellId, for: indexPath) as! CreateBusinessCollectionViewCell
        switch indexPath.row {
        case 0:
            cell.optionsLabel.text = Strings.getNewContactOptions.localized
            cell.titleLabel.text = Strings.businessProfile.localized
            cell.headerImageView.image = #imageLiteral(resourceName: "Business a-c 1")
        case 1:
            cell.optionsLabel.text = Strings.learnAboutNewFollowers.localized
            cell.titleLabel.text = Strings.insights.localized
            cell.headerImageView.image =  #imageLiteral(resourceName: "Business a-c 2")
        case 2:
            cell.optionsLabel.text = Strings.postProductsAndServices.localized
            cell.titleLabel.text = Strings.productAndServices.localized
            cell.headerImageView.image = #imageLiteral(resourceName: "Business a-c 3")
        default:
            break
        }
        return cell
    }
    
    // collectionView layout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize{
        let itemSize:CGSize = CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
        return itemSize
    }
    
    // did select item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row{
        case 0:
            pageControlOutlet.currentPage = 1
            let indexPath = IndexPath(item: 1, section: 0)
            collectionViewOutlet.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        case 1:
            pageControlOutlet.currentPage = 2
            let indexPath = IndexPath(item: 2, section: 0)
            collectionViewOutlet.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        case 2:
            pageControlOutlet.currentPage = 0
            let indexPath = IndexPath(item: 0, section: 0)
            collectionViewOutlet.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        default:
            break
        }
    }
}

// MARK: - UIScrollViewDelegate
extension CreateBusinessProfileViewController:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.collectionViewOutlet{
            let content = self.collectionViewOutlet.contentOffset
            if content.x ==  self.view.frame.origin.x  {
                pageControlOutlet.currentPage = 0
            }else if  content.x ==  self.view.frame.origin.x + collectionViewOutlet.frame.width{
                pageControlOutlet.currentPage = 1
            }else if content.x == self.view.frame.origin.x + (2 * collectionViewOutlet.frame.width){
                pageControlOutlet.currentPage = 2
            }
        }
    }
    
    
    //    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    //        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
    //        self.pageControlOutlet.currentPage = Int(pageNumber)
    //    }
    //
    //    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    //        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
    //        self.pageControlOutlet.currentPage = Int(pageNumber)
    //    }
}
