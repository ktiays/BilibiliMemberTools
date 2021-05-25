//
//  View+Extension.swift
//  BilibiliMemberTools
//
//  Created by ktiays on 2021/5/25.
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
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners) )
    }
    
}
