//
//  Created by ktiays on 2021/7/17.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import Foundation

struct TimestampedState<S> {
    var state: S
    var timestamp: TimeInterval
}

struct User {
    
    var uid: String
    var username: String
    var avatarURL: String
    
}

enum Relation {
    // There is no relation between you and this user.
    case none
    // You are following this user.
    case following
    // This user is following you.
    case followed
    // You and this user is following each other.
    case friend
    // This user is blacklisted.
    case blacklist
}
