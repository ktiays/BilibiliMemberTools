//
//  Created by ktiays on 2021/7/31.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import UIKit
import CyanKit

func present(_ viewControllerToPresent: UIViewController, animated flag: Bool = true, completion: (() -> Void)? = nil) {
    DispatchQueue.main.async {
        let topViewController = UIApplication.shared.cyan.keyWindow?.cyan.topViewController
        topViewController?.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}
