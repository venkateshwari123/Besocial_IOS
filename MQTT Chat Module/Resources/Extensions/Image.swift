//
//  ImageExtension.swift
//  Yelo
//
//  Created by Rahul Sharma on 05/10/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import Foundation
class Image : NSObject {
    
    // prgm mark ----
    // convert images into base64 and keep them into string
    class func convertImageToBase64(image: UIImage) -> String {
        let imageData = image.pngData()
        let base64String = imageData?.base64EncodedString(options: [])
        return base64String!
    }// end convertImageToBase64
    
    
    /// Used for getting image from encoded string
    ///
    /// - Parameter base64String: encoded string
    /// - Returns: UIImage object
    class func convertBase64ToImage(base64String: String) -> UIImage? {
        if let decodedData = NSData(base64Encoded: base64String, options: NSData.Base64DecodingOptions(rawValue: 0)) {
            if let decodedimage = UIImage(data: decodedData as Data, scale:1.0) {
                return decodedimage
            }
        }
        return nil
    }
}
