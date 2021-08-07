//
//  Created by ktiays on 2021/8/7.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import SwiftUI

struct InteractiveTag: View {
    
    var image: Image
    var value: String
    
    var body: some View {
        HStack(spacing: 3) {
            image
            Text(value)
        }
        .font(.system(size: 10))
        .foregroundColor(.init(.secondaryLabel))
    }
    
}
