//
//  Audio.swift
//  dub.ly
//
//  Created by DINESH GUPTHA on 12/18/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import SCRecorder

struct Audio {
    var name = ""
    var url = ""
    var duration = ""
    var isFavourite =  false
    var thumbNail = ""
    var id = ""
    var artist = ""
    
    init(details:[String:Any]) {
        
        if let audioName = details["name"] as? String {
            self.name = audioName
        }
        
        if let path = details["path"] as? String {
             self.url = path
        }
        
        
        if let artist = details["producername"] as? String {
            self.artist = artist
        }
        
        if let artist = details["artist"] as? String {
            self.artist = artist
        }
        
        if let duration = details["duration"] as? String {
            self.duration = duration
        }
        
        if let thumbNail = details["imageUrl"] as? String {
            self.thumbNail = thumbNail
        }
        
        if let id = details["_id"] as? String {
            self.id = id
        }
        
        if let isFav = details["isFavourite"] as? Int {
            if isFav == 1 {
                self.isFavourite = true
            }
        }
    }
    
    
    init(mediaModel: MediaModel){
        if let name = mediaModel.name{
            self.name = name
        }
        if let url = mediaModel.path{
            self.url = url
        }
        if let dura = mediaModel.duration{
            self.duration = dura
        }
        if let thumb = mediaModel.imageUrl{
            self.thumbNail = thumb
        }
        if let id = mediaModel.mediaId{
            self.id = id
        }
        self.isFavourite = mediaModel.isFavourite
    }
    
    
}


struct DubAudioCategory {
    var categoryImageUrl:String = ""
    var categoryName:String = ""
    var categoryId:String = ""
    
    init(details:[String:Any]) {
        if let catName = details["name"] as? String {
            self.categoryName = catName
        }
        
        if let catID = details["_id"] as? String {
            self.categoryId = catID
        }
        
        if let catImage = details["imageUrl"] as? String {
            self.categoryImageUrl = catImage
        }
    }
}


extension SCRecorder {
    
    private func _videoConnection() -> AVCaptureConnection? {
        
        if let _outputs = self.captureSession?.outputs {
            
            for output in _outputs {
                if let _captureOutput = output as? AVCaptureVideoDataOutput {
                    
                    for connection in _captureOutput.connections {
                        if let captureConnection = connection as? AVCaptureConnection {
                            
                            for port in captureConnection.inputPorts {
                                if let _port = port as? AVCaptureInput.Port {
                                    if _port.mediaType.rawValue == convertFromAVMediaType(AVMediaType.video) {
                                        return captureConnection
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        
        return nil
        
    }
    
    func attemptTurnOffVideoStabilization() {
        
        self.beginConfiguration()
        
        let videoConnection = self._videoConnection()
        if let connection = videoConnection {
            
            if connection.isVideoStabilizationSupported {
                connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.off
            }
            
        }
        
        self.commitConfiguration()
        
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVMediaType(_ input: AVMediaType) -> String {
	return input.rawValue
}
