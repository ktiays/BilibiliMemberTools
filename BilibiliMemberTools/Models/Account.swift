//
//  Created by ktiays on 2021/5/20.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import UIKit

struct Account {
    
    enum Sex {
        case male
        case female
        case unknown
    }
    
    struct UserInfo {
        
        struct Certification {
            
            enum Role {
                case none
                case personal
                case institutional
            }
            
            var type: Role
            var description: String
            var remake: String
        }
        
        struct VIP {
            
            enum Level: Int {
                case none = 0
                case monthly = 1
                case annual = 2
            }
            
            var type: Level
            var expired: Date
            var nickNameColor: UIColor
            var description: String
            
        }
        
        var uid: String
        var username: String
        var sex: Sex
        var avatarURL: String
        var signature: String
        var level: Int
        var coins: Double
        var certification: Certification
        var vip: VIP
    }
    
    struct MemberInfo {
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
    
    public struct UpStatus {
        
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
