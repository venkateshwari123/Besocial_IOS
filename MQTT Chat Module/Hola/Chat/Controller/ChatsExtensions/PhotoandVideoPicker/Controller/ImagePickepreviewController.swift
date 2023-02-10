//
//  ImagePickepreviewController.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 12/12/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import Photos
import TLPhotoPicker

fileprivate let filterNameList = [
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

fileprivate let filterDisplayNameList = [
    "Normal",
    "Chrome",
    "Fade",
    "Instant",
    "Mono",
    "Noir",
    "Process",
    "Tonal",
    "Transfer",
    "Tone",
    "Linear"
]


protocol ImagepreviewDelegate {
    func didCancelCliked()
    func didSendCliked(medias:[Any])
}

let ImagePreviewCollectionViewTag = 25
let filterCollectionViewTag = 26

class ImagePickepreviewController: UIViewController {
    
    @IBOutlet weak var imgPreviewCollectionView: UICollectionView!
    @IBOutlet weak var filterCollectionView: UICollectionView!
    @IBOutlet weak var thumbNailView: UIView!
    @IBOutlet weak var thumbnailCollectionView: UICollectionView!
    @IBOutlet weak var colorsCollectionView: UICollectionView!
    @IBOutlet weak var colorPickerView: UIView!
    @IBOutlet weak var colorPickerViewBottomConstraint: NSLayoutConstraint!
   //  var colorsCollectionViewDelegate: ColorsCollectionViewDelegate!
    
    var delegate:ImagepreviewDelegate?
    fileprivate var filterImage: UIImage?
    fileprivate let context = CIContext(options: nil)
    fileprivate var smallImage: UIImage?
    @IBOutlet weak var thumbViewHeight: NSLayoutConstraint!
    
    
    public var colors  : [UIColor] = []
    var drawColor: UIColor = UIColor.black
    var isDrawing: Bool = false
    var textColor: UIColor = UIColor.white
     var activeTextView: UITextView?
    var swiped = false
    var isComingFromCamera = false
    
    
    var stickersVCIsVisible = false
    var lastPoint: CGPoint!
    var lastPanPoint: CGPoint?
    var lastTextViewTransform: CGAffineTransform?
    var lastTextViewTransCenter: CGPoint?
    var lastTextViewFont:UIFont?
    var imageViewToPan: UIImageView?
    var isTyping: Bool = false
    
    
    
    var imageArray  = [Any]()
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imgPreviewCollectionView.delegate = self
        imgPreviewCollectionView.dataSource = self
        thumbnailCollectionView.delegate = self
        thumbnailCollectionView.dataSource = self
        filterCollectionView.dataSource = self
        filterCollectionView.delegate = self
        self.imgPreviewCollectionView.reloadData()
        self.thumbnailCollectionView.reloadData()
        
        self.filterCollectionView.isHidden = true
        self.filterCollectionView.tag = filterCollectionViewTag
        let  swipeGester = UISwipeGestureRecognizer.init(target: self, action: #selector(swipeGesterCliked))
        swipeGester.direction = .up
        self.imgPreviewCollectionView.addGestureRecognizer(swipeGester)
        
        // colorsCollectionView.isHidden = true
        //self.configureCollectionViewForColour()
        
    }
    
    
    @objc func swipeGesterCliked(j : UISwipeGestureRecognizer){
        self.imgPreviewCollectionView.isScrollEnabled = false
        thumbnailCollectionView.isHidden = true
        colorsCollectionView.isHidden = true
        thumbViewHeight.constant = 120
        
        if let tplAssets =  imageArray[(self.imgPreviewCollectionView.indexPathsForVisibleItems.last?.row)!] as? TLPHAsset{
            filterImage = tplAssets.fullResolutionImage
        }else {
            if let img = imageArray[(self.imgPreviewCollectionView.indexPathsForVisibleItems.last?.row)!] as? UIImage{
                filterImage = img
            }
        }
        
        smallImage = resizeImage(image: filterImage!)
        self.filterCollectionView.isHidden = false
        self.filterCollectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func cancelButtonCliked(_ sender: Any) {
        self.delegate?.didCancelCliked()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonCliked(_ sender: Any) {
        self.delegate?.didSendCliked(medias: imageArray)
       // self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cutButtonCliked(_ sender: Any) {
        let controller = ImageCropViewController()
        controller.delegate = self
        if let tplAssets =  imageArray[(self.imgPreviewCollectionView.indexPathsForVisibleItems.last?.row)!] as? TLPHAsset{
            controller.image = tplAssets.fullResolutionImage
        }else {
            if let img = imageArray[(self.imgPreviewCollectionView.indexPathsForVisibleItems.last?.row)!] as? UIImage{
                controller.image = img
            }
        }
        let navController = UINavigationController(rootViewController: controller)
        present(navController, animated: true, completion: nil)
    }
    
    @IBAction func deleteButtonCliked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func rotateImagecliked(_ sender: Any) {
        var originalIMg : UIImage?
        if let tplAssets =  imageArray[(self.imgPreviewCollectionView.indexPathsForVisibleItems.last?.row)!] as? TLPHAsset{
            originalIMg = tplAssets.fullResolutionImage
        }else {
            if let img = imageArray[(self.imgPreviewCollectionView.indexPathsForVisibleItems.last?.row)!] as? UIImage{
                originalIMg = img
            }
        }
        var imageee : UIImage?
        if originalIMg?.imageOrientation == UIImage.Orientation.rightMirrored{
            imageee = UIImage.init(cgImage: (originalIMg?.cgImage)!, scale: 1.0, orientation: .downMirrored)
        }else if originalIMg?.imageOrientation == UIImage.Orientation.downMirrored{
            imageee = UIImage.init(cgImage: (originalIMg?.cgImage)!, scale: 1.0, orientation: .leftMirrored)
        }else if originalIMg?.imageOrientation == UIImage.Orientation.leftMirrored{
            imageee = UIImage.init(cgImage: (originalIMg?.cgImage)!, scale: 1.0, orientation: .upMirrored)
        }else if originalIMg?.imageOrientation == UIImage.Orientation.right{
            imageee = UIImage.init(cgImage: (originalIMg?.cgImage)!, scale: 1.0, orientation: .down)
        }else if originalIMg?.imageOrientation == UIImage.Orientation.down{
            imageee = UIImage.init(cgImage: (originalIMg?.cgImage)!, scale: 1.0, orientation: .left)
        }else if originalIMg?.imageOrientation == UIImage.Orientation.left{
            imageee = UIImage.init(cgImage: (originalIMg?.cgImage)!, scale: 1.0, orientation: .up)
        }else if originalIMg?.imageOrientation == UIImage.Orientation.up{
            imageee = UIImage.init(cgImage: (originalIMg?.cgImage)!, scale: 1.0, orientation: .right)
        }else {
            imageee = UIImage.init(cgImage: (originalIMg?.cgImage)!, scale: 1.0, orientation: .rightMirrored)
        }
        let index = self.imgPreviewCollectionView.indexPathsForVisibleItems.last!
        self.imageArray.remove(at: (index.row))
        self.imageArray.insert(imageee, at: (index.row))
        self.imgPreviewCollectionView.reloadItems(at: [index])
    }
    
    
    @IBAction func editBtnCliked(_ sender: Any) {
        
        let photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController",bundle: Bundle(for: PhotoEditorViewController.self))
        if let tplAssets =  imageArray[(self.imgPreviewCollectionView.indexPathsForVisibleItems.last?.row)!] as? TLPHAsset{
            photoEditor.image = tplAssets.fullResolutionImage
        }else {
            if let img = imageArray[(self.imgPreviewCollectionView.indexPathsForVisibleItems.last?.row)!] as? UIImage{
                photoEditor.image = img
            }
        }
        photoEditor.photoEditorDelegate = self
        for i in 0...10 {
            photoEditor.stickers.append(UIImage(named: i.description )!)
        }
        photoEditor.hiddenControls = [.share]
        photoEditor.isPresented = true
        /* Bug Name :  SINGLE CHAT While sharing images , images can be edited
         the push the chat details page should open"
         Fix Date : 12-apr-2021
         Fixed By : Jayaram G
         Description Of Fix : Presenting the view in fullscreen
         */
        photoEditor.modalPresentationStyle = .fullScreen
        present(photoEditor, animated: true, completion: nil)
    }
}



//MARK:- CollectionView delegates
extension ImagePickepreviewController : UICollectionViewDelegate ,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    @objc func  collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView.tag == filterCollectionViewTag {
            return CGSize.init(width: 100, height: 120)
        }else if collectionView.tag == ImagePreviewCollectionViewTag{
            return CGSize.init(width: self.view.frame.size.width - 4 , height: self.imgPreviewCollectionView.frame.size.height - 20 )
        }
        else {
            return CGSize.init(width: 56, height: 56)
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        
        if collectionView.tag == filterCollectionViewTag {
            return UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        }else if collectionView.tag == ImagePreviewCollectionViewTag{
            
            return UIEdgeInsets.init(top: 0, left: 0, bottom:0, right: 0)
        }
        else {
            return UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        }
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if  collectionView.tag == 25 {
            return   imageArray.count
        }else if collectionView.tag == filterCollectionViewTag{
            return filterNameList.count
        }
        else{
            if isComingFromCamera == true{
                return imageArray.count
            }else {
                return imageArray.count + 1}
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 25{
            let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "mainImageViewCell", for: indexPath) as! MainImagePickerCell
            imageCell.setMainImage(image:imageArray[indexPath.row] as Any)
            return imageCell
        }else if collectionView.tag == filterCollectionViewTag{
            let filterCell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterCollectionviewCell", for: indexPath) as! FilterCollectionViewCell
            if var filterImg = smallImage{
                if indexPath.row != 0 {
                    filterImg = createFilteredImage(filterName: filterNameList[indexPath.row], image: filterImg)
                    filterCell.filterImageView.image = filterImg}else {filterCell.filterImageView.image = smallImage}
            }
            return filterCell
        }
        else{
            let thumbCell = collectionView.dequeueReusableCell(withReuseIdentifier: "thumnailCell", for: indexPath) as! ThumbImagePickerCell
            if indexPath.row == imageArray.count {
                thumbCell.thumbImage.image = #imageLiteral(resourceName: "addMoreImg")
            }else{
                thumbCell.setThumbImage(image: imageArray[indexPath.row] as Any) }
            return thumbCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.tag == 25 {
            thumbViewHeight.constant = 65
            thumbnailCollectionView.isHidden = false
            self.imgPreviewCollectionView.isScrollEnabled = true
            self.filterCollectionView.isHidden = true
            
        }else if collectionView.tag == filterCollectionViewTag{
            let index = self.imgPreviewCollectionView.indexPathsForVisibleItems.last!
            if let img = filterImage {
                if indexPath.row == 0{
                    self.imageArray.remove(at: (index.row))
                    self.imageArray.insert(img, at: (index.row))
                }else {
                    let filterName = filterNameList[indexPath.row]
                    let filteredImage = createFilteredImage(filterName: filterName, image: img)
                    self.imageArray.remove(at: (index.row))
                    self.imageArray.insert(filteredImage, at: (index.row))
                }
                self.imgPreviewCollectionView.reloadItems(at: [index])
            }
        }else {
            if indexPath.row == imageArray.count {
                self.dismiss(animated: true, completion: nil)
            }else{
                self.imgPreviewCollectionView.scrollToItem(at: indexPath, at: .left, animated: true)
            }
        }
    }
    
    
    /*creat filter Image here*/
    func createFilteredImage(filterName: String, image: UIImage) -> UIImage {
        // 1 - create source image
        let sourceImage = CIImage(image: image)
        
        // 2 - create filter using name
        let filter = CIFilter(name: filterName)
        filter?.setDefaults()
        
        // 3 - set source image
        filter?.setValue(sourceImage, forKey: kCIInputImageKey)
        
        // 4 - output filtered image as cgImage with dimension.
        let outputCGImage = context.createCGImage((filter?.outputImage!)!, from: (filter?.outputImage!.extent)!)
        
        // 5 - convert filtered CGImage to UIImage
        let filteredImage = UIImage(cgImage: outputCGImage!)
        
        return filteredImage
    }
    
    
    func resizeImage(image: UIImage) -> UIImage {
        let ratio: CGFloat = 0.4
        let resizedSize = CGSize(width: Int(image.size.width * ratio), height: Int(image.size.height * ratio))
        UIGraphicsBeginImageContext(resizedSize)
        image.draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage!
    }
    
}



//MARK: - Crop image delegate
extension ImagePickepreviewController: ImageCropViewControllerDelegate{
    
    public func cropViewController(_ controller: ImageCropViewController, didFinishCroppingImage image: UIImage, transform: CGAffineTransform, cropRect: CGRect) {
        
        let index = self.imgPreviewCollectionView.indexPathsForVisibleItems.last!
        self.imageArray.remove(at: (index.row))
        self.imageArray.insert(image, at: (index.row))
        self.imgPreviewCollectionView.reloadItems(at: [index])
        controller.dismiss(animated: true, completion: nil)
    }
    
    public func cropViewControllerDidCancel(_ controller: ImageCropViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}




//MARK: - Edit
extension ImagePickepreviewController: PhotoEditorDelegate {
    
    func doneEditing(image: UIImage) {
        let index = self.imgPreviewCollectionView.indexPathsForVisibleItems.last!
            self.imageArray.remove(at: (index.row))
            self.imageArray.insert(image, at: (index.row))
            self.imgPreviewCollectionView.reloadItems(at: [index])
    }
    
    func canceledEditing() {
        print("Canceled")
    }
}



