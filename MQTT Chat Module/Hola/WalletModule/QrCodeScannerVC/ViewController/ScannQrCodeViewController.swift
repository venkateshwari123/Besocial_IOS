//
//  ScannQrCodeViewController.swift
//  Crowwe
//
//  Created by Rahul Sharma on 04/04/20.
//  Copyright © 2020 Rahul Sharma. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

/// Passing BarCode Response (String)
protocol BarcodeDelegateScanner {
    func barcodeReaded(barcode: String)
}

class ScannQrCodeViewController: UIViewController ,AVCaptureMetadataOutputObjectsDelegate{

    //MARK:- Outlet's
    @IBOutlet weak var vwSquare: UIView!
    @IBOutlet weak var qrScannerView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var toarchBtnOutlet: UIButton!
    @IBOutlet weak var qrCodeLbl: UILabel!


    //MARK:- Variables&Declarations
    var delegate: BarcodeDelegateScanner?
    var videoCaptureDevice: AVCaptureDevice = AVCaptureDevice.default(for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video)))!
    var device = AVCaptureDevice.default(for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video)))
    var output = AVCaptureMetadataOutput()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var captureSession = AVCaptureSession()
    var code: String?
    var navigationToQrScann:Int = 0
    var backVC:Int = 0
    var currencySymbol:String = ""
    var profileVM = ProfileViewModel()
    
    @IBAction func backVCActionBtn(_ sender: UIButton) {
        backVC = 1
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        self.setupCamera()
        self.qrCodeLbl.text = "QR Code".localized
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession.isRunning == false) {
            captureSession.startRunning()
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
        if backVC == 1{
             self.navigationController?.isNavigationBarHidden = false
        }
        self.navigationController?.isNavigationBarHidden = false
        if (captureSession.isRunning == true) {
            captureSession.stopRunning()
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
            let codedata = readableObject.stringValue
            let url = AppConstants.memberProfile + "?memberId=\(codedata!)"
            profileVM.isSelf = false
            profileVM.userDetailsService(strUrl: url, params: nil) { (success, error, serviceCall) in
                if success {
                    self.navigationController?.isNavigationBarHidden = false
                    self.navigationToQrScann = 1
                    
                    /*
                     Bug Name:- Kyc is not done from receiver end but when scan QR code it is allowing share the payment
                     Fix Date:- 21st Sep 2021
                     Fixed By:- Nikunj C
                     Description of Fix:- check for kycStatus
                     */
                    
                    if self.profileVM.userProfileModel?.kycStatus == true{
                        if #available(iOS 13.0, *) {
                            guard let transferToFriendVC = UIStoryboard.init(name: AppConstants.StoryBoardIds.chat, bundle: nil).instantiateViewController(identifier: String(describing: TransferToFriendViewController.self)) as? TransferToFriendViewController else {return}
                            transferToFriendVC.userModel = self.profileVM.userProfileModel
                            self.navigationController?.pushViewController(transferToFriendVC, animated: true)
                        } else {
                            // Fallback on earlier versions
                        }
                    }else{
                        Helper.showAlertViewOnWindow("", message: "The receiver has to complete their kyc for you to send them money".localized + ".")
                        self.navigationController?.isNavigationBarHidden = true
                    }
                   
                }
                else if let error = error{
                    if error.code == 204 {
                        let alert = UIAlertController(title: "Error", message: "User Not Found.", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Ok", style: .default) { action in
                            self.navigationController?.popViewController(animated: true)
                        }
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                    }else{
                        Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                    }
                        
                }
            }
            self.delegate?.barcodeReaded(barcode: codedata!)
            print(codedata!)

            }
            
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
                toarchBtnOutlet.setImage(device.isTorchActive ? #imageLiteral(resourceName: "flash_off") : #imageLiteral(resourceName: "flash_on")  , for: .normal)
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

