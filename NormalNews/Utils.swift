//
//  Utils.swift
//  NormalNews
//
//  Created by Henry Silva Olivo on 5/4/22.
//

import Foundation

class Utils{
    
    static func convert_timestamp_to_date(_ timestamp: Int) -> Date{
        
        let epocTime = TimeInterval(timestamp)
        //let myDate = NSDate(timeIntervalSince1970: epocTime)

        return Date.init(timeIntervalSince1970: epocTime)
    }
    
}
