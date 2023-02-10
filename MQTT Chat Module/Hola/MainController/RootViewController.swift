//
//  MainViewController.swift
//  Starchat
//
//  Created by 3Embed on 17/07/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class RootViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {

    var controllers : [UIViewController] = []
    var isFirstTime : Bool = false
    
    @IBOutlet weak var collectionControllers: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isFirstTime = true
        let cameraController = self.storyboard?.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
        cameraController.isForStory = true
        controllers.append(cameraController)
        let tabBarController = self.storyboard?.instantiateViewController(withIdentifier: "tabBarController") as! TabbarController
        controllers.append(tabBarController)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.collectionControllers.scrollToItem(at: IndexPath.init(row: 1, section: 0), at: .right, animated: false)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(changeCell), name: NSNotification.Name(rawValue: "ChangeCell"), object: nil)
        // Do any additional setup after loading the view.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return controllers.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : collectionControllersCell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionControllersCell", for: indexPath) as! collectionControllersCell
        
        let cameraController = controllers[indexPath.item]
        cameraController.view.frame = cell.bounds
        cell.addSubview(cameraController.view)
        controllers[indexPath.item].didMove(toParent: self)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return UIScreen.main.bounds.size
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == 0{
            if let cellOne = collectionControllers.cellForItem(at: collectionControllers.indexPathsForVisibleItems.first ?? indexPath) as? collectionControllersCell, let tabbarVC : TabbarController = cellOne.subviews.last?.parentViewController as? TabbarController{
                tabbarVC.viewControllers?.forEach({ (obj) in
                    if let navVC = obj as? SwipeNavigationController{
                        if navVC.viewControllers.count > 1{
                            collectionControllers.scrollToItem(at: IndexPath.init(row: 1, section: 0), at: .right, animated: false)
                        }
                    }
                })
            }
        }
        if isFirstTime{
            isFirstTime = false
            collectionControllers.scrollToItem(at: IndexPath.init(row: 1, section: 0), at: .right, animated: false)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cellOne = collectionControllers.cellForItem(at: collectionControllers.indexPathsForVisibleItems.first ?? indexPath) as? collectionControllersCell, let cameravc : CameraViewController = cellOne.subviews.last?.parentViewController as? CameraViewController{
            cameravc.viewDidLoad()
        }
    }
    
    @objc func changeCell(){
//        collectionControllers.scrollToItem(at: IndexPath.init(row: 1, section: 0), at: .right, animated: false)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

class collectionControllersCell: UICollectionViewCell {
}
