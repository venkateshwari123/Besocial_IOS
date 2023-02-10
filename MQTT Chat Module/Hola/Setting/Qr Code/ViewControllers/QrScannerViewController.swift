//
//  QrScannerViewController.swift
//  Starchat
//
//  Created by Rahul Sharma on 07/06/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G
import UIKit
import AVFoundation
import Foundation

/// Passing BarCode Response (String)
protocol BarcodeDelegate {
    func barcodeReaded(barcode: String)
    func moveToProfileUser(userId: String)
}
class QrScannerViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate {
    
    
    //MARK:- Outlets
    @IBOutlet weak var vwSquare: UIView!
    @IBOutlet weak var torchBtnOutlet: UIButton!
    @IBOutlet weak var qrScannerView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var qrCodeLabel: UILabel!
    
    //MARK:- Variables&Declarations
    var delegate: BarcodeDelegate?
    var videoCaptureDevice: AVCaptureDevice = AVCaptureDevice.default(for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video)))!
    var device = AVCaptureDevice.default(for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video)))
    var output = AVCaptureMetadataOutput()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var captureSession = AVCaptureSession()
    var code: String?
    var profielVmObject = ProfileViewModel()
    var isPrivate:Int = 0
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        self.setupCamera()
        qrCodeLabel.text = "QR Code".localized
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession.isRunning == false) {
            captureSession.startRunning();
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (captureSession.isRunning == true) {
            captureSession.stopRunning();
        }
    }
    
    /// Setting up Qr Scanner camera
    private func setupCamera() {
        let input = try? AVCaptureDeviceInput(device: videoCaptureDevice)
        if self.captureSession.canAddInput(input!) {
            self.captureSession.addInput(input!)
        }
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        if let videoPreviewLayer = self.previewLayer {
            videoPreviewLayer.videoGravity = AVLayerVideoGravity(rawValue: convertFromAVLayerVideoGravity(AVLayerVideoGravity.resizeAspectFill))
            videoPreviewLayer.frame = self.qrScannerView.bounds
            qrScannerView.layer.addSublayer(videoPreviewLayer)
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if self.captureSession.canAddOutput(metadataOutput) {
            self.captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr, AVMetadataObject.ObjectType.ean13]
        } else {
            print("Could not add metadata output")
        }
        self.qrScannerView.bringSubviewToFront(vwSquare)
    }
    
    /// After Completed Scanning QrCode , for getting output response
    ///
    /// - Parameters:
    ///   - captureOutput: captureOutput
    ///   - metadataObjects: metaObject (Response)
    ///   - connection: AVCaptureConnection
    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        // This is the delegate's method that is called when a code is read.
        if (captureSession.isRunning == true) {
            captureSession.stopRunning();
        }
        for metadata in metadataObjects {
            let readableObject = metadata as! AVMetadataMachineReadableCodeObject
            let code = readableObject.stringValue
            
            self.profielVmObject.QrCodeFollowPeopleService(url: AppConstants.follow, peopleId: code!) { (isPrivate,success,error)   in
                if success {
                    if isPrivate == 1 {
                        /* Bug Name :  ADD CONTACTS--SCAN QR CODE PRIVATE PROFILE After scanning QR code the it should say "request sent".
                         Fix Date : 02-Apr-2021
                         Fixed By : Jayaram G
                         Description Of Fix : Added toast view to showing the "Request sent" text ,and added 0.5 secs delay to close the screen.
                         */
                        
                        Helper.showAlertViewOnWindowWithCompletionHandler(Strings.message.localized, message: "Request Sent Successfully".localized + ".") { success in
                            
                            if code != nil  {
                                self.dismissMoveToProfile(id: code!)
                            }
                            
                        }
                        
                    }else{
                        Helper.showAlertViewOnWindowWithCompletionHandler(Strings.message.localized, message: "Added as friend".localized + ".") { success in
                            
                            if code != nil  {
                                self.dismissMoveToProfile(id: code!)
                            }
                            
                        }
                    }
                   }else {
                    self.dismiss(animated: true, completion: {
                        if error?.code == 422 {
                            Helper.showAlertViewOnWindow(Strings.message.localized, message: "Request has already been made to this user".localized + ".")
                        }
                    })
                }
            }
            self.delegate?.barcodeReaded(barcode: code!)
            print(code!)
        }
    }
    
    
    func dismissMoveToProfile(id: String) {
        self.dismiss(animated: true, completion: {
            /* Bug Name :  After scanning qrcode need to navigate to profile page
             Fix Date : 02-Apr-2021
             Fixed By : Jayaram G
             Description Of Fix : Added profile navigation here through protocol delegate
             */
            self.delegate?.moveToProfileUser(userId: id)
        })
    }
    
    
    /// Dismissing ViewController
    ///
    /// - Parameter sender: backBtn
    @IBAction func backToQrCodeVc(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    /// Managing Flash Light
    ///
    /// - Parameter sender: flashBtn
    @IBAction func flashButton(_ sender: UIButton) {
        toggleFlash()
    }
    
    
    /// Managing Flash Light
    func toggleFlash() {
        if let device = AVCaptureDevice.default(for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video))), device.hasTorch {
            do {
                try device.lockForConfiguration()
                let torchOn = !device.isTorchActive
                try device.setTorchModeOn(level: 1.0)
                device.torchMode = torchOn ? .on : .off
                device.unlockForConfiguration()
                torchBtnOutlet.setImage(device.isTorchActive ? #imageLiteral(resourceName: "flash_off") : #imageLiteral(resourceName: "flash_on")  , for: .normal)
            } catch {
                print()
            }
        }
    }
}




// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVMediaType(_ input: AVMediaType) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVLayerVideoGravity(_ input: AVLayerVideoGravity) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVMetadataObjectObjectType(_ input: AVMetadataObject.ObjectType) -> String {
	return input.rawValue
}
