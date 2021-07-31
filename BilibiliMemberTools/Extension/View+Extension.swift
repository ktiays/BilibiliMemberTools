//
//  Created by ktiays on 2021/5/25.
//  Copyright (c) 2021 ktiays. All rights reserved.
//

import SwiftUI

fileprivate struct InnerBottomPaddingKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}

extension EnvironmentValues {
    var innerBottomPadding: CGFloat {
        get { self[InnerBottomPaddingKey.self] }
        set { self[InnerBottomPaddingKey.self] = newValue }
    }
}

public extension View {
    
    func innerBottomPadding(_ value: CGFloat) -> some View {
        environment(\.innerBottomPadding, value)
    }
    
    @inline(__always) func cornerRadius(_ radius: CGFloat = 10, corners: UIRectCorner = .allCorners, style: RoundedCornerStyle = .circular) -> some View {
        mask {
            RoundedRect(cornerRadius: radius, corners: corners, style: style)
        }
    }
    
}

public extension View {
    
    func loadingView<Content>(when condition: Bool, @ViewBuilder _ content: () -> Content) -> some View where Content: View {
        condition ? AnyView(hidden().overlay(content())) : AnyView(self)
    }
    
}
