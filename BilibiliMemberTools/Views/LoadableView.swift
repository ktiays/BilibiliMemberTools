//
//  Created by ktiays on 2021/7/17.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import Foundation
import SwiftUI
import Combine

enum LoadingState<ResultType> {
    case loading
    case loaded(ResultType)
}

protocol Loadable: ObservableObject {
    
    associatedtype Output
    associatedtype Failure: Error
    
    var state: AnyPublisher<LoadingState<Output>, Failure> { get }
    
}

struct LoadableView<Source, Content, Resource>: View where Source: Loadable, Content: View {
    
    private enum SourceState {
        case loading
        case success(Resource)
        case failed(Source.Failure)
    }
    
    @State private var sourceState: SourceState = .loading
    
    private let source: Source
    private let contentBuilder: (Resource) -> Content
    private let resourceMapper: (Source.Output) -> Resource
    private var loadingViewBuilder: (() -> AnyView)?
    
    init(source: Source, resourceMapper: @escaping (Source.Output) -> Resource, @ViewBuilder _ content: @escaping (Resource) -> Content) {
        self.source = source
        self.resourceMapper = resourceMapper
        self.contentBuilder = content
    }
    
    var body: some View {
        ZStack {
            switch sourceState {
            case .loading:
                loadingViewBuilder?()
            case let .success(output):
                contentBuilder(output)
            case .failed(_):
                Optional<Never>.none
            }
        }
        .onReceive(source.state.map({ output in
            switch output {
            case .loading:
                return SourceState.loading
            case let .loaded(output):
                return SourceState.success(resourceMapper(output))
            }
        }).catch({ error in
            Just(SourceState.failed(error))
        })) { sourceState in
            self.sourceState = sourceState
        }
    }
    
    func loadingView<V>(@ViewBuilder _ content: @escaping () -> V) -> some View where V: View {
        var newView = self
        newView.loadingViewBuilder = { AnyView(content()) }
        return newView
    }
    
}

extension LoadableView where Source.Output == Resource {
    
    init(source: Source, @ViewBuilder _ content: @escaping (Resource) -> Content) {
        self.source = source
        self.resourceMapper = { $0 }
        self.contentBuilder = content
    }
    
}

// MARK: - Preview

struct LoadableView_Previews: PreviewProvider {
    
    static var previews: some View {
        PreviewView()
    }
    
    private struct PreviewView: View {
        
        var body: some View {
            EmptyView()
        }
        
    }
    
}
