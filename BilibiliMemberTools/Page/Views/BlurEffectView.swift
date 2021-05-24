//
//  Created by ktiays on 2021/5/24.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import SwiftUI

class CustomVisualEffectView: UIVisualEffectView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for subview in subviews {
            if NSStringFromClass(type(of: subview)) == "_UIVisualEffectBackdropView" {
                let layer = subview.layer
                let filters = layer.value(forKey: "filters") as! [NSObject]
                var newFilters = [NSObject]()
                for filter in filters {
                    if filter.value(forKey: "name") as! NSString == "gaussianBlur" {
                        filter.setValue(7, forKey: "inputRadius")
                        newFilters.append(filter)
                    }
                }
                layer.setValue(newFilters, forKey: "filters")
            } else if NSStringFromClass(type(of: subview)) == "_UIVisualEffectSubview" {
                subview.backgroundColor = .clear
            }
        }
    }
    
}

struct BlurEffectView: UIViewRepresentable {
    
    var style: UIBlurEffect.Style = .systemMaterial
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> CustomVisualEffectView {
        CustomVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: CustomVisualEffectView, context: UIViewRepresentableContext<Self>) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
