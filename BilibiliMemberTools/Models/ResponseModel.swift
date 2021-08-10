//
//  Created by ktiays on 2021/8/10.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import Foundation

struct ResponseModel<T>: Codable where T: Codable {
    
    var code: Int
    var message: String
    var data: T
    
}
