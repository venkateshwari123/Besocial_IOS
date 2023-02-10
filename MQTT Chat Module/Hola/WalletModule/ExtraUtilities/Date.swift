//
//  Date.swift
//  Ufy_Store
//
//  Created by Raghavendra Shedole on 22/01/18.
//  Copyright © 2018 Nabeel Gulzar. All rights reserved.
//

import Foundation

//DateFormats
struct DateFormat {
    
    static let ISODateFormat                            = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    static let DateAndTimeFormatServer                  = "yyyy-MM-dd HH:mm:ss"
    static let TimeAndDateFormatServer                  = "HH:mm:ss dd-MM-yyyy"
    static let DateAndTimeFormatServerGET               = "yyyyMMddHHmmss"
    static let DateFormatToDisplay                      = "dd MMM yyyy"
    static let DateFormatServer                         = "yyyy-MM-dd"
    static let TimeFormatServer                         = "HH:mm"
    static let TimeFormatToDisplay                      = "hh:mm a"
    static let OrderDateFormate                         = "hh:mm a, dd MMM"
    static let DateOfBirthFormat                        = "MM/dd/yyyy"
    static let onlyTime                                 = "hh:mm a"
    static let onlyDate                                 = "dd MMM"
    static let fullDate                                 = "dd MMM YYYY"
    static let tfDate                                   = "MM-dd-yyyy"
}

enum RequiredDate {
    case Mins
    case HourMins
}

extension Date {
    
    func getDateFromString(value:String,format:String) -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormat.DateAndTimeFormatServer
        
