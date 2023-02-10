//
//  ViewController.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 4/23/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import PixelEditor
import PixelEngine


open class PhotoEditorViewController: UIViewController {
    
    /** holding the 2 imageViews original image and drawing & stickers */
    @IBOutlet weak var canvasView: UIView!
    @IBOutlet weak var undoBtn: UIButton!
    @IBOutlet weak var redoBtn: UIButton!
    @IBOutlet weak var textFontTypeBtn: UIButton!
    @IBOutlet weak var fontTypeTbl: UITableView!
    @IBOutlet weak var fontTypeView: UIView!
    
    
    @IBOutlet weak var undoRedoStackView: UIStackView!
    @IBOutlet weak var fontTypeStackView: UIStackView!
    @IBOutlet weak var drawingView: ACEDrawingView!
    let storyAPIObj = StoryAPI()
    //To hold the image
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var canvasViewTopConstraint: NSLayoutConstraint!
    //To hold the drawings and stickers
    @IBOutlet weak var canvasImageView: UIImageView!
    var isForStory = false
    
    @IBOutlet weak var colorsCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var colorsMainVeiwHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var topToolbar: UIView!
    @IBOutlet weak var bottomToolbar: UIView!
    
    @IBOutlet weak var topGradient: UIView!
    @IBOutlet weak var bottomGradient: UIView!
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var colorsCollectionView: UICollectionView!
    @IBOutlet weak var colorPickerView: UIView!
//    @IBOutlet weak var colorPickerViewBottomConstraint: NSLayoutConstraint!
    
    //Controls
    @IBOutlet weak var cropButton: UIButton!
    @IBOutlet weak var stickerButton: UIButton!
    @IBOutlet weak var drawButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    @IBOutlet weak var botomToolBar: UIView!
    @IBOutlet weak var filtersBtnOutlet: UIButton!
    
    @IBOutlet weak var saveLabel: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var yourStoryBtn: UIButton!
    @IBOutlet weak var storyLabel: UILabel!
    

    
    public var image: UIImage?
    
    public var isFromGallery: Bool = false
    /**
     Array of Stickers -UIImage- that the user will choose from
     */
    public var stickers : [UIImage] = []
    /**
     Array of Colors that will show while drawing or typing
     */
    public var colors  : [UIColor] = []
    
    public var photoEditorDelegate: PhotoEditorDelegate?
    var colorsCollectionViewDelegate: ColorsCollectionViewDelegate!
    var fontTypeTableViewDelegate: FontTypeTableviewDelegate!
    // list of controls to be hidden
    public var hiddenControls : [control] = []
    
    var stickersVCIsVisible = false
    var drawColor: UIColor = UIColor.black
    var textColor: UIColor = UIColor.white
    var textFont: UIFont = UIFont(name: "Helvetica", size: 30)!
    var isDrawing: Bool = false
    var lastPoint: CGPoint!
    var swiped = false
    var lastPanPoint: CGPoint?
    var lastTextViewTransform: CGAffineTransform?
    var lastTextViewTransCenter: CGPoint?
    var lastTextViewFont:UIFont?
    var activeTextView: UITextView?
    var imageViewToPan: UIImageView?
    var isTyping: Bool = false
    var isFromChat = false
    var isForProfile = false
    
    
    var stickersViewController: StickersViewController!
    
