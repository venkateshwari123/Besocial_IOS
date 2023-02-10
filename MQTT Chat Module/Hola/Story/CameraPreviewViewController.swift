//
//  CameraPreviewViewController.swift
//  CameraModule
//
//  Created by Shivansh on 11/14/18.
//  Copyright © 2018 Shivansh. All rights reserved.
//

import UIKit
//import iOSPhotoEditor

class CameraPreviewViewController:PhotoEditorViewController  {

    @IBOutlet weak var previewImage: UIImageView!
    var capturedImage:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        previewImage.image = capturedImage
       // photoEditorDelegate = self
        // Do any additional setup after loading the view.
    }
}
