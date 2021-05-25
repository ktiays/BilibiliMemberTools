//
//  RoundedCorner.swift
//  BilibiliMemberTools
//
//  Created by ktiays on 2021/5/25.
//

import SwiftUI

struct RoundedCorner: Shape {
    
    var radius: CGFloat = .zero
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        Path(UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius)).cgPath)
    }
    
}

struct RoundedCorner_Previews: PreviewProvider {
    static var previews: some View {
        RoundedCorner()
    }
}
