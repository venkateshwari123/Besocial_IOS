//
//  FSCameraView.swift
//  YPImgePicker
//
//  Created by Sacha Durand Saint Omer on 2015/11/14.
//  Copyright © 2015 Yummypets. All rights reserved.
//

import UIKit
import Stevia

class FSCameraView: UIView, UIGestureRecognizerDelegate {
    
    let previewViewContainer = UIView()
    let buttonsContainer = UIView()
    let flipButton = UIButton()
    let addAudioButton = UIButton()
    let shotButton = UIButton()
    let flashButton = UIButton()
    let timeElapsedLabel = UILabel()
    let progressBar = UIProgressView()
    let videoSpeedView = VideoSpeedView.instanceFromNib()
    let removeLastButton = UIButton()
    
    convenience init() {
        self.init(frame:CGRect.zero)
        
        sv(
            previewViewContainer,
            progressBar,
            timeElapsedLabel,
            flashButton,
            flipButton,
            addAudioButton,
            buttonsContainer.sv(
                shotButton,
                videoSpeedView,
                removeLastButton
            )
        )
        
        let isIphone4 = UIScreen.main.bounds.height == 480
        let sideMargin: CGFloat = isIphone4 ? 20 : 0
        
        layout(
            0,
            |-sideMargin-previewViewContainer-sideMargin-|,
            -2,
            |progressBar|,
            0,
            |buttonsContainer|,
            0
        )
        
        previewViewContainer.heightEqualsWidth()
        
        layout(
            15,
            |-(15+sideMargin)-flashButton.size(42)
        )
        
        layout(
            15,
            flipButton.size(42)-(15+sideMargin)-|
        )
        
        layout(
            10,
            addAudioButton.height(30),
            addAudioButton.width(170).centerHorizontally()
        )
        
        layout(
            videoSpeedView.height(40),
            videoSpeedView.width(250).centerHorizontally()
        )
        
        layout(
            removeLastButton.size(50)-(15+sideMargin)-|
        )
        
        addConstraint(item: timeElapsedLabel, attribute: .bottom,
                      toItem: previewViewContainer, constant: -15)
        
        timeElapsedLabel-(15+sideMargin)-|
        
        shotButton.size(65).centerHorizontally()
        
        if UIScreen.main.bounds.height > 667{
            shotButton.centerVertically()
        }else{
            addConstraint(item: shotButton, attribute: .top,
                          toItem: buttonsContainer, constant: 60)
        }
        addConstraint(item: removeLastButton, attribute: .centerY,
                      toItem: shotButton, constant: 0)
        addConstraint(item: videoSpeedView, attribute: .top,
                      toItem: buttonsContainer, constant: 10)
        backgroundColor = .clear
        previewViewContainer.backgroundColor = .black
        timeElapsedLabel.style { l in
            l.textColor = .white
            l.text = "00:00"
            l.isHidden = true
            l.font = .monospacedDigitSystemFont(ofSize: 13, weight: UIFont.Weight.medium)
        }
        progressBar.trackTintColor = .clear
        progressBar.tintColor = .red
        
        let flipImage = imageFromBundle("Flip")
//        let shotImage = imageFromBundle("camera_btn")
        let backImage = imageFromBundle("Mask Group 4")
        let audioImage = imageFromBundle("music-symbol")
        flashButton.setImage(flashOffImage, for: .normal)
        flipButton.setImage(flipImage, for: .normal)
//        shotButton.setImage(shotImage, for: .normal)
        removeLastButton.setImage(backImage, for: .normal)
        videoSpeedView.backgroundColor = UIColor.clear
        addAudioButton.setTitle("Add a Sound", for: .normal)
        addAudioButton.titleLabel?.font = UIFont(name: "CenturyGothic", size: 14)
        addAudioButton.setImage(audioImage, for: .normal)
    }
}
