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
    
    // MARK: User Information
    
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
    
    // MARK: Member Information
    
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
    
    // MARK: Up Status
    
    public struct UpStatus {
        
        struct VideoStatus {
            var followers: Int = 0
            var replies: Int = 0
            var danmakus: Int = 0
            var videoViews: Int = 0
 
            var coins: Int = 0
            var likes: Int = 0
            var favorites: Int = 0
            var shares: Int = 0

            var batteries: Int = 0
        }
        
        struct ArticleStatus {
            var articleViews: Int = 0
 
            var coins: Int = 0
            var likes: Int = 0
            var favorites: Int = 0
            var replies: Int = 0
            var shares: Int = 0
        }
        
        typealias FollowerData = [Date : Int]
        
        var video: (total: VideoStatus, delta: VideoStatus)
        
        var article: (total: ArticleStatus, delta: ArticleStatus)
        
        var followerTrend: (follow: FollowerData, unfollow: FollowerData)
        
        static func format(string: String?) -> Date {
            guard let string = string else { return Date() }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            return dateFormatter.date(from: string) ?? Date()
        }
        
    }
    
    // MARK: - Properties
    
    var memberInfo: MemberInfo?
    var userInfo: UserInfo?
    var upStatus: UpStatus?
    var videos: [Video] = []
    
}
