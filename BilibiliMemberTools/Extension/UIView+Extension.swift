//
//  Created by ktiays on 2021/7/19.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import UIKit

extension UIView {
    
    var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
            layer.cornerCurve = .circular
        }
        get { layer.cornerRadius }
    }

    var continuousCornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
            layer.cornerCurve = .continuous
        }
        get { layer.cornerRadius }
    }
    
}
