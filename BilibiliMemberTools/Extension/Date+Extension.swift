//
//  Created by ktiays on 2021/5/18.
//  Copyright (c) 2021 ktiays. All rights reserved.
//

import Foundation

extension Date {
    
    var timestamp : Int {
        Int(self.timeIntervalSince1970)
    }
    
}
