//
//  CameraTabViewController.swift
//  Do Chat
//
//  Created by Rahul Sharma on 10/07/20.
//  Copyright © 2020 Rahul Sharma. All rights reserved.
//

import UIKit

class CameraTabViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let camVc = UIStoryboard.init(name: "Camera", bundle: nil).instantiateViewController(withIdentifier: "CameraViewController")as? CameraViewController {
                       camVc.dismissVC = { isClose in
                           if isClose{
                               self.tabBarController?.selectedIndex = 0
                           }
                       }
                          camVc.modalPresentationStyle = .fullScreen
                          camVc.hidesBottomBarWhenPushed = true
                          self.navigationController?.pushViewController(camVc, animated: false)
                }
                else{
                       self.tabBarController?.selectedIndex = 0
                }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

}
