//
//  Created by ktiays on 2021/5/22.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import UIKit
import SwiftUI

// MARK: Initialization Method

extension UIColor {
    
    convenience init(hex: String) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            self.init()
            return
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
}

// MARK: Properties

extension UIColor {
    
    static var accentColor: UIColor { .init(named: "AccentColor") ?? .clear }
    
}

extension Color {
    
    static func accentBackgroundColor(for colorScheme: ColorScheme) -> Color {
        .accentColor.opacity(colorScheme == .dark ? 0.08 : 0.04)
    }
    
}
