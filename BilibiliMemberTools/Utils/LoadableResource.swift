//
//  Created by ktiays on 2021/7/18.
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