    var isPresented: Bool = false
    

    
    //MARK:- View life cycle
    //Register Custom font before we load XIB
    override open func loadView() {
        registerFont()
        super.loadView()
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.drawingView.lineColor = .clear

        /* Bug Name :  Create post: Not able to post photo by selecting an image from the album, blank photo is being posted instead of the photo we have selected form the album
         Fix Date : 15-apr-2021
         Fixed By : Jayaram G
         Description Of Fix : Adding image in viewDidload instead of viewDidAppear
         */
        DispatchQueue.main.async {
            if self.image != nil {
                self.setImageView(image: self.image!)
            }
        }
        
        sendBtn.setTitle("SHARE".localized, for: .normal)
        storyLabel.text = "Your Story".localized
        saveLabel.text = "Save".localized
        doneButton.setTitle("Done".localized, for: .normal)
        activeTextView?.delegate = self
        if #available(iOS 11, *) {
          let guide = view.safeAreaLayoutGuide
          NSLayoutConstraint.activate([
            self.view.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 1.0),
            guide.bottomAnchor.constraint(equalToSystemSpacingBelow: self.view.bottomAnchor, multiplier: 1.0)
           ])
        } else {
           let standardSpacing: CGFloat = 8.0
           NSLayoutConstraint.activate([
           self.view.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: standardSpacing),
           bottomLayoutGuide.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant: standardSpacing)
           ])
        }
        
        deleteView.layer.cornerRadius = deleteView.bounds.height / 2
        deleteView.layer.borderWidth = 2.0
        deleteView.layer.borderColor = UIColor.white.cgColor
        deleteView.clipsToBounds = true
        
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        edgePan.edges = .bottom
        edgePan.delegate = self
        self.view.addGestureRecognizer(edgePan)
        
        self.addObserver()
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillChangeFrame(_:)),
                                               name:UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        
        configureCollectionView()
        configurefontTypeTableView()
        stickersViewController = StickersViewController(nibName: "StickersViewController", bundle: Bundle(for: StickersViewController.self))
        
        hideControls()
        
        
    }
    
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
//        if isForProfile {
//            saveLabel.isHidden = true
//            saveBtn.isHidden = true
//            yourStoryBtn.isHidden = true
//            storyLabel.isHidden = true
//            sendBtn.setTitle("save", for: .normal)
//        }else {
//            saveLabel.isHidden = false
//            saveBtn.isHidden = false
//            yourStoryBtn.isHidden = false
//            storyLabel.isHidden = false
//            sendBtn.setTitle("Share", for: .normal)
//        }
        
        
        if !isForStory {
            self.saveLabel.isHidden = true
            self.saveBtn.isHidden = true
            self.yourStoryBtn.isHidden = true
            self.storyLabel.isHidden = true
        } else {
            self.sendBtn.isHidden = true
            self.filtersBtnOutlet.isHidden = true
            self.clearButton.isHidden = false
        }
        
        if isFromChat {
            self.filtersBtnOutlet.isHidden = true
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /*
         Bug Name:- toast not appear sometime
         Fix Date:- 16/04/21
         Fix By  :- Nikunj C
         Description of Fix:- refactor extra code
         */
        Helper.checkConnectionAvaibility(view: self.view)
        
    }
    
    
    open override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        
    }
    
    @IBAction func undoAction(_ sender: Any) {
        self.drawingView.undoLatestStep()
        self.updateButtonStatus()
    }
    
    
    @IBAction func redoAction(_ sender: Any) {
        self.drawingView.redoLatestStep()
        self.updateButtonStatus()
    }
    
    @IBAction func fontChangeAction(_ sender: Any) {
        self.fontTypeView.isHidden = false
        if activeTextView != nil {
            activeTextView?.resignFirstResponder()
        }
    }
    
    @IBAction func fontIncreaseAction(_ sender: Any) {
        if activeTextView != nil {
            let fontSize = (activeTextView?.font!.pointSize)! + 1
            self.textFont = UIFont(name: (activeTextView?.font!.fontName)!, size: fontSize)!
            activeTextView?.font = self.textFont
            let oldFrame = activeTextView!.frame
            let sizeToFit = activeTextView!.sizeThatFits(CGSize(width: oldFrame.width, height:CGFloat.greatestFiniteMagnitude))
            activeTextView?.frame.size = CGSize(width: oldFrame.width, height: sizeToFit.height)
        }
    }
    
    @IBAction func fontDecreaseAction(_ sender: Any) {
        if activeTextView != nil {
            let fontSize = (activeTextView?.font!.pointSize)! - 1
            self.textFont = UIFont(name: (activeTextView?.font!.fontName)!, size: fontSize)!
            activeTextView?.font = self.textFont
            let oldFrame = activeTextView!.frame
            let sizeToFit = activeTextView!.sizeThatFits(CGSize(width: oldFrame.width, height:CGFloat.greatestFiniteMagnitude))
            activeTextView?.frame.size = CGSize(width: oldFrame.width, height: sizeToFit.height)
        }
    }
    
    @IBAction func editTextAction(_ sender: Any){
        if activeTextView != nil {
            activeTextView?.becomeFirstResponder()
        }
    }
    
    func updateButtonStatus(){
        
        self.redoBtn.isEnabled = self.drawingView.canRedo()
        self.undoBtn.isEnabled = self.drawingView.canUndo()
    }
    
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        photoEditorDelegate?.canceledEditing()
        if self.isPresented{
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func cropButtonTapped(_ sender: UIButton) {
//                let controller = ImageCropViewController()
//                controller.delegate = self
//                controller.image = image
//                let navController = UINavigationController(rootViewController: controller)
//                present(navController, animated: true, completion: nil)
    }
    
    @IBAction func stickersButtonTapped(_ sender: Any) {
        addStickersViewController()
    }
    
    @IBAction func drawButtonTapped(_ sender: Any) {
        self.drawingView.drawTool = ACEDrawingToolTypePen
        isDrawing = true
        canvasImageView.isUserInteractionEnabled = false
        doneButton.isHidden = false
        self.drawingView.lineColor = .black
        self.undoRedoStackView.isHidden = false
        colorsMainVeiwHeightConstraint.constant = 50
        colorsCollectionViewHeightConstraint.constant = 40
        colorPickerView.isHidden = false
        hideToolbar(hide: true)
    }
    
    @IBAction func textButtonTapped(_ sender: Any) {
        isTyping = true
        
        let textView = UITextView(frame: CGRect(x: 0, y: drawingView.center.y,
                                                width: UIScreen.main.bounds.width, height: 30))
        
        textView.textAlignment = .center
        textView.font = UIFont(name: "Helvetica", size: 30)
        textView.textColor = textColor
        textView.tintColor = textColor
        textView.font = textFont
        textView.delegate = self
        textView.allowsEditingTextAttributes = true
        textView.isEditable = true
        textView.isSelectable = true
        textView.layer.shadowColor = UIColor.black.cgColor
        textView.layer.shadowOffset = CGSize(width: 1.0, height: 0.0)
        textView.layer.shadowOpacity = 0.2
        textView.layer.shadowRadius = 1.0
        textView.layer.backgroundColor = UIColor.clear.cgColor
        textView.autocorrectionType = .no
        textView.isScrollEnabled = false
        textView.delegate = self
        self.fontTypeStackView.isHidden = false
        self.drawingView.addSubview(textView)
        addGestures(view: textView)
        textView.becomeFirstResponder()
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        view.endEditing(true)
        doneButton.isHidden = true
        self.undoRedoStackView.isHidden = true
        self.drawingView.lineColor = .clear
        colorPickerView.isHidden = true
        fontTypeView.isHidden = true
        fontTypeStackView.isHidden = true
        colorsMainVeiwHeightConstraint.constant = 0
        colorsCollectionViewHeightConstraint.constant = 0
        canvasImageView.isUserInteractionEnabled = true
        hideToolbar(hide: false)
        isDrawing = false
        if self.activeTextView != nil {
            activeTextView?.font = textFont
            self.reloadInputViews()
        }
    }
    
    //MARK:- Bottom Toolbar
    
    @IBAction func saveButtonTapped(_ sender: AnyObject) {
        UIImageWriteToSavedPhotosAlbum(canvasView.toImage(),self, #selector(PhotoEditorViewController.image(_:withPotentialError:contextInfo:)), nil)
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        let activity = UIActivityViewController(activityItems: [canvasView.toImage()], applicationActivities: nil)
        present(activity, animated: true, completion: nil)
        
    }
    
    @IBAction func clearButtonTapped(_ sender: AnyObject) {
        //clear drawing
//        drawingView.image = nil
        //clear stickers and textviews
        for subview in drawingView.subviews {
            subview.removeFromSuperview()
        }
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        let img = self.canvasView.toImage()
        photoEditorDelegate?.doneEditing(image: img)
        self.dismiss(animated: true, completion: nil)
    }
    
    //MAKR: helper methods
    
    @objc func image(_ image: UIImage, withPotentialError error: NSErrorPointer, contextInfo: UnsafeRawPointer) {
        let alert = UIAlertController(title: "Image Saved".localized, message: "Image successfully saved to Photos library".localized, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK".localized, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func hideControls() {
        for control in hiddenControls {
            switch control {
                
            case .clear:
                clearButton.isHidden = true
            case .crop:
                cropButton.isHidden = true
            case .draw:
                drawButton.isHidden = true
            case .save:
                saveButton.isHidden = true
            case .share:
                shareButton.isHidden = true
            case .sticker:
                stickerButton.isHidden = true
            case .text:
                stickerButton.isHidden = true
            }
        }
    }
    
    @IBAction func addStoryButtonAction(_ sender: Any) {
        let img = self.canvasView.toImage()
        self.doneEditing(image:img)
    }
    
    func checkIsAnyNewStoryAvailble(newStoryDetails:[String:Any]) {
        self.postNewStory(storyDetails:newStoryDetails)
    }
    
    func doneEditing(image: UIImage) {
        StoryHelper.uploadImageToCloudinary(image: image, view: self.view, message:"Uploading Image".localized + " ...", onCompletion:  { (isuploaded,storyDetails) in
            if(isuploaded) {
                self.checkIsAnyNewStoryAvailble(newStoryDetails: storyDetails)
            }
        })
    }
    
    func postNewStory(storyDetails:[String:Any]) {
        Helper.showPI()
        let storyDetails = ["caption":storyDetails["caption"], "type":storyDetails["type"], "isPrivate":false, "urlPath":storyDetails["urlPath"], "thumbnail":storyDetails["thumbnail"]] as [String:Any]
        storyAPIObj.postNewStory(with:AppConstants.postStory , params:storyDetails, complitation: { (response, error) in
            print("responce")
            DispatchQueue.main.async {
                Helper.hidePI()
                self.photoEditorDelegate?.doneEditing(image: UIImage())
                self.dismiss(animated: false, completion: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ChangeCell"), object: nil)
            }
        })
    }
    
    
    
    @IBAction func filtersAction(_ sender: UIButton) {
        let filters = self.getFiltersCube()
        let storage = ColorCubeStorage(filters: filters)
        let img = self.canvasView.toImage()
        let filterVC = PixelEditViewController(image: img, colorCubeStorage: storage)
        filterVC.delegate = self
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.fade
        self.view.layer.add(transition, forKey: nil)
        self.navigationController?.pushViewController(filterVC, animated: false)
        
        
    }
    
    func getFiltersCube()->[FilterColorCube]{
          var filters = [FilterColorCube]()
        let filtersName = ["","Hefe","Aden","Moon","Nashville","Perpetua","Clarendon","Lark","Lofi","Moon"]
          for index in 1...9{
              let imageName = "LUT_M0\(index).png"
              guard let lutImage: UIImage = UIImage(named: imageName) else{continue}
              let filter = FilterColorCube(
                  name: "\(filtersName[index])",
                  identifier: imageName,
                  lutImage: lutImage,
                  dimension: 64
              )
              filters.append(filter)
          }
          return filters
      }
    
    
    
    @IBAction func sendBtnAction(_ sender: Any) {
        if self.isPresented{
            let img = self.canvasView.toImage()
            photoEditorDelegate?.doneEditing(image: img)
            self.dismiss(animated: true, completion: nil)
        }else{
            let img = self.canvasView.toImage()
            ImageSaveHelper.saveImageDocumentDirectory(imageToSave:img, completionHandler: { (imagePath) in
                let createPostVc = CreatePostViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.CreatePost) as CreatePostViewController
                createPostVc.mediaPath = imagePath
                createPostVc.selectedImage = img
                createPostVc.isForVideo = false
                self.navigationController?.pushViewController(createPostVc, animated:true)
            })
        }
    }
    
    
    func configureCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 30, height: 30)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        colorsCollectionView.collectionViewLayout = layout
        colorsCollectionViewDelegate = ColorsCollectionViewDelegate()
        colorsCollectionViewDelegate.colorDelegate = self
        if !colors.isEmpty {
            colorsCollectionViewDelegate.colors = colors
        }
        colorsCollectionView.delegate = colorsCollectionViewDelegate
        colorsCollectionView.dataSource = colorsCollectionViewDelegate
        
        colorsCollectionView.register(UINib(nibName: "ColorCollectionViewCell", bundle: Bundle(for: ColorCollectionViewCell.self)),
                                      forCellWithReuseIdentifier: "ColorCollectionViewCell")
    }
    
    func configurefontTypeTableView(){
        fontTypeTableViewDelegate = FontTypeTableviewDelegate()
        fontTypeTableViewDelegate.fontDelegate = self
        fontTypeTbl.delegate = fontTypeTableViewDelegate
        fontTypeTbl.dataSource = fontTypeTableViewDelegate
        fontTypeTbl.layer.cornerRadius = 12
        fontTypeTbl.register(UINib(nibName: "FontTypeTableViewCell", bundle: Bundle(for: FontTypeTableViewCell.self)), forCellReuseIdentifier: "FontTypeTableViewCell")
    }
    
    func setImageView(image: UIImage) {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            let topPadding = window?.safeAreaInsets.top
            self.canvasViewTopConstraint.constant = topPadding!
        }else{
            self.canvasViewTopConstraint.constant = 20
        }
        self.view.layoutIfNeeded()
        self.view.updateConstraints()
        imageView.image = image
        if self.isFromGallery{
            imageView.contentMode = UIView.ContentMode.scaleAspectFit
        }
    }
    
    func hideToolbar(hide: Bool) {
        topToolbar.isHidden = hide
        topGradient.isHidden = hide
        bottomToolbar.isHidden = hide
        bottomGradient.isHidden = hide
    }
}

