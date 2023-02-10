//
//  ScrollingImageVC.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 25/05/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import UIKit

class ScrollingImageVC: UIViewController {

    @IBOutlet weak var backgroundScrollingView: UIScrollView!
    @IBOutlet weak var backgroundScrollingImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        animateImageView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Route.navigateToLoginVC(vc: self)
    }
    
    /*
     Bug Name :- Need to add background image scrolling
     Fix Date :- 25/05/2021
     Fixed By :- Jayaram G
     Description Of Fix :- Added animation to image
     */
    func animateImageView() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 10) {
                self.backgroundScrollingView.contentOffset.y = self.view.frame.size.height * 2
            } completion: { (status) in
                self.backgroundScrollingView.contentOffset.y = 0
                self.animateImageView()
            }
        }
    }
}
