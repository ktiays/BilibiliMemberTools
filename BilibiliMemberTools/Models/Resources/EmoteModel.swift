//
//  Created by ktiays on 2021/8/10.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import Foundation

typealias EmotePackage = EmoteModel

struct EmoteModel: Codable {
    
    struct Package: Identifiable, Codable {
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
    
    struct Emote: Identifiable, Codable {
        var id: Int
        var packageID: Int
        var text: String
        var url: String
        var type: EmoteType
        
        enum CodingKeys: String, CodingKey {
            case id
            case packageID = "package_id"
            case text
            case url
            case type
        }
        
        enum EmoteType: Codable {
            case unknown
            case emoji
            case emoticon
            
            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                let status = try? container.decode(Int.self)
                switch status {
                case 1:
                    self = .emoji
                case 4:
                    self = .emoticon
                default:
                    self = .unknown
                }
            }
        }
    }
    
    var packages: [Package]
    
}
