//
//  AudioSlider.swift
//  MQTT Chat Module
//
//  Created by Sachin Nautiyal on 27/02/2018.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import Foundation

class SliderBuffering:UISlider {
    let bufferProgress =  UIProgressView(progressViewStyle: .default)
    
    override init (frame : CGRect) {
        super.init(frame : frame)
    }
    
    convenience init () {
        self.init(frame:CGRect.zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        self.minimumTrackTintColor = UIColor.clear
        self.maximumTrackTintColor = UIColor.clear
        bufferProgress.backgroundColor = UIColor.clear
        bufferProgress.isUserInteractionEnabled = false
        bufferProgress.progress = 0.0
        bufferProgress.progressTintColor = UIColor.lightGray.withAlphaComponent(0.5)
        bufferProgress.trackTintColor = UIColor.darkGray.withAlphaComponent(0.5)
        self.addSubview(bufferProgress)
    }
}
