//
//  Created by ktiays on 2021/7/17.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import Foundation

class UserDataManager {
    
    typealias RelationResource = LoadableResource<TimestampedState<Relation>, APIManager.APIError>
    
    static let `default` = UserDataManager()
    
    private var cache = [String : RelationResource]()
    
    func relation(with uid: String) -> RelationResource {
        if let cachedResource = cache[uid] {
            return cachedResource
        }
        
        let resource = RelationResource { completionHandler in
            APIManager.shared.relation(with: uid) { result in
                DispatchQueue.main.async {
                    completionHandler(result)
                }
            }
        }
        cache[uid] = resource
        return resource
    }
    
}
