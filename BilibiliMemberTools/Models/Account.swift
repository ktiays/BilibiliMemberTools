//
//  Created by ktiays on 2021/5/20.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import Foundation

struct Account {
    
    struct Info {
        var birthday: Date
        var uid: String
        var signature: String
        var username: String
        var userID: String
        var rank: String
        
        static func format(string: String?) -> Date? {
            guard let string = string else { return nil }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.date(from: string) ?? Date()
        }
    }
    
}
