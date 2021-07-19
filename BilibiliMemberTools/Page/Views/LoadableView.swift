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

struct LoadableView<Source, Content>: View where Source: Loadable, Content: View {
    
    private enum SourceState {
        case loading
        case success(Source.Output)
        case failed(Source.Failure)
    }
    
    @State private var sourceState: SourceState = .loading
    
    private let source: Source
    private let contentBuilder: (Source.Output) -> Content
    private var loadingViewBuilder: (() -> AnyView)?
    
    init(source: Source, @ViewBuilder _ content: @escaping (Source.Output) -> Content) {
        self.source = source
        self.contentBuilder = content
    }
    
    var body: some View {
        ZStack {
            EmptyView()
            switch sourceState {
            case .loading:
                loadingViewBuilder?()
            case let .success(output):
                contentBuilder(output)
            case .failed(_):
                EmptyView()
            }
        }
        .onReceive(source.state.map({ output in
            switch output {
            case .loading:
                return SourceState.loading
            case let .loaded(output):
                return SourceState.success(output)
            }
        }).catch({ error in
            Just(SourceState.failed(error))
        })) { sourceState in
            self.sourceState = sourceState
        }
    }
    
    func loadingView<V>(@ViewBuilder _ content: @escaping () -> V) -> some View where V: View {
        var newView = self
        newView.loadingViewBuilder = {
            return AnyView(content())
        }
        return newView
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