extension PhotoEditorViewController: ColorDelegate {
    func didSelectColor(color: UIColor) {
        if isDrawing {
            self.drawingView.lineColor = color
            self.drawColor = color
        } else if activeTextView != nil {
            activeTextView?.textColor = color
            textColor = color
            self.reloadInputViews()
        }
    }
}

extension PhotoEditorViewController: fontTypeDelegate{
    func didSelectFont(font: UIFont) {
        if activeTextView != nil {
            activeTextView?.font = font
            
            self.textFont = font
            self.fontTypeView.isHidden = true
            self.reloadInputViews()
        }
    }
    
    
}


extension PhotoEditorViewController: PixelEditViewControllerDelegate{
    public func pixelEditViewController(_ controller: PixelEditViewController, didEndEditing editingStack: EditingStack) {
        controller.navigationController?.popViewController(animated: false)
        let image = editingStack.makeRenderer().render(resolution: .full)
        /* Bug Name : filters are not being applied for photos
         Fix Date : 05-May-2021
         Fixed By : Jayaram G
         Description Of Fix : Adding image after applying filters to imageView on main thread
         */
        DispatchQueue.main.async {
            self.setImageView(image: image)
        }
        ImageSaveHelper.saveImageDocumentDirectory(imageToSave:image, completionHandler: { (imagePath) in
            self.image = image
        })
    }
    
    public func pixelEditViewControllerDidCancelEditing(in controller: PixelEditViewController) {
        controller.navigationController?.popViewController(animated: false)
    }
}


