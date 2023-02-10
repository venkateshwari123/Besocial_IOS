//
//  MediaDownloader.swift
//  MQTT Chat Module
//
//  Created by Sachin Nautiyal on 21/02/2018.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import Foundation

import UIKit
import Alamofire
import Photos

/// Download and save video to camera roll
final class VideoFetcher {
    private let fileManager: FileManager
    
    init(fileManager: FileManager = FileManager.default) {
        self.fileManager = fileManager
    }
    
    func downloadAndSave(videoUrl: URL,fileName : String, progress : @escaping (Progress) -> Void, completionBlock: @escaping (URL?) -> Void) {
        let destination: DownloadRequest.Destination = { _, _ in
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let fileURL = documentsURL.appendingPathComponent(fileName)

                    return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }


        DispatchQueue.global(qos: .default).async {
            
            AF.download(videoUrl, to: destination)
                .downloadProgress(closure: { (prgs) in
                    progress(prgs)
                })
                .response(completionHandler: { response in
                    guard response.error == nil,
                        let destinationUrl = response.fileURL else {
                            completionBlock(nil)
                            return
                    }
                    completionBlock(destinationUrl)
                })
        }
    }
}

class MediaDownloader {
    func SaveMedia(withURL urlString: String, andData data: Data) -> URL? {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let fileName = urlString as NSString
        let filePath="file://\(documentsPath)/\(fileName.lastPathComponent)"
        let fileExists = FileManager().fileExists(atPath: filePath)
        let mediaURL = URL(string:filePath)!
        if(fileExists) {
            // File is already Saved
            print("Media Already Exist")
            return mediaURL
        }
        else {
            //Save it locally.
            do {
                try data.write(to: mediaURL, options: [])
                print("media Saved")
                return mediaURL
                
            } catch let error {
                print("Got Error on writing the data",error.localizedDescription)
                return nil
            }
        }
    }
}
