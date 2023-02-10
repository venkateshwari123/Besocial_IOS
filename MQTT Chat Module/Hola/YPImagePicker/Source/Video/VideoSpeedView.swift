//
//  VideoSpeedView.swift
//  Starchat
//
//  Created by 3Embed Software Tech Pvt Ltd on 20/06/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class VideoSpeedView: UIView {
    
    @IBOutlet weak var speedPoint1Button: UIButton!
    @IBOutlet weak var speedPoint5Button: UIButton!
    @IBOutlet weak var speed1Button: UIButton!
    @IBOutlet weak var speed2Button: UIButton!
    @IBOutlet weak var speed3Button: UIButton!
    
    @IBOutlet weak var selectedViewLeadingConstraint: NSLayoutConstraint!
    
    
    class func instanceFromNib() -> VideoSpeedView {
        return UINib(nibName: "VideoSpeedView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! VideoSpeedView
    }
    
}
