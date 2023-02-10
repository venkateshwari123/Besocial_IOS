//
//  FSAlbumVC.swift
//  YPImagePicker
//
//  Created by Sacha Durand Saint Omer on 27/10/16.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import UIKit
import Photos

@objc public protocol FSAlbumViewDelegate: class {
    func albumViewCameraRollUnauthorized()
    func albumViewStartedLoadingImage()
    func albumViewFinishedLoadingImage()
}

public class FSAlbumVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,
PHPhotoLibraryChangeObserver, UIGestureRecognizerDelegate {
    
    weak var delegate: FSAlbumViewDelegate?
    
    public var showsVideo = false
    var isFirstTime = true
    let myQueue = DispatchQueue(label: "com.octopepper.ypImagePicker.imagesQueue",
                                attributes: .concurrent)

    private var _images: PHFetchResult<PHAsset>?
    func getImages() -> PHFetchResult<PHAsset>? {
        return myQueue.sync { _images }
    }

    func setImages(_ newImages: PHFetchResult<PHAsset>, completion: () -> Void) {
        // Make sure writes blokc access
        // No reads can happen while the array is written :)
        myQueue.sync(flags: DispatchWorkItemFlags.barrier) {
            self._images = newImages
            completion()
        }
    }
    
    var imageManager: PHCachingImageManager?
    var previousPreheatRect: CGRect = CGRect.zero
    let cellSize = CGSize(width: UIScreen.main.bounds.width/4, height: UIScreen.main.bounds.width/4)
    var phAsset: PHAsset!
    
    // Variables for calculating the position
    enum Direction {
        case scroll
        case stop
        case up
        case down
    }
    let imageCropViewOriginalConstraintTop: CGFloat = 0
    let imageCropViewMinimalVisibleHeight: CGFloat  = 50
    var dragDirection = Direction.up
    var imaginaryCollectionViewOffsetStartPosY: CGFloat = 0.0
    
    var cropBottomY: CGFloat  = 0.0
    var dragStartPos: CGPoint = CGPoint.zero
    let dragDiff: CGFloat     = 0//20.0

    var _isImageShown = true
    var isImageShown: Bool {
        get { return self._isImageShown }
        set {
            if newValue != isImageShown {
                self._isImageShown = newValue
                v.imageCropViewContainer.isShown = newValue
                
                //Update imageCropContainer
                if isImageShown {
                    v.imageCropView.isScrollEnabled = true
                } else {
                   v.imageCropView.isScrollEnabled = false
                }
                
            }
        }
    }

    var v: FSAlbumView!
    
    public override func loadView() {
        let bundle = Bundle(for: self.classForCoder)
        let xibView = UINib(nibName: "FSAlbumView",
                            bundle: bundle).instantiate(withOwner: self,
                                                        options: nil)[0] as? FSAlbumView
        v = xibView
        view = v
    }
    
    convenience init() {
        self.init(nibName:nil, bundle:nil)
        title = "Library".localized
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        v.collectionView.dataSource = self
        v.collectionView.delegate = self
        self.navigationController?.navigationBar.tintColor = UIColor.black
        initialize()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let player = self.v.imageCropView.player, player.playbackState == .paused{
            DispatchQueue.main.async{
                player.play()
            }
            self.v.imageCropView.addPlayerOvserver()
        }
    }

    func initialize() {
        if getImages() != nil {
            return
        }
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panned(_:)))
        panGesture.delegate = self
        v.addGestureRecognizer(panGesture)
        
        v.collectionViewConstraintHeight.constant =
            v.frame.height - v.imageCropView.frame.height - imageCropViewOriginalConstraintTop
        v.imageCropViewConstraintTop.constant = 0
        dragDirection = Direction.up
        
        v.imageCropViewContainer.layer.shadowColor   = UIColor.black.cgColor
        v.imageCropViewContainer.layer.shadowRadius  = 30.0
        v.imageCropViewContainer.layer.shadowOpacity = 0.9
        v.imageCropViewContainer.layer.shadowOffset  = CGSize.zero
        
        v.collectionView.register(FSAlbumViewCell.self, forCellWithReuseIdentifier: "FSAlbumViewCell")
        
        // Never load photos Unless the user allows to access to photo album
        checkPhotoAuth()
        
