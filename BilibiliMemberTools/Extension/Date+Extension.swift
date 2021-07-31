//
//  Created by ktiays on 2021/5/18.
//  Copyright (c) 2021 ktiays. All rights reserved.
//

import Foundation

extension Date {
    
    var timestamp : Int { Int(self.timeIntervalSince1970) }
    
    static var formatter = DateFormatter()
    
    var formattedString: String { stringFrom(format: "yyyy-MM-dd HH:mm:ss") }
    
    func stringFrom(format: String) -> String {
        Self.formatter.dateFormat = format
        return Self.formatter.string(from: self)
    }
    
}
