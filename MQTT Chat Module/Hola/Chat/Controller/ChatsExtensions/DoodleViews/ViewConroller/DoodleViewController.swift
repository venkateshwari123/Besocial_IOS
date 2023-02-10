//
//  DoodleViewController.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 17/12/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import ACEDrawingView
import AVFoundation
import QuartzCore

protocol doodleDelegate {
    func didDoodleSendCliked(_ image:UIImage)
}


class DoodleViewController: UIViewController {
    @IBOutlet weak var doodleCollectionView: UICollectionView!
    
    @IBOutlet weak var aceView: ACEDrawingView!
    @IBOutlet weak var baseImageView: UIImageView!
    @IBOutlet weak var chanageColourButton: UIButton!
    
    @IBOutlet weak var penView: UIView!
    @IBOutlet weak var lineWidthView: UISlider!
    @IBOutlet weak var colourCollectionView: UIView!
    var colour_custom : [UIColor]?
    var colourImage : [UIImage]?
    var delegate:doodleDelegate?
    
    @IBOutlet weak var redoButton: UIButton!
    @IBOutlet weak var undoButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        aceView.delegate = self
        self.lineWidthView.value = Float(self.aceView.lineWidth);
        self.initData()
        
        self.colourCollectionView.backgroundColor = UIColor.init(red:204.0/255.0 , green: 204.0/255.0, blue: 204.0/255.0, alpha: 1)
        self.colourCollectionView.isHidden = true;
        self.penView.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func initData() {
        
        colour_custom = [UIColor.init(red:255.0/255.0 , green: 255.0/255.0 , blue: 255.0/255.0, alpha: 1),
                         UIColor.init(red:254.0/255.0 , green: 173.0/255.0, blue: 17.0/255.0, alpha: 1),
                         UIColor.init(red:254.0/255.0 , green: 223.0/255.0, blue: 17.0/255.0, alpha: 1),
                         UIColor.init(red:17.0/255.0 , green: 180.0/255.0, blue: 28.0/255.0, alpha: 1),
                         UIColor.init(red:82.0/255.0, green: 181.0/255.0, blue: 219.0/255.0, alpha: 1),
                         UIColor.init(red:0.0/255.0 , green: 0.0/255.0, blue: 0.0/255.0, alpha: 1),
                         UIColor.init(red:119.0/255.0 , green: 119.0/255.0, blue: 119.0/255.0, alpha: 1),
                         UIColor.init(red:102.0/255.0,green: 92.0/255.0, blue: 172.0/255.0, alpha: 1),
                         UIColor.init(red:131.0/255.0 , green: 103.0/255.0, blue: 219.0/255.0 , alpha: 1),
                         UIColor.init(red:255.0/255.0 , green: 59.0/255.0, blue: 48.0/255.0, alpha: 1),
        ]
        
        colourImage = [UIImage.init(named: "doodleImageBlackWhite")!,
                       UIImage.init(named: "dooldeImageOrange")!,
                       UIImage.init(named: "doodleImageBlackYellow")!,
                       UIImage.init(named: "doodleImageBlackGreen")!,
                       UIImage.init(named: "doodleImageBlackblue")!,
                       UIImage.init(named: "doodleImageBlack")!,
                       UIImage.init(named: "doodleImageBlackGray")!,
                       UIImage.init(named: "doodleImageBlackVilot")!,
                       UIImage.init(named: "doodleImageBlackporple")!,
                       UIImage.init(named: "doodleImageRed")!]
    }
    
    
    
    
    func updateButtonStatus(){
        
        self.redoButton.isEnabled = self.aceView.canRedo()
        self.undoButton.isEnabled = self.aceView.canUndo()
    }
    
    
    //MARK:- Button Actions
    
