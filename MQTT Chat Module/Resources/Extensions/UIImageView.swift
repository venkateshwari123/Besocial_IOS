//
//  UIImageView.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 17/08/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import Foundation
import Kingfisher
import Cloudinary
import Accelerate

extension UIImageView{
    
    
    /// Set image with animation
    ///
    /// - Parameter image: image to assign
    func setImageWithFadeAnimation(image: UIImage){
        UIView.transition(with: self,
                          duration: 0.50,
                          options: .transitionCrossDissolve,
                          animations: {
                          self.image = image
        },completion: nil)
    }
    
    /// To set Image on a image view
    ///
    /// - Parameters:
    ///   - imageUrl: Url of image to assign on an image view
    ///   - defaultImage: default   view to set on it
    func setImageOn(imageUrl: String?, defaultImage: UIImage, isThumbnail:Bool = false){
        if var url = imageUrl {
            self.kf.indicatorType = .activity
            self.kf.indicator?.startAnimatingView()
             if !url.contains("dubly")  && !url.contains("dafszph29")   {
            url = url.replace(target: "upload/", withString: "upload/q_60/")
            }
            URLCache.shared.removeAllCachedResponses()
//            DispatchQueue.global().async {
                self.kf.setImage(with: URL(string: url), placeholder: defaultImage, options: [.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: { (image, error, CacheType, url) in
                     self.kf.indicator?.stopAnimatingView()
                })
//            }
        }else{
            self.image = defaultImage
        }
    }
    
    func setGifOnImage(imageUrl: String?, defaultImage: UIImage){
        if let url = imageUrl{
            let cloudinary = CLDCloudinary(configuration: CLDConfiguration(cloudName:"deu1yq6y6", secure: true))
            self.cldSetImage(cloudinary.createUrl().setTransformation(CLDTransformation().setWidth(200).setHeight(200).setCrop("fill")).generate(url)!, cloudinary: cloudinary)
        }
    }
}
extension Date {
    
    func offsetFrom(date : Date) -> String {
        
        let dayHourMinuteSecond: Set<Calendar.Component> = [.day, .hour, .minute, .second]
        let difference = NSCalendar.current.dateComponents(dayHourMinuteSecond, from: date, to: self);
        
        if let days  = difference.day,days > 0 {
            if days == 1 {
                return "\(days) " + "Day".localized + " " + "Ago".localized
            }
            return "\(days) " + "Days".localized + " " + "Ago".localized
        }
        
        if let hours  = difference.hour,hours > 0 {
            if hours == 1 {
                return "\(hours) " + "Hour".localized + " " + "Ago".localized
            }
            return "\(hours) " + "Hours".localized + " " + "Ago".localized
        }
        
        if let minutes  = difference.minute,minutes > 0 {
            if minutes == 1 {
                return "\(minutes) " + "Minute".localized + " " + "Ago".localized
            }
            return "\(minutes) " + "Minutes".localized + " " + "Ago".localized
        }
        
        if let second  = difference.second,second > 0 {
            if second == 1 {
                return "\(second) " + "Second".localized + " " + "Ago".localized
            }
            return "\(second) " + "Seconds".localized + " " + "Ago".localized
        }
        
        return ""
    }
    
}

extension UIImage {
    func resizeImageUsingVImage(size:CGSize) -> UIImage? {
         let cgImage = self.cgImage!
         var format = vImage_CGImageFormat(bitsPerComponent: 8, bitsPerPixel: 32, colorSpace: nil, bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue), version: 0, decode: nil, renderingIntent: CGColorRenderingIntent.defaultIntent)
         var sourceBuffer = vImage_Buffer()
         defer {
              free(sourceBuffer.data)
         }
        var error = vImageBuffer_InitWithCGImage(&sourceBuffer, &format, nil, cgImage, numericCast(kvImageNoFlags))
         guard error == kvImageNoError else { return nil }
       // create a destination buffer
       let scale = self.scale
       let destWidth = Int(size.width)
       let destHeight = Int(size.height)
       let bytesPerPixel = self.cgImage!.bitsPerPixel/8
       let destBytesPerRow = destWidth * bytesPerPixel
       let destData = UnsafeMutablePointer<UInt8>.allocate(capacity: destHeight * destBytesPerRow)
       defer {
             destData.deallocate()
       }
      var destBuffer = vImage_Buffer(data: destData, height: vImagePixelCount(destHeight), width: vImagePixelCount(destWidth), rowBytes: destBytesPerRow)
    // scale the image
     error = vImageScale_ARGB8888(&sourceBuffer, &destBuffer, nil, numericCast(kvImageHighQualityResampling))
     guard error == kvImageNoError else { return nil }
     // create a CGImage from vImage_Buffer
     var destCGImage = vImageCreateCGImageFromBuffer(&destBuffer, &format, nil, nil, numericCast(kvImageNoFlags), &error)?.takeRetainedValue()
    guard error == kvImageNoError else { return nil }
    // create a UIImage
     let resizedImage = destCGImage.flatMap { UIImage(cgImage: $0, scale: 0.0, orientation: self.imageOrientation) }
     destCGImage = nil
    return resizedImage
    }
}
