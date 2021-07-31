//
//  Created by ktiays on 2021/5/24.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import Foundation

struct Article: Publication {
    
    struct Status {
        
        var views: Int
        var replies: Int
        
        var likes: Int
        var dislikes: Int
        var coins: Int
        var favorites: Int
        
        var shares: Int
        
    }
    
    var cv: String
    var title: String
    var summary: String
    var coverURL: String
    var url: String
    var publishedTime: Date
    var status: Status
    
}
