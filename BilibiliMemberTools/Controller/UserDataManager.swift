//
//  Created by ktiays on 2021/7/17.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import Foundation
import Combine

class LoadableResource<T, E>: Loadable where E: Error {
    
    typealias Output = T
    typealias Failure = E
    
    typealias CompletionHandler = (Result<T, E>) -> ()
    typealias Loader = (@escaping CompletionHandler) -> ()
    
    private let loader: Loader
    private var _state: CurrentValueSubject<LoadingState<T>, E>?
    
    var state: AnyPublisher<LoadingState<T>, E> {
        if let _state = self._state {
            return _state.eraseToAnyPublisher()
        }
        let _state = CurrentValueSubject<LoadingState<T>, E>(.loading)
        self._state = _state
        performLoading()
        return _state.eraseToAnyPublisher()
    }
    
    init(loader: @escaping Loader) {
        self.loader = loader
    }
    
    private func performLoading() {
        loader { result in
            switch result {
            case let .success(value):
                self._state?.send(.loaded(value))
            case let .failure(error):
                self._state?.send(completion: .failure(error))
            }
        }
    }
    
}

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
