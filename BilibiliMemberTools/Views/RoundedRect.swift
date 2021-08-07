//
//  Created by ktiays on 2021/7/31.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import UIKit
import SwiftUI

class RoundedRectView: UIView {
    
    func updateCorner(radius: CGFloat, corners: UIRectCorner, style: RoundedCornerStyle) {
        layer.cornerRadius = radius
        layer.cornerCurve = (style == .circular ? .circular : .continuous)
        var cornerMask: CACornerMask = .init()
        if corners.contains(.topLeft) {
            cornerMask.insert(.layerMinXMinYCorner)
        }
        if corners.contains(.topRight) {
            cornerMask.insert(.layerMaxXMinYCorner)
        }
        if corners.contains(.bottomLeft) {
            cornerMask.insert(.layerMinXMaxYCorner)
        }
        if corners.contains(.bottomRight) {
            cornerMask.insert(.layerMaxXMaxYCorner)
        }
        layer.maskedCorners = cornerMask
    }
    
}

struct RoundedRect: UIViewRepresentable {
    
    var cornerRadius: CGFloat
    var corners: UIRectCorner
    var style: RoundedCornerStyle
    
    func makeUIView(context: Context) -> RoundedRectView {
        let view  = RoundedRectView()
        view.backgroundColor = .black
        view.updateCorner(radius: cornerRadius, corners: corners, style: style)
        return view
    }
    
    func updateUIView(_ uiView: RoundedRectView, context: Context) {
        uiView.updateCorner(radius: cornerRadius, corners: corners, style: style)
    }
    
}
