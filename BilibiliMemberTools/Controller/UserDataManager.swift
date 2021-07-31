//
//  Created by ktiays on 2021/7/17.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import Foundation
import SwiftUI

class UserDataManager {
    
    typealias RelationResource = LoadableResource<TimestampedState<Relation>, APIManager.APIError>
    
    static let `default` = UserDataManager()
    
    private var relationCache = [String : RelationResource]()
    
    func removeAllCaches() {
        relationCache.removeAll()
    }
    
    func relation(with uid: String) -> RelationResource {
        if let cachedResource = relationCache[uid] {
            return cachedResource
        }
        
        let resource = RelationResource { completion in
            APIManager.shared.relation(with: uid) { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
        relationCache[uid] = resource
        return resource
    }
    
    func requestVideos() {
        withAsync {
            APIManager.shared.videos(for: [.published, .rejected, .reviewing]) { result in
                guard let videos = try? result.get() else { return }
                withMainQueue {
                    Self.cacher.videos.append(contentsOf: videos)
                }
            }
        }
    }
    
    func requestArticles() {
        withAsync {
            APIManager.shared.articles { result in
                do {
                    let articles = try result.get()
                    withMainQueue {
                        Self.cacher.articles.append(contentsOf: articles)
                    }
                } catch {}
            }
        }
    }
    
}

// MARK: - Cacher

extension UserDataManager: ObservableObject {
    
    class Cacher: ObservableObject {
        @Published var videos = [Video]()
        @Published var articles = [Article]()
        
        func removeAll() {
            videos.removeAll()
            articles.removeAll()
        }
    }
    
    static let cacher: Cacher = .init()
    
}
