//
//  Created by ktiays on 2021/8/10.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import Foundation

struct EmoticonModel: Codable {
    
    struct Package: Codable {
        var id: Int
        var title: String
        var packageImageURL: String
        var emotes: [Emote]
        
        enum CodingKeys: String, CodingKey {
            case id
            case title = "text"
            case packageImageURL = "url"
            case emotes = "emote"
        }
    }
    
    struct Emote: Codable {
        var id: Int
        var packageID: Int
        var text: String
        var url: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case packageID = "package_id"
            case text
            case url
        }
    }
    
    var packages: [Package]
    
}