//        refreshMediaRequest()

        let tapImageGesture = UITapGestureRecognizer(target: self, action: #selector(tappedImage))
        v.imageCropViewContainer.addGestureRecognizer(tapImageGesture)
                
        // FIX - Fixes collectionViewImage not appearing on first load
        let containerHeight = v.imageCropViewContainer.frame.height
        let height = v.frame.height
        v.collectionViewConstraintHeight.constant =
            height - imageCropViewOriginalConstraintTop - containerHeight
    }
    
    var collection: PHAssetCollection?
    
    func refreshMediaRequest() {
        
        // Sorting condition
        let options = PHFetchOptions()

        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            
            
            let completion = {
                DispatchQueue.main.async {
                    if let images = self.getImages(), images.count > 0 {
                        self.changeImage(images[0])
                        self.v.collectionView.reloadData()
                        self.v.collectionView.selectItem(at: IndexPath(row: 0, section: 0),
                                                         animated: false,
                                                         scrollPosition: UICollectionView.ScrollPosition())
                    }
                }
            }
            
            if let collection = self.collection {
                if !self.showsVideo {
                    options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
                }
                self.setImages(PHAsset.fetchAssets(in: collection, options: options), completion: completion)
            } else {
//              options.predicate = NSPredicate(format: "((mediaSubtype & %d) != 0)", PHAssetMediaSubtype.videoStreamed.rawValue)
                let newImages = self.showsVideo
                    ? PHAsset.fetchAssets(with: options)
                    : PHAsset.fetchAssets(with: PHAssetMediaType.image, options: options)
                self.setImages(newImages, completion: completion)
            }
        }
        PHPhotoLibrary.shared().register(self)
        
        scrollToTop()
    }
    
    func scrollToTop() {
        tappedImage()
        v.collectionView.contentOffset = CGPoint.zero
    }
    
    @objc func tappedImage() {
        if !isImageShown {
            v.imageCropViewConstraintTop.constant = imageCropViewOriginalConstraintTop
            v.collectionViewConstraintHeight.constant =
                v.frame.height - imageCropViewOriginalConstraintTop - v.imageCropViewContainer.frame.height
              DispatchQueue.main.async{
            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.v.layoutIfNeeded()
            }, completion: nil)
            }
            refreshImageCurtainAlpha()
        }
    }
    
    deinit {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            PHPhotoLibrary.shared().unregisterChangeObserver(self)
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith
                                  otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let p = gestureRecognizer.location(ofTouch: 0, in: v)
        // Desactivate pan on image when it is shown.
        if isImageShown {
            if p.y < v.imageCropView.frame.height {
                return false
            }
        }
        return true
    }
    
    @objc func panned(_ sender: UIPanGestureRecognizer) {
        
        let containerHeight = v.imageCropViewContainer.frame.height
        let height = v.frame.height
        
        if sender.state == UIGestureRecognizer.State.began {
            let view    = sender.view
            let loc     = sender.location(in: view)
            let subview = view?.hitTest(loc, with: nil)
            
            if subview == v.imageCropView
                && v.imageCropViewConstraintTop.constant == imageCropViewOriginalConstraintTop {
                return
            }
            
            dragStartPos = sender.location(in: v)
            cropBottomY = v.imageCropViewContainer.frame.origin.y + containerHeight
            
            // Move
            if dragDirection == Direction.stop {
                dragDirection = (v.imageCropViewConstraintTop.constant == imageCropViewOriginalConstraintTop)
                    ? Direction.up
                    : Direction.down
            }
            
            // Scroll event of CollectionView is preferred.
            if (dragDirection == Direction.up && dragStartPos.y < cropBottomY + dragDiff) ||
                (dragDirection == Direction.down && dragStartPos.y > cropBottomY) {
                dragDirection = Direction.stop
            }
        } else if sender.state == UIGestureRecognizer.State.changed {
            let currentPos = sender.location(in: v)
            if dragDirection == Direction.up && currentPos.y < cropBottomY - dragDiff {
                v.imageCropViewConstraintTop.constant =
                    max(imageCropViewMinimalVisibleHeight - containerHeight, currentPos.y + dragDiff - containerHeight)
                v.collectionViewConstraintHeight.constant =
                    min(height - imageCropViewMinimalVisibleHeight,
                        height - v.imageCropViewConstraintTop.constant - containerHeight)
            } else if dragDirection == Direction.down && currentPos.y > cropBottomY {
                v.imageCropViewConstraintTop.constant =
                    min(imageCropViewOriginalConstraintTop, currentPos.y - containerHeight)
                v.collectionViewConstraintHeight.constant =
                    max(height - imageCropViewOriginalConstraintTop - containerHeight,
                        height - v.imageCropViewConstraintTop.constant - containerHeight)
            } else if dragDirection == Direction.stop && v.collectionView.contentOffset.y < 0 {
                dragDirection = Direction.scroll
                imaginaryCollectionViewOffsetStartPosY = currentPos.y
            } else if dragDirection == Direction.scroll {
                v.imageCropViewConstraintTop.constant =
                    imageCropViewMinimalVisibleHeight - containerHeight
                    + currentPos.y - imaginaryCollectionViewOffsetStartPosY
                v.collectionViewConstraintHeight.constant =
                    max(height - imageCropViewOriginalConstraintTop - containerHeight,
                        height - v.imageCropViewConstraintTop.constant - containerHeight)
                
            }
        } else {
            imaginaryCollectionViewOffsetStartPosY = 0.0
            if sender.state == UIGestureRecognizer.State.ended && dragDirection == Direction.stop {
                return
            }
            let currentPos = sender.location(in: v)
            if currentPos.y < cropBottomY - dragDiff
                && v.imageCropViewConstraintTop.constant != imageCropViewOriginalConstraintTop {
                // The largest movement
                v.imageCropViewConstraintTop.constant =
                    imageCropViewMinimalVisibleHeight - containerHeight
                v.collectionViewConstraintHeight.constant = height - imageCropViewMinimalVisibleHeight
                  DispatchQueue.main.async{
                UIView.animate(withDuration: 0.3,
                               delay: 0.0,
                               options: UIView.AnimationOptions.curveEaseOut,
                               animations: {
                    self.v.layoutIfNeeded()
                    }, completion: nil)
                }
                dragDirection = Direction.down
            } else {
                // Get back to the original position
                v.imageCropViewConstraintTop.constant = imageCropViewOriginalConstraintTop
                v.collectionViewConstraintHeight.constant =
                    height - imageCropViewOriginalConstraintTop - containerHeight
                  DispatchQueue.main.async{
                UIView.animate(withDuration: 0.3,
                               delay: 0.0,
                               options: UIView.AnimationOptions.curveEaseOut,
                               animations: {
                    self.v.layoutIfNeeded()
                    }, completion: nil)
                }
                dragDirection = Direction.up
            }
        }
        
        // Update isImageShown
        isImageShown = v.imageCropViewConstraintTop.constant == 0

        refreshImageCurtainAlpha()
    }
    
    func refreshImageCurtainAlpha() {
        let imageCurtainAlpha = abs(v.imageCropViewConstraintTop.constant)
            / (v.imageCropViewContainer.frame.height - imageCropViewMinimalVisibleHeight)
        v.imageCropViewContainer.curtain.alpha = imageCurtainAlpha
    }
    
    // MARK: - UICollectionViewDelegate Protocol
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FSAlbumViewCell",
                                                         for: indexPath) as? FSAlbumViewCell {
            let currentTag = cell.tag + 1
            cell.tag = currentTag
            if let images = getImages() {
                let asset = images[(indexPath as NSIndexPath).item]
                imageManager?.requestImage(for: asset,
                                           targetSize: cellSize,
                                           contentMode: .aspectFill,
                                           options: nil) { result, _ in
                                            if cell.tag == currentTag {
                                                cell.imageView.image = result
                                            }
                }
                if asset.mediaType == .video {
                    cell.durationLabel.isHidden = false
                    cell.durationLabel.text = formattedStrigFrom(asset.duration)
                } else {
                    cell.durationLabel.isHidden = true
                    cell.durationLabel.text = ""
                }
            }
            return cell
        }
        return UICollectionViewCell()
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getImages() == nil ? 0 : getImages()!.count
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 3) / 4
        return CGSize(width: width, height: width)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let images = getImages() {
            changeImage(images[(indexPath as NSIndexPath).row])
            v.imageCropViewConstraintTop.constant = imageCropViewOriginalConstraintTop
            v.collectionViewConstraintHeight.constant =
                v.frame.height - imageCropViewOriginalConstraintTop - v.imageCropViewContainer.frame.height
            DispatchQueue.main.async{
            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.v.layoutIfNeeded()
                }, completion: nil)
            }
            dragDirection = Direction.up
            collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
            refreshImageCurtainAlpha()
        }
    }
    
    // MARK: - ScrollViewDelegate
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == v.collectionView {
            updateCachedAssets()
        }
    }
    
    // MARK: - PHPhotoLibraryChangeObserver
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
//        DispatchQueue.main.async {
//            if let images = self.getImages() {
//                let collectionChanges = changeInstance.changeDetails(for: images)
//                if collectionChanges != nil {
//                    self.setImages(collectionChanges!.fetchResultAfterChanges, completion: {
//                        let collectionView = self.v.collectionView!
//                        if !collectionChanges!.hasIncrementalChanges || collectionChanges!.hasMoves {
//                            collectionView.reloadData()
//                        } else {
//                            collectionView.performBatchUpdates({
//                                let removedIndexes = collectionChanges!.removedIndexes
//                                if (removedIndexes?.count ?? 0) != 0 {
//                                    collectionView.deleteItems(at: removedIndexes!.aapl_indexPathsFromIndexesWithSection(0))
//                                }
//                                let insertedIndexes = collectionChanges!.insertedIndexes
//                                if (insertedIndexes?.count ?? 0) != 0 {
//                                    collectionView
//                                        .insertItems(at: insertedIndexes!.aapl_indexPathsFromIndexesWithSection(0))
//                                }
//                                let changedIndexes = collectionChanges!.changedIndexes
//                                if (changedIndexes?.count ?? 0) != 0 {
//                                    collectionView.reloadItems(at: changedIndexes!.aapl_indexPathsFromIndexesWithSection(0))
//                                }
//                            }, completion: nil)
//                        }
//                        self.resetCachedAssets()
//                    })
//                }
//            }
//        }
    }
    
    var latestImageTapped = ""

    func changeImage(_ asset: PHAsset) {
        v.imageCropView.image = nil
        self.stopVideoPlayer()
        phAsset = asset
        latestImageTapped = asset.localIdentifier
        if asset.mediaType == PHAssetMediaType.video {
            v.imageCropViewContainer.isVideoMode = true
                let videosOptions = PHVideoRequestOptions()
                videosOptions.isNetworkAccessAllowed = true
                PHImageManager.default().requestAVAsset(forVideo: asset, options: videosOptions) { ass, _, _ in
                    DispatchQueue.main.async {
                        if ass == nil {
                            self.v.imageCropViewContainer.spinnerView.alpha = 1
                        } else {
                            if let urlAsseets = ass as? AVURLAsset{
                                UIView.animate(withDuration: 0.2) {
                                    self.v.imageCropViewContainer.spinnerView.alpha = 0
                                }
                                /*bug Name :- Create post>> video post>>add a sound>> musics are overlapping
                                  Fix Date :- 8/07/2021
                                  Fixed By :- Jayaram G
                                  Description Of fix :- Not playing video firsttime when in camera mode
                                 */
                                if self.isFirstTime {
                                    return
                                }
                                self.v.imageCropView.urlAsset = urlAsseets
                                self.v.imageCropViewContainer.refreshSquareCropButton()
                            }
                        }
                    }
                }
        } else {
            v.imageCropViewContainer.isVideoMode = false
            DispatchQueue.global(qos: .default).async {
                let options = PHImageRequestOptions()
                options.isNetworkAccessAllowed = true
                self.imageManager?.requestImage(for: asset,
                                                targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
                                                contentMode: .aspectFill,
                                                options: options) { result, info in
                                                    // Prevent long images to come after user selected another in the meantime.
                                                    if self.latestImageTapped == asset.localIdentifier {
                                                        DispatchQueue.main.async {
                                                            
                                                            if let isFromCloud = info?[PHImageResultIsDegradedKey] as? Bool, isFromCloud  == true {
                                                                self.v.imageCropViewContainer.spinnerView.alpha = 1
                                                            } else {
                                                                UIView.animate(withDuration: 0.2) {
                                                                    self.v.imageCropViewContainer.spinnerView.alpha = 0
                                                                }
                                                            }
                                                            
                                                            self.v.imageCropView.imageSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
                                                            self.v.imageCropView.image = result
                                                            
                                                            if YPImagePickerConfiguration.shared.onlySquareImages {
                                                                self.v.imageCropView.setFitImage(true)
                                                                self.v.imageCropView.minimumZoomScale = self.v.imageCropView.squaredZoomScale
                                                            }
                                                            self.v.imageCropViewContainer.refreshSquareCropButton()
                        }
                    }
                }
            }
        }
    }
    
    
    
    /// To start video player, remove from super view and remove observer
    func startVideoPlayer(){
        if let player = self.v.imageCropView.player, player.playbackState == .paused{
            DispatchQueue.main.async{
                player.play()
            }
        }
    }
    
    
    /// To stop video player, remove from super view and remove observer
    func stopVideoPlayer(){
        if let play = self.v.imageCropView.player{
            DispatchQueue.main.async {
                play.shutdown()
                play.view.removeFromSuperview()
                self.v.imageCropView.player = nil
            }
            NotificationCenter.default.removeObserver(self.v.imageCropView as Any, name: NSNotification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: nil)
        }
    }
    
    
    /// To pause video player and remobe observer
    func pauseVideoPlayer(){
        if let play = self.v.imageCropView.player{
            DispatchQueue.main.async {
                play.pause()
            }
            NotificationCenter.default.removeObserver(self.v.imageCropView as Any, name: NSNotification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: nil)
        }
    }
    
    // Check the status of authorization for PHPhotoLibrary
    func checkPhotoAuth() {
        PHPhotoLibrary.requestAuthorization { status  in
            switch status {
            case .authorized:
                self.imageManager = PHCachingImageManager()
//                if let images = self.getImages(), images.count > 0 {
                DispatchQueue.main.async {
                    self.refreshMediaRequest()
                }
//                    DispatchQueue.main.async{
//                        self.v.collectionView.reloadData()
//                    }
//                    self.changeImage(images[0])
//                }
            case .restricted, .denied:
                DispatchQueue.main.async {
                    self.delegate?.albumViewCameraRollUnauthorized()
                }
            default:
                break
            }
        }
    }
    
    // MARK: - Asset Caching
    
    func resetCachedAssets() {
        imageManager?.stopCachingImagesForAllAssets()
        previousPreheatRect = CGRect.zero
    }
    
    func updateCachedAssets() {
        var preheatRect = v.collectionView!.bounds
        preheatRect = preheatRect.insetBy(dx: 0.0, dy: -0.5 * preheatRect.height)
        
        let delta = abs(preheatRect.midY - self.previousPreheatRect.midY)
        if delta > self.v.collectionView!.bounds.height / 3.0 {
            
            var addedIndexPaths: [IndexPath] = []
            var removedIndexPaths: [IndexPath] = []
            
            self.computeDifferenceBetweenRect(self.previousPreheatRect,
                                              andRect: preheatRect,
                                              removedHandler: { removedRect in
                let indexPaths = self.v.collectionView.aapl_indexPathsForElementsInRect(removedRect)
                removedIndexPaths += indexPaths
                }, addedHandler: {addedRect in
                    let indexPaths = self.v.collectionView.aapl_indexPathsForElementsInRect(addedRect)
                    addedIndexPaths += indexPaths
            })
            
            let assetsToStartCaching = self.assetsAtIndexPaths(addedIndexPaths)
            let assetsToStopCaching = self.assetsAtIndexPaths(removedIndexPaths)
            
            self.imageManager?.startCachingImages(for: assetsToStartCaching,
                                                  targetSize: cellSize,
                                                  contentMode: .aspectFill,
                                                  options: nil)
            self.imageManager?.stopCachingImages(for: assetsToStopCaching,
                                                 targetSize: cellSize,
                                                 contentMode: .aspectFill,
                                                 options: nil)
            
            self.previousPreheatRect = preheatRect
        }
    }
    
    func computeDifferenceBetweenRect(_ oldRect: CGRect,
                                      andRect newRect: CGRect,
                                      removedHandler: (CGRect) -> Void,
                                      addedHandler: (CGRect) -> Void) {
        if newRect.intersects(oldRect) {
            let oldMaxY = oldRect.maxY
            let oldMinY = oldRect.minY
            let newMaxY = newRect.maxY
            let newMinY = newRect.minY
            if newMaxY > oldMaxY {
                let rectToAdd = CGRect(x: newRect.origin.x,
                                       y: oldMaxY,
                                       width: newRect.size.width,
                                       height: (newMaxY - oldMaxY))
                addedHandler(rectToAdd)
            }
            if oldMinY > newMinY {
                let rectToAdd = CGRect(x: newRect.origin.x,
                                       y: newMinY,
                                       width: newRect.size.width,
                                       height: (oldMinY - newMinY))
                addedHandler(rectToAdd)
            }
            if newMaxY < oldMaxY {
                let rectToRemove = CGRect(x: newRect.origin.x,
                                          y: newMaxY,
                                          width: newRect.size.width,
                                          height: (oldMaxY - newMaxY))
                removedHandler(rectToRemove)
            }
            if oldMinY < newMinY {
                let rectToRemove = CGRect(x: newRect.origin.x,
                                          y: oldMinY,
                                          width: newRect.size.width,
                                          height: (newMinY - oldMinY))
                removedHandler(rectToRemove)
            }
        } else {
            addedHandler(newRect)
            removedHandler(oldRect)
        }
    }
    
    func assetsAtIndexPaths(_ indexPaths: [IndexPath]) -> [PHAsset] {
        if indexPaths.count == 0 { return [] }
        
        var assets: [PHAsset] = []
        assets.reserveCapacity(indexPaths.count)
        for indexPath in indexPaths {
            if let images = getImages() {
                let asset = images[(indexPath as NSIndexPath).item]
                assets.append(asset)
            }
        }
        return assets
    }
    
    public func selectedMedia(photo:@escaping (_ photo: UIImage) -> Void,
                              video: @escaping (_ videoURL: URL) -> Void) {
        var cropRect = CGRect.zero
        if let cropView = v.imageCropView {
            let normalizedX = min(1, cropView.contentOffset.x / cropView.contentSize.width)
            let normalizedY = min(1, cropView.contentOffset.y / cropView.contentSize.height)
            let normalizedWidth = min(1, cropView.frame.width / cropView.contentSize.width)
            let normalizedHeight = min(1, cropView.frame.height / cropView.contentSize.height)
            cropRect = CGRect(x: normalizedX, y: normalizedY, width: normalizedWidth, height: normalizedHeight)
        }
        DispatchQueue.global(qos: .default).async {
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.normalizedCropRect = cropRect
            options.resizeMode = .exact
            
            let targetWidth = floor(CGFloat(self.phAsset.pixelWidth) * cropRect.width)
            let targetHeight = floor(CGFloat(self.phAsset.pixelHeight) * cropRect.height)
            let dimension = max(min(targetHeight, targetWidth), 1024 * UIScreen.main.scale)
            
            let targetSize = CGSize(width: dimension, height: dimension)
            
            let asset = self.phAsset!
//             let unsignedInt64 = asset.value(forKey: "fileSize") as? CLong
//            let size = Int64(bitPattern: UInt64(unsignedInt64!))
//            print("**********Size\(size)")
            if asset.mediaType == .video {
                if asset.duration > 180 {
                    let alert = UIAlertController(title: "VideoTooLong".localized,
                                                  message: "VideoTooLong".localized,
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized, style: UIAlertAction.Style.default, handler: nil))
                    DispatchQueue.main.async{
                    self.present(alert, animated: true, completion: nil)
                    }
                } else {
                    let videosOptions = PHVideoRequestOptions()
                    videosOptions.isNetworkAccessAllowed = true
                    self.delegate?.albumViewStartedLoadingImage()
                    PHImageManager.default().requestAVAsset(forVideo: asset,
                                                            options: videosOptions) { v, _, _ in
                                                                if let urlAsset = v as? AVURLAsset {
                                                                    print(urlAsset.fileSize)
                                                                    DispatchQueue.main.async {
                                                                        self.delegate?.albumViewFinishedLoadingImage()
                                                                        video(urlAsset.url)
                                                                    }
                                                                }
                    }
                }
            } else {
                self.delegate?.albumViewStartedLoadingImage()
                PHImageManager.default()
                    .requestImage(for: asset,
                                  targetSize: targetSize,
                                  contentMode: .aspectFit,
                                  options: options) { result, _ in
                                    DispatchQueue.main.async {
                                        self.delegate?.albumViewFinishedLoadingImage()
                                        /*
                                         Bug Name:- Crash
                                         Fix Date:- 14/06/21
                                         Fix By  :- Jayaram G
                                         Description of Fix:- Added check for nil value
                                         */
                                        if result != nil {
                                            photo(result!)
                                        }
                                    }
                }
            }
        }
    }
    
}

internal extension UICollectionView {
    
    func aapl_indexPathsForElementsInRect(_ rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)
        if (allLayoutAttributes?.count ?? 0) == 0 {return []}
        var indexPaths: [IndexPath] = []
        indexPaths.reserveCapacity(allLayoutAttributes!.count)
        for layoutAttributes in allLayoutAttributes! {
            let indexPath = layoutAttributes.indexPath
            indexPaths.append(indexPath)
        }
        return indexPaths
    }
}

internal extension IndexSet {
    
    func aapl_indexPathsFromIndexesWithSection(_ section: Int) -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        indexPaths.reserveCapacity(count)
        (self as NSIndexSet).enumerate({idx, _ in
            indexPaths.append(IndexPath(item: idx, section: section))
        })
        return indexPaths
    }
}
