//
//  TimeAgoExtension.swift
//  TwitterClient
//
//  Created by Robert Xue on 11/8/15.
//  Copyright © 2015 roboxue. All rights reserved.
//

import Foundation

extension NSDate {
    func timeAgo(formatter: NSDateFormatter) -> String {
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        let earliest = now.earlierDate(self)
        let latest = (earliest == now) ? self : now
        let components: NSDateComponents = calendar.components([NSCalendarUnit.Minute , NSCalendarUnit.Hour , NSCalendarUnit.Day , NSCalendarUnit.WeekOfYear , NSCalendarUnit.Month , NSCalendarUnit.Year , NSCalendarUnit.Second], fromDate: earliest, toDate: latest, options: NSCalendarOptions())
        
        if (components.day >= 1){
            return formatter.stringFromDate(self)
        } else if (components.hour >= 1) {
            return "\(components.hour)h"
        } else if (components.minute >= 1) {
            return "\(components.minute)m"
        } else if (components.second >= 1) {
            return "\(components.second)s"
        } else {
            return "Just now"
        }
    }
}
