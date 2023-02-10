//
//  DateExtension.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 11/07/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import Foundation
import UIKit

class DateExtension {
    
    func getCurrentDate(forDate dateString: String) -> Date? {
        let dateFormat = DateFormatter()
        dateFormat.timeZone = TimeZone(abbreviation: "GMT")
        dateFormat.dateFormat = "yyyy-MM-dd"
        let thisDate = dateFormat.date(from:dateString)
        return thisDate
    }
    
    func getDateString(fromDate date: Date?) -> String?{
        guard let date = date else { return nil }
        let dateFormat = DateFormatter()
        dateFormat.timeZone = TimeZone(abbreviation: "GMT")
        dateFormat.dateFormat = "yyyy-MM-dd"
        let thisDate = dateFormat.string(from: date)
        return thisDate
    }
    
    func getDataAndTimeForMessageInfo(date: Date) -> String?{
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd-MM-yyyy hh:mm a"
        let time = dateFormat.string(from: date)
        return time
    }
    
    func getDate(forLastSeenTimeString timeString : String) -> Date? {
        let dateFormat = DateFormatter()
        dateFormat.timeZone = TimeZone(abbreviation: "GMT+00:00")
        dateFormat.dateFormat = "yyyyMMddHHmmssSSS z"
        let thisDate = dateFormat.date(from:timeString)
        return thisDate
    }
    
    //    to convert timestamp to date and return nil if timestamp is 0
    func getDateFromDouble(timeStamp: Double)-> Date?{
        if timeStamp <= 0.0{
            return nil
        }
        let timeStampInt = timeStamp/1000
        return Date(timeIntervalSince1970: TimeInterval(timeStampInt))
    }
    
    func sendTimeStamp(fromDate date : Date) -> String? {
        let dateFormat = DateFormatter()
//        dateFormat.timeZone = TimeZone(abbreviation: "GMT")
        dateFormat.timeZone = TimeZone(abbreviation: "GMT+00:00")
        dateFormat.dateFormat = "yyyyMMddHHmmssSSS z"
        let thisDate = dateFormat.string(from: date)
        return thisDate
    }
    
    func getDateString(fromTimeStamp timeStamp: String) -> String {
        if let timeStampObj = UInt64(timeStamp) {
//            let tStamp =  UInt64(timeStamp)!
            let timeStampInt = timeStampObj/1000
            let msgDate = Date(timeIntervalSince1970: TimeInterval(timeStampInt))
            let dateStr = self.lastMessageTime(date: msgDate)
            return dateStr
        }
        return ""
    }
    
    func getDateObj(fromTimeStamp timeStamp: String) -> Date {
        if let timeStampObj = UInt64(timeStamp) {
//        let tStamp =  UInt64(timeStamp)!
        let timeStampInt = timeStampObj/1000
        let msgDate = Date(timeIntervalSince1970: TimeInterval(timeStampInt))
        return msgDate
    }
        return Date()
    }
    
    func lastMessageTime(date: Date)->String {
        let dateFormatter = DateFormatter()
        let today = NSCalendar.current.isDateInToday(date)
        if(today) {
            return "Today".localized
        }
        else if(NSCalendar.current.isDateInYesterday(date)){
            return "Yesterday".localized
        }
        else{
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            let dateString = dateFormatter.string(from: date)
            return dateString
        }
    }
    
    
    
    func lastSeenTime(date : Date) -> String {
        let dateFormatter = DateFormatter()
        let today = NSCalendar.current.isDateInToday(date)
        dateFormatter.dateFormat = "hh:mm a"
        if(today){
            
            return dateFormatter.string(from: date)
        }
        else if(NSCalendar.current.isDateInYesterday(date)){
            return "Yesterday".localized + " \(dateFormatter.string(from: date))"
        }
        else{
            
            dateFormatter.dateStyle = .medium
            let dateString = dateFormatter.string(from: date)
            return dateString
        }
    }
    
    func lastMessageInHours(date : Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.string(from: date)
    }
    
    func relativePast(for date : Date) -> String {
        
        let units = Set<Calendar.Component>([.year, .month, .day, .hour, .minute, .second, .weekOfYear])
        let components = Calendar.current.dateComponents(units, from: date, to: Date())
        
        if components.year! > 0 {
            return "\(components.year!) " + (components.year! > 1 ? "years".localized + " " + "ago".localized : "year".localized + " " + "ago".localized)
            
        } else if components.month! > 0 {
            return "\(components.month!) " + (components.month! > 1 ? "months".localized + " " + "ago".localized : "month".localized + " " + "ago".localized)
            
        } else if components.weekOfYear! > 0 {
            return "\(components.weekOfYear!) " + (components.weekOfYear! > 1 ? "weeks".localized + " " + "ago".localized : "week".localized + " " + "ago".localized)
            
        } else if (components.day! > 0) {
            return (components.day! > 1 ? "\(components.day!) " + "days".localized + " " + "ago".localized : "Yesterday".localized)
            
        } else if components.hour! > 0 {
            return "\(components.hour!) " + (components.hour! > 1 ? "hours".localized + " " + "ago".localized : "hour".localized + " " + "ago".localized)
            
        } else if components.minute! > 0 {
            return "\(components.minute!) " + (components.minute! > 1 ? "minutes".localized + " " + "ago".localized : "minute".localized + "ago".localized)
            
        } else {
            return "\(components.second!) " + (components.second! > 1 ? "seconds".localized + " " + "ago".localized : "second".localized + " " + "ago".localized)
        }
    }
    
    func compareDates(currentDate:Date, previousDate:Date)->Bool{
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: currentDate )
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentDay = calendar.component(.day, from: currentDate)
        let previousYear = calendar.component(.year, from: previousDate)
        let previousMonth = calendar.component(.month, from: previousDate)
        let previousDay = calendar.component(.day, from: previousDate)
        if currentYear == previousYear && currentMonth == previousMonth && currentDay == previousDay{
            return true
        }
        else{
            return false
        }
    }
    
         func differenceDate(date: Date) -> Int {
            let minutes =  Calendar.current.dateComponents([.minute], from: Date(), to: date).minute ?? 0
            return minutes
        }
        
          
}

extension Date {
    func getMonthFormatted() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: self)
    }
    
    func getDateFromTimeStamp(dateString: String, fromFormat : String, toFormate: String) -> String{
               
                 let df = DateFormatter.init()
                 df.dateFormat = fromFormat

                 let date = df.date(from: dateString)
                 df.dateFormat = toFormate
                 return df.string(from: date ?? Date())
             }
          
          func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
              return calendar.dateComponents(Set(components), from: self)
          }

          func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
              return calendar.component(component, from: self)
          }
      

}
