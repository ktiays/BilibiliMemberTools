//
//  Created by ktiays on 2021/12/12.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import UIKit

class PassthroughView: UIView {

    /// Called when a touch event may pass through the view, the
    /// closure returns a Boolean value that indicates whether
    /// the event should be passed through.
    var shouldPassthroughPrediction: (() -> Bool)? = nil
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView === self {
            if let prediction = shouldPassthroughPrediction {
                return prediction() ? nil : hitView
            }
            return nil
        }
        return hitView
    }

}
