//
//  Created by ktiays on 2021/7/18.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import UIKit

extension UIImage {
    
    class func colorImage(with color: UIColor) -> UIImage? {
        let size: CGSize = .init(width: 1, height: 1)
        UIGraphicsBeginImageContext(size)
        guard let context = UIGraphicsGetCurrentContext() else {
            assert(false, "Get current graphics context failed.")
        }
        context.setFillColor(color.cgColor)
        context.fill(.init(origin: .zero, size: size))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return colorImage
    }
    
}
