//
//  Created by ktiays on 2021/5/24.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import Foundation

protocol Publication {
    
    var title: String { get set }
    
    var coverURL: String { get set }
    
    var publishedTime: Date { get set }
    
}
