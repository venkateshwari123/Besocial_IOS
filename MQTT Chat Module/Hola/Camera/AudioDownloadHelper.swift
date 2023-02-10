//
//  AudioDownloadHelper.swift
//  dub.ly
//
//  Created by 3Embed Software Tech Pvt Ltd on 30/01/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class AudioDownloadHelper: NSObject {

    
    func downloadAudioFile(audioUrl:String, completionHandler: @escaping (_ result:Bool, _ error: String) -> Void){
        if let audioUrl = URL(string: audioUrl) {
            
            // then lets create your document folder url
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            print(destinationUrl)
            
            // to check if it exists before downloading it
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                print("The file already exists at path")
                completionHandler(true,"")
            } else {
                
                Helper.showPI()
                // if the file doesn't exist
                // you can use NSURLSession.sharedSession to download the data asynchronously
                URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) -> Void in
                    guard let location = location, error == nil else {
                        DispatchQueue.main.async {
                            Helper.hidePI()
                        }
                        return }
                    do {
                        // after downloading your file you need to move it to your destination url
                        try FileManager.default.moveItem(at: location, to: destinationUrl)
                        print("File moved to documents folder")
                        DispatchQueue.main.async {
                            Helper.hidePI()
                            completionHandler(true,"")
                        }
                    } catch let error as NSError {
                        DispatchQueue.main.async {
                            Helper.hidePI()
                        }
                        print(error.localizedDescription)
                        completionHandler(false,error.localizedDescription)
                    }
                }).resume()
            }
        }
    }
    
}


open class ImageSaveHelper {
     static func saveImageDocumentDirectory(imageToSave:UIImage , completionHandler: @escaping (_ imagePath:String) -> Void){
        let fileManager = FileManager.default
        let timeStamp = Helper.getcurrentDataAndtimeForSave()
        
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(timeStamp).jpg")
        let imageData = imageToSave.jpegData(compressionQuality: 0.5)
        fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
        completionHandler(paths)
    }
}
