//
//  ImageCropViewContainer.swift
//  YPImgePicker
//
//  Created by Sacha Durand Saint Omer on 15/11/2016.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import Foundation
import UIKit
import Stevia

class ImageCropViewContainer: UIView, FSImageCropViewDelegate, UIGestureRecognizerDelegate {
    
    var isShown = true
    let grid = FSGridView()
    let curtain = UIView()
    let spinnerView = UIView()
    let spinner = UIActivityIndicatorView(style: .white)
    let squareCropButton = UIButton()
    var isVideoMode = false {
        didSet {
            self.cropView?.isVideoMode = isVideoMode
            self.refresh()
        }
    }
    var cropView: FSImageCropView?
    var shouldCropToSquare = false
    public var onlySquareImages: Bool {
        return YPImagePickerConfiguration.shared.onlySquareImages
    }
    
    @objc func squareCropButtonTapped() {
        if let cropView = cropView {
            let z = cropView.zoomScale
            if z >= 1 && z < cropView.squaredZoomScale {
                shouldCropToSquare = true
            } else {
                shouldCropToSquare = false
            }
        }
        cropView?.setFitImage(shouldCropToSquare)
    }
    
    func refresh() {
        refreshSquareCropButton()
    }
    
    func refreshSquareCropButton() {
        if let image = cropView?.image {
            let isShowingSquareImage = image.size.width == image.size.height
            squareCropButton.isHidden = isVideoMode || isShowingSquareImage
        }else{
            squareCropButton.isHidden = isVideoMode
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(grid)
        grid.frame = frame
        clipsToBounds = true
        
        for sv in subviews {
            if let cv = sv as? FSImageCropView {
                cropView = cv
                cropView?.myDelegate = self
            }
        }
        
        grid.alpha = 0
        
        let touchDownGR = UILongPressGestureRecognizer(target: self, action: #selector(handleTouchDown))
        touchDownGR.minimumPressDuration = 0
        addGestureRecognizer(touchDownGR)
        touchDownGR.delegate = self
        
        sv(
            spinnerView.sv(
                spinner
            ),
            curtain
        )
        
        spinnerView.fillContainer()
        spinner.centerInContainer()
        curtain.fillContainer()
        
        spinner.startAnimating()
        spinnerView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        curtain.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        curtain.alpha = 0
        
        if !onlySquareImages {
            // Crop Button
            squareCropButton.setImage(imageFromBundle("crop_new_icon_off"), for: .normal)
            sv(squareCropButton)
            squareCropButton.size(42)
            |-15-squareCropButton
            squareCropButton.Bottom == cropView!.Bottom - 15
            squareCropButton.addTarget(self, action: #selector(squareCropButtonTapped), for: .touchUpInside)
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith
                                  otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
         return !(touch.view is UIButton)
    }
    
    @objc func handleTouchDown(sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            if isShown && !isVideoMode {
                UIView.animate(withDuration: 0.1) {
                    self.grid.alpha = 1
                }
            }
        case .ended:
            UIView.animate(withDuration: 0.3) {
                self.grid.alpha = 0
            }
        default : ()
        }
    }
    
    func fsImageCropViewDidLayoutSubviews() {
        let newFrame = cropView!.imageView.convert(cropView!.imageView.bounds, to:self)
        grid.frame = frame.intersection(newFrame)
        grid.layoutIfNeeded()
    }
    
    func fsImageCropViewscrollViewDidZoom() {
        if isShown && !isVideoMode {
            UIView.animate(withDuration: 0.1) {
                self.grid.alpha = 1
            }
        }
    }
    
    func fsImageCropViewscrollViewDidEndZooming() {
        UIView.animate(withDuration: 0.3) {
            self.grid.alpha = 0
        }
    }
}
