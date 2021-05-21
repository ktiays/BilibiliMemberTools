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
        
        static func format(string: String?) -> Date {
            guard let string = string else { return Date() }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.date(from: string) ?? Date()
        }
    }
    
    struct UpStatus {
        
        struct VideoData {
            var followers: Int
            var replies: Int
            var danmakus: Int
            var videoViews: Int

            var coins: Int
            var likes: Int
            var favorites: Int
            var shares: Int
            
            var batteries: Int
        }
        
        typealias FollowerData = [Date : Int]
        
        var delta: VideoData
        
        var total: VideoData
        
        var followerTrend: (follow: FollowerData, unfollow: FollowerData)
        
        static func format(string: String?) -> Date {
            guard let string = string else { return Date() }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            return dateFormatter.date(from: string) ?? Date()
        }
        
    }
    
}
