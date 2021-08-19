//
//  Created by ktiays on 2021/7/31.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import UIKit
import CyanKit
import SwiftUI

func present(_ viewControllerToPresent: UIViewController, animated flag: Bool = true, completion: (() -> Void)? = nil) {
    let topViewController = (UIApplication.shared.connectedScenes.first as! UIWindowScene).keyWindow?.cyan.topViewController
    // Avoid the top view controller presenting other view controller when the top view controller was not completely dismissed.
    if topViewController?.isBeingDismissed == true { return }
    topViewController?.present(viewControllerToPresent, animated: flag, completion: completion)
}

let displayCornerRadius = UIScreen.main.displayCornerRadius

typealias UIHostingView = _UIHostingView
