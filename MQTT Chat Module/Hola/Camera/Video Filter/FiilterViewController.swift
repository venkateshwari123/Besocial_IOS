//
//  FiilterViewController.swift
//  InstagramFilter
//
//  Created by James Fong on 2018-01-05.
//  Copyright © 2018 James Fong. All rights reserved.
//

import UIKit

class FiilterViewController: UIViewController {
    
    internal let filterNameList = [
        "No Filter",
        "CIPhotoEffectChrome",
        "CIPhotoEffectFade",
        "CIPhotoEffectInstant",
        "CIPhotoEffectMono",
        "CIPhotoEffectNoir",
        "CIPhotoEffectProcess",
        "CIPhotoEffectTonal",
        "CIPhotoEffectTransfer",
        "CILinearToSRGBToneCurve",
        "CISRGBToneCurveToLinear"
    ]
    
    internal let filterDisplayNameList = [
        "Normal".localized,
        "Chrome".localized,
        "Fade".localized,
        "Instant".localized,
        "Mono".localized,
        "Noir".localized,
        "Process".localized,
        "Tonal".localized,
        "Transfer".localized,
        "Tone".localized,
        "Linear".localized
    ]
    
    internal var filterIndex = -1
    internal let context = CIContext(options: nil)
    
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var collectionView: UICollectionView?
    internal var image: UIImage?
    internal var smallImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.register(VideoFilterCollectionViewCell.self, forCellWithReuseIdentifier: "VideoFilterCollectionViewCell")
        collectionView?.register(UINib.init(nibName: "VideoFilterCollectionViewCell", bundle:nil), forCellWithReuseIdentifier: "VideoFilterCollectionViewCell")
    }
    
    @IBAction func imageViewDidSwipeLeft() {
        if filterIndex == filterNameList.count - 1 {
            filterIndex = 0
            imageView?.image = image
        } else {
            filterIndex += 1
        }
        if filterIndex != 0 {
            applyFilter()
        }
        updateCellFont()
        scrollCollectionViewToIndex(itemIndex: filterIndex)
    }
    
    @IBAction func imageViewDidSwipeRight() {
        if filterIndex == 0 {
            filterIndex = filterNameList.count - 1
        } else {
            filterIndex -= 1
        }
        if filterIndex != 0 {
            applyFilter()
        } else {
            imageView?.image = image
        }
        updateCellFont()
        scrollCollectionViewToIndex(itemIndex: filterIndex)
    }
    
    func applyFilter() {
        let filterName = filterNameList[filterIndex]
        if let image = self.image {
            let filteredImage = createFilteredImage(filterName: filterName, image: image)
            imageView?.image = filteredImage
        }
    }
    
    func createFilteredImage(filterName: String, image: UIImage) -> UIImage {
       return UIImage()
    }
    
    func resizeImage(image: UIImage) -> UIImage {
        let ratio: CGFloat = 0.3
        let resizedSize = CGSize(width: Int(image.size.width * ratio), height: Int(image.size.height * ratio))
        UIGraphicsBeginImageContext(resizedSize)
        image.draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage ?? UIImage()
    }

}

extension FiilterViewController: UICollectionViewDataSource, UICollectionViewDelegate
{
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoFilterCollectionViewCell", for: indexPath) as! VideoFilterCollectionViewCell
        var filteredImage = smallImage
        if indexPath.row != 0 {
            filteredImage = createFilteredImage(filterName: filterNameList[indexPath.row], image: smallImage!)
        }
        cell.imageView.image = filteredImage
        cell.filterNameLabel.text = filterDisplayNameList[indexPath.row]
        if let initalCharacter = filterDisplayNameList[indexPath.row].first {
             cell.initialLabel.text = "\(initalCharacter)"
        }
        updateCellFont()
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterNameList.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if filterIndex != indexPath.row {
            filterIndex = indexPath.row
            applyFilter()
        } else {
            imageView?.image = image
        }
        updateCellFont()
        scrollCollectionViewToIndex(itemIndex: indexPath.item)
    }
    
    func updateCellFont() {
        // update font of selected cell
        if let selectedCell = collectionView?.cellForItem(at: IndexPath(row: filterIndex, section: 0)) {
            let cell = selectedCell as! VideoFilterCollectionViewCell
            cell.filterNameLabel.font = UIFont.boldSystemFont(ofSize: 14)
        }
        
        for i in 0...filterNameList.count - 1 {
            if i != filterIndex {
                // update nonselected cell font
                if let unselectedCell = collectionView?.cellForItem(at: IndexPath(row: i, section: 0)) {
                    let cell = unselectedCell as! VideoFilterCollectionViewCell
                    cell.filterNameLabel.font = UIFont.systemFont(ofSize: 14.0, weight:UIFont.Weight.thin)
                }
            }
        }
    }
    
    func scrollCollectionViewToIndex(itemIndex: Int) {
        let indexPath = IndexPath(item: itemIndex, section: 0)
        self.collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

