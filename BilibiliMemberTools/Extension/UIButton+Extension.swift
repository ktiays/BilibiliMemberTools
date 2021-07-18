//
//  Created by ktiays on 2021/7/18.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import UIKit

extension UIButton {
    
    func setBackgroundColor(_ color: UIColor?, for state: UIControl.State) {
        setBackgroundImage(UIImage.colorImage(with: color ?? .clear), for: state)
    }
    
}