        if formatter.date(from: value) == nil {
            return formatter.string(from: Date())
        }else {
            let someDate = formatter.date(from: value)
            let date = Helper.convertGMTDateToLocalFromDate(gmtDate: someDate!)
            formatter.dateFormat = format
            return formatter.string(from: date)
        }
    }
    
    /// return curent date in yyyy-MM-dd HH:mm:ss as string
    func getCurrentData() -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormat.DateAndTimeFormatServer
        return formatter.string(from: Date.init())
        
    }
    
    func getRemainingDaysFromTimeStamp(timeStamp: Double) -> Int? {
        // converts timestamp to date then give difference from now to future date *in days count*
        let timeStampInt = UInt64(UInt64(timeStamp)/1000)
        let msgDate = Date(timeIntervalSince1970: TimeInterval(timeStampInt))
        let calendar = Calendar.current
        let date1 = calendar.startOfDay(for: Date())
        let date2 = calendar.startOfDay(for: msgDate)
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        let days = components.day
        return days
    }
    
    func getTheDataFromTimeStamp(value:Int64,format:String) -> String {
        
        let formatter = DateFormatter()
        let timestamp = Date(timeIntervalSince1970: TimeInterval(value))
        _ = Helper.convertGMTDateToLocalFromDate(gmtDate: timestamp)
        formatter.dateFormat = format
        return formatter.string(from: timestamp)
    }
    
    func getDateFromTimeStampwithFormat(value:Double, format: String) -> String{
        let date = Date(timeIntervalSince1970: value)
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = .current
        return formatter.string(from: date)
    }
    
    
    func timeStamp() -> String {
        return String(self.timeIntervalSince1970 * 1000)
    }
    
    func timeStampInt() -> Int {
        return Int(self.timeIntervalSince1970 * 1000)
    }
    
    func getDueTime(value:String) -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormat.DateAndTimeFormatServer
        
        var dueTime:Date
        if formatter.date(from: value) == nil {
            dueTime  = Date()
        }else {
            let date = formatter.date(from: value)!
            dueTime = Helper.convertGMTDateToLocalFromDate(gmtDate: date)
        }
        
        return DateComponentsFormatter().difference(from:dueTime, to: Helper.convertGMTDateToLocalFromDate(gmtDate: Date()))!
    }
    
    func dateDifference(dueDate:String, bookingDate:String) ->String {
        let toDate = getStringToDate(value: dueDate, format: DateFormat.DateAndTimeFormatServer)
        let fromDate = getStringToDate(value: bookingDate, format: DateFormat.DateAndTimeFormatServer)
        
        return DateComponentsFormatter().difference(from: fromDate, to: toDate)!
    }
    
    func isValidDate(dateString: String  , format : String) -> Bool {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = format
        if let _ = dateFormatterGet.date(from: dateString) {
            //date parsing succeeded, if you need to do additional logic, replace _ with some variable name i.e date
            return true
        } else {
            // Invalid date
            return false
        }
    }
    
    func getDateString(dateFormat:String, requiredDateFormat:String, dateValue:String) -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        if formatter.date(from: dateValue) == nil {
            return formatter.string(from: Helper.convertGMTDateToLocalFromDate(gmtDate: Date()))
        }else {
            let someDate = formatter.date(from: dateValue)
            
            formatter.dateFormat = requiredDateFormat
            return formatter.string(from: Helper.convertGMTDateToLocalFromDate(gmtDate: someDate!))
        }
    }
    
    func stringFromTimeInterval(interval:TimeInterval) -> NSString {
        let time = NSInteger(interval)
        let minutes = time / 60
        return NSString(format: "%d",Int(minutes))
    }
    
    func getDateString(value:Date,format:String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let myString = formatter.string(from: value)
        return myString
    }

    func toGlobalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    // Convert UTC (or GMT) to local time
    func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    func getCurrentDateAndTime() -> String{
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        
        formatter.dateFormat = DateFormat.DateAndTimeFormatServer
        let dateString = formatter.string(from: now)
        return dateString
    }
    
    func getStringToDate(value:String,format:String) -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: "en_US_POSIX")// for 24 hours
        formatter.dateFormat = format
        if formatter.date(from: value) == nil {
            return Helper.convertGMTDateToLocalFromDate(gmtDate: Date())
        }else {
            let date = formatter.date(from: value)!
            return Helper.convertGMTDateToLocalFromDate(gmtDate: date)
        }
    }
    
    func convertStringToDate( value:String,format:String ) -> Date{
        let dateFormatter = DateFormatter()
        print(format)
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
        dateFormatter.dateFormat = format //Your date format
        
        //according to date format your date string
        guard let date = dateFormatter.date(from: value) else {
            print("error........  date conversion failed")
            fatalError()
        }
        print(date)
        return date
    }
    
    func getStringToDateFromTimeStamp(value:Int64,format:String) -> Date {
        
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormat.DateAndTimeFormatServer
        let timestamp = Date(timeIntervalSince1970: TimeInterval(value))
        let date = Helper.convertGMTDateToLocalFromDate(gmtDate: timestamp)
        formatter.dateFormat = format
        let newDate = formatter.string(from: date)
        return formatter.date(from: newDate)!
    }
    
    /// return current time stamp in Double formate
    var getTimeStamp: Double {
        return Double(self.timeIntervalSince1970 * 1000)
    }
    
    func adding(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
    
    func adding(years: Int)-> Date{
        return Calendar.current.date(byAdding: .year, value: years, to: self)!
    }
    
    func adding(days: Int)-> Date{
        return Calendar.current.date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(months: Int)-> Date{
        return Calendar.current.date(byAdding: .month, value: months, to: self)!
    }
}

extension DateComponentsFormatter {
    func difference(from fromDate: Date, to toDate: Date) -> String? {
        self.allowedUnits = [.day, .hour,.minute]
        self.maximumUnitCount = 0
        self.unitsStyle = .full
        return self.string(from: fromDate, to: toDate)?.replacingOccurrences(of: "-", with: "")
    }
}

extension Date {
    func differenceDate(date: Date) -> Int {
        let minutes =  Calendar.current.dateComponents([.minute], from: Date(), to: date).minute ?? 0
        return minutes
    }
 
}


extension Date {

    func timeAgoSinceDate() -> String {

        // From Time
        let fromDate = self

        // To Time
        let toDate = Date()

        // Estimation
        // Year
        if let interval = Calendar.current.dateComponents([.year], from: fromDate, to: toDate).year, interval > 0  {

            return interval == 1 ? "\(interval)" + " " + "year ago" : "\(interval)" + " " + "years ago"
        }

        // Month
        if let interval = Calendar.current.dateComponents([.month], from: fromDate, to: toDate).month, interval > 0  {

            return interval == 1 ? "\(interval)" + " " + "month ago" : "\(interval)" + " " + "months ago"
        }

        // Day
        if let interval = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day, interval > 0  {

            return interval == 1 ? "\(interval)" + " " + "day ago" : "\(interval)" + " " + "days ago"
        }

        // Hours
        if let interval = Calendar.current.dateComponents([.hour], from: fromDate, to: toDate).hour, interval > 0 {

            return interval == 1 ? "\(interval)" + " " + "hour ago" : "\(interval)" + " " + "hours ago"
        }

        // Minute
        if let interval = Calendar.current.dateComponents([.minute], from: fromDate, to: toDate).minute, interval > 0 {

            return interval == 1 ? "\(interval)" + " " + "minute ago" : "\(interval)" + " " + "minutes ago"
        }

        return "a moment ago"
    }
}