    @IBAction func cancelCliked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func brushChangeValue(_ sender: Any) {
        self.aceView.lineWidth = CGFloat((sender as! UISlider).value)
    }
    
    
    @IBAction func sendCliked(_ sender: Any) {
        
        self.colourCollectionView.isHidden = true
        self.penView.isHidden = true
        delegate?.didDoodleSendCliked(aceView.image)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func colourButtonCliked(_ sender: Any) {
        
        if self.colourCollectionView.isHidden == true {
            self.colourCollectionView.isHidden = false
            self.penView.isHidden = true
        }else{
            self.colourCollectionView.isHidden = true
        }
    }
    
    
    @IBAction func eraseButtonCliked(_ sender: Any) {
        self.aceView.drawTool = ACEDrawingToolTypeEraser;
    }
    
    @IBAction func cameraCliked(_ sender: Any) {
        
        let actionSheet = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        let action1  = UIAlertAction.init(title: "Camera".localized, style: .default, handler: {action in
            self.openCamera()
        })
        
        let action2  = UIAlertAction.init(title: "Choose Photo".localized, style: .default, handler: {action in
            self.openGallery()
        })
        
        let action3 = UIAlertAction.init(title: "Cancel".localized, style: .cancel, handler: nil)
        
        actionSheet.addAction(action1)
        actionSheet.addAction(action2)
        actionSheet.addAction(action3)
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    
    
    /// - Parameter sender: Pen Button Action
    @IBAction func penButtonCliked(_ sender: Any) {
        self.aceView.drawTool = ACEDrawingToolTypePen;
        if(self.penView.isHidden == true)
        {
            self.penView.isHidden = false;
            self.colourCollectionView.isHidden = true;
        }else
        {
            self.penView.isHidden = true;
        }
    }
    
    
    @IBAction func undoButtonCliked(_ sender: Any) {
        self.aceView.undoLatestStep()
        self.updateButtonStatus()
    }
    
    
    @IBAction func redoButtonCliked(_ sender: Any) {
        self.aceView.redoLatestStep()
        self.updateButtonStatus()
    }
    
    
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePickerObj = UIImagePickerController()
            imagePickerObj.navigationBar.tintColor = .black
            imagePickerObj.delegate = self
            imagePickerObj.sourceType = UIImagePickerController.SourceType.camera;
            imagePickerObj.allowsEditing = false
            self.present(imagePickerObj, animated: true, completion: nil)
        }
        else {
            self.showAlert("Alert".localized, message: "Your device doesn't support Camera".localized + ". " + "Please choose other option".localized + ".")
        }
    }
    
    
    func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            let imagePickerObj = UIImagePickerController()
            imagePickerObj.navigationBar.tintColor = .black
            imagePickerObj.delegate = self
            imagePickerObj.sourceType = UIImagePickerController.SourceType.photoLibrary;
            imagePickerObj.allowsEditing = false
            self.present(imagePickerObj, animated: true, completion: nil)
        }
    }
}


extension DoodleViewController: ACEDrawingViewDelegate{
    
    
    func drawingView(_ view: ACEDrawingView!, willBeginDrawUsing tool: ACEDrawingTool!) {
        
    }
    
    func drawingView(_ view: ACEDrawingView!, didEndDrawUsing tool: ACEDrawingTool!) {
        
    }
    
    func drawingView(_ view: ACEDrawingView!, didRedoDrawUsing tool: ACEDrawingTool!) {
        
    }
    
    func drawingView(_ view: ACEDrawingView!, didUndoDrawUsing tool: ACEDrawingTool!) {
        
    }
}


extension DoodleViewController : UICollectionViewDelegate,UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DoodleCell", for: indexPath) as! DoodleCollectionViewCell
        cell.viewColourCell.backgroundColor = colour_custom?[indexPath.row]
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.aceView.lineColor = colour_custom?[indexPath.row]
        self.colourCollectionView.isHidden = true
         self.aceView.drawTool = ACEDrawingToolTypePen;
        self.chanageColourButton.setImage(colourImage?[indexPath.row], for: .normal)
    }
}


extension DoodleViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    
    func imagePickerController(_ picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!) {
      let flippedImage = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation:.leftMirrored)
        self.aceView.clear()
        self.updateButtonStatus()
       
        self.baseImageView.image = flippedImage
       // self.aceView.frame = AVMakeRect(aspectRatio: image.size, insideRect: self.aceView.frame)
         self.aceView.frame = AVMakeRect(aspectRatio: self.baseImageView.frame.size, insideRect: self.baseImageView.frame)
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
