//
//  Created by ktiays on 2021/5/24.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import Foundation

struct Video: Publication {
    
    struct Status {
        
        var views: Int
        var danmakus: Int
        var replies: Int
        
        var likes: Int
        var coins: Int
        var favorites: Int
        
        var shares: Int
        
    }
    
    var title: String
    var coverURL: String
    var publishedTime: Date
    var av: String
    var bv: String
    var description: String
    var duration: Int
    var status: Status
    
}
