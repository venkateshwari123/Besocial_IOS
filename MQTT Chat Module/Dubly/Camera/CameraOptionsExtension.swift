//
//  CameraOptionsExtension.swift
//  Do Chat
//
//  Created by Rahul Sharma on 11/07/20.
//  Copyright © 2020 Rahul Sharma. All rights reserved.
//

import Foundation

enum CameraOptions:Int{
    case Albums
    case Photo
    case ShortVideo
    case LongVideo
    
    func title() -> String? {
          switch self {
         // case .FirstPadding1,.FirstPadding2,.LastPadding1,.LastPadding2: return "     "
          case .Albums: return "Albums".localized
          case .Photo: return "Photo".localized
          case .ShortVideo: return "15s".localized
          case .LongVideo: return "60s".localized
          }
      }
}


extension CameraViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
     func calculateSectionInset() -> CGFloat {
        let deviceIsIpad = UIDevice.current.userInterfaceIdiom == .pad
        let deviceOrientationIsLandscape = UIDevice.current.orientation.isLandscape
        let cellBodyViewIsExpended = deviceIsIpad || deviceOrientationIsLandscape
        let cellBodyWidth: CGFloat = 236 + (cellBodyViewIsExpended ? 174 : 0)
        
        let buttonWidth: CGFloat = 50
        
        let inset = (collectionViewLayout.collectionView!.frame.width - cellBodyWidth + buttonWidth) / 4
        return inset
    }
    
     func configureCollectionViewLayoutItemSize() {
        let inset: CGFloat = calculateSectionInset() // This inset calculation is some magic so the next and the previous cells will peek from the sides. Don't worry about it
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: 150, bottom: 0, right: 160)
        
        collectionViewLayout.itemSize = CGSize(width: 65, height: 30)
    }
    
     func indexOfMajorCell() -> Int {
        let itemWidth = collectionViewLayout.itemSize.width
        let proportionalOffset = collectionViewLayout.collectionView!.contentOffset.x / itemWidth
        let index = Int(round(proportionalOffset))
        let safeIndex = max(0, min(4 - 1, index))
        return safeIndex
    }
    
    // ===================================
    // MARK: - UICollectionViewDataSource:
    // ===================================
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == deepARCollectionView{
            switch currentMode! {
            case .effects:
                return Effects.allCases.count
            case .masks:
                return   Masks.allCases.count
  
            case .filters:
                return   Filters.allCases.count
            }
            
        }
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == deepARCollectionView{
        
                 let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DeepARCVCell", for: indexPath) as! DeepARCVCell
            cell.imageView.backgroundColor = .red
            switch currentMode! {
            case .effects:
                if effectIndex == indexPath.row{
                    cell.selectedImage.isHidden = false
                }else{
                    cell.selectedImage.isHidden = true
                }
                cell.imageView.setImage(string:Effects.allCases[indexPath.row].rawValue.capitalized, color: nil, circular: false, stroke: false)
                cell.titleLabel.text = Effects.allCases[indexPath.row].rawValue.capitalized
            case .masks:
                if maskIndex == indexPath.row{
                    cell.selectedImage.isHidden = false
                }else{
                    cell.selectedImage.isHidden = true
                }
                cell.imageView.setImage(string:Masks.allCases[indexPath.row].rawValue.capitalized, color: nil, circular: false, stroke: false)
                cell.titleLabel.text = Masks.allCases[indexPath.row].rawValue.capitalized
  
            case .filters:
                if filterIndex == indexPath.row{
                    cell.selectedImage.isHidden = false
                }else{
                    cell.selectedImage.isHidden = true
                }
                cell.imageView.setImage(string:Filters.allCases[indexPath.row].rawValue.capitalized, color: nil, circular: false, stroke: false)
                cell.titleLabel.text = Filters.allCases[indexPath.row].rawValue.capitalized
            }
          
            return cell
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CameraBottomOptionsCVCell", for: indexPath) as! CameraBottomOptionsCVCell
        
        
        cell.optionTitle.text = CameraOptions.title(CameraOptions.init(rawValue: indexPath.row)!)()
        if indexPath.row == selectedIndexPathRow{
            if selectedAudio != nil{
              cell.optionTitle.text = "\(maxVideoSeconds)s"
            }
            cell.setSelected()
        }
        else if let session =  recorder.session, session.duration.seconds != 0.0 || isVideoStarted {
            cell.hideCells()
        }
        else{
            cell.setUnSelected()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
          if collectionView == deepARCollectionView{
            switch currentMode! {
            case .effects:
                let path = effectPaths[indexPath.row]
                effectIndex = indexPath.row
                deepAR.switchEffect(withSlot: currentMode.rawValue, path: path)
            
            case .masks:
                maskIndex = indexPath.row
                let path = maskPaths[indexPath.row]
                deepAR.switchEffect(withSlot: currentMode.rawValue, path: path)
  
            case .filters:
                filterIndex = indexPath.row
                let path = filterPaths[indexPath.row]
                deepAR.switchEffect(withSlot: currentMode.rawValue, path: path)
            }
            
            self.deepARCollectionView.reloadData()
        }
          else{
        if let cell = collectionView.cellForItem(at: IndexPath.init(row:selectedIndexPathRow , section: 0)) as? CameraBottomOptionsCVCell{
                   cell.setUnSelected()
               }
        if let cell = collectionView.cellForItem(at: indexPath) as? CameraBottomOptionsCVCell{
            selectedIndexPathRow = indexPath.row
            cell.setSelected()
        }
        collectionViewLayout.collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        self.changeIndex(index: indexPath.row)
        }
    }
    func changeIndex(index:Int){
        switch CameraOptions.init(rawValue: index) {
        case .Albums:
            self.libraryButtonAction(self.libraryBUtton!)
            isVideoStarted = false
            isPhotoMode = false
            self.hideAllTheTools(ishide:true)
            self.viewForProgress.isHidden = true
        case .Photo:
            isVideoStarted = false
            isPhotoMode = true
           self.hideAllTheTools(ishide:true)
            self.closeButton.isHidden = false
            self.viewForProgress.isHidden = true
            currentRecordingMode = .photo

        case .ShortVideo:
            isPhotoMode = false
            isVideoStarted = false
            maxVideoSeconds = 15
             recorder.maxRecordDuration = CMTime(seconds: Double(maxVideoSeconds), preferredTimescale: 1)
            self.viewForProgress.isHidden = false
             self.hideAllTheTools(ishide:false)
            currentRecordingMode = .lowQualityVideo
        case .LongVideo:
            isPhotoMode = false
             maxVideoSeconds = 60
            recorder.maxRecordDuration = CMTime(seconds: Double(maxVideoSeconds), preferredTimescale: 1)
          self.viewForProgress.isHidden = false
            self.hideAllTheTools(ishide:false)
            currentRecordingMode = .lowQualityVideo
        case .none:
            print("No Action")
        }

    }
    // =================================
    // MARK: - UICollectionViewDelegate:
    // =================================
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
          if scrollView != deepARCollectionView{
        indexOfCellBeforeDragging = indexOfMajorCell()
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
         if scrollView != deepARCollectionView{
//         Stop scrollView sliding:
        targetContentOffset.pointee = scrollView.contentOffset

        // calculate where scrollView should snap to:
        let indexOfMajorCell = self.indexOfMajorCell()

        // calculate conditions:
        let swipeVelocityThreshold: CGFloat = 0.5 // after some trail and error
        let hasEnoughVelocityToSlideToTheNextCell = indexOfCellBeforeDragging + 1 < 4 && velocity.x > swipeVelocityThreshold
        let hasEnoughVelocityToSlideToThePreviousCell = indexOfCellBeforeDragging - 1 >= 0 && velocity.x < -swipeVelocityThreshold
        let majorCellIsTheCellBeforeDragging = indexOfMajorCell == indexOfCellBeforeDragging
        let didUseSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell || hasEnoughVelocityToSlideToThePreviousCell)

        if didUseSwipeToSkipCell {
            let snapToIndex = indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? 1 : -1)
            let toValue = collectionViewLayout.itemSize.width * CGFloat(snapToIndex)

            // Damping equal 1 => no oscillations => decay animation:
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: velocity.x, options: .allowUserInteraction, animations: {
                scrollView.contentOffset = CGPoint(x: toValue, y: 0)
                scrollView.layoutIfNeeded()
            }, completion: nil)

        } else {
        //     This is a much better way to scroll to a cell:
            let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
            if let cell = collectionViewLayout.collectionView!.cellForItem(at: IndexPath.init(row:selectedIndexPathRow , section: 0)) as? CameraBottomOptionsCVCell{
                               cell.setUnSelected()
                           }
            
            if let cell = collectionViewLayout.collectionView!.cellForItem(at: indexPath) as? CameraBottomOptionsCVCell{
                   selectedIndexPathRow = indexPath.row
                   cell.setSelected()
               }
                 collectionViewLayout.collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
             self.changeIndex(index: indexPath.row)
        }
     }
    }

}





