//
//  Extensions.swift
//  NormalNews
//
//  Created by Henry Silva Olivo on 5/4/22.
//

import Foundation

extension Date {
    
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
}
