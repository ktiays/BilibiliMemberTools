//
//  Created by ktiays on 2021/5/22.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import Foundation

extension Int {
    
    var integerDescription: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? .init()
    }
    
    init(count: Int) {
        self.init(pow(10, Double(count - 1)))
    }
    
}
