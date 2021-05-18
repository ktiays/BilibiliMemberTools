//
//  Date+Extension.swift
//  BilibiliMemberTools
//
//  Created by ktiays on 2021/5/18.
//

import Foundation

extension Date {
    
    var timestamp : Int {
        Int(self.timeIntervalSince1970)
    }
    
}
