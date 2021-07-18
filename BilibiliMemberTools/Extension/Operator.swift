//
//  Created by ktiays on 2021/7/18.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import CoreGraphics
import Foundation

func > (_ lhs: Int?, _ rhs: Int) -> Bool { if let lhs = lhs { return lhs > rhs } else { return false } }

func * (_ lhs: CGSize, _ rhs: CGFloat) -> CGSize { .init(width: lhs.width * rhs, height: lhs.height * rhs) }
