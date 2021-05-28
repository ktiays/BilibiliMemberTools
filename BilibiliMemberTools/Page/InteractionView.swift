//
//  Created by ktiays on 2021/5/28.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import SwiftUI

struct InteractionView: View {
    
    @EnvironmentObject var badgeValue: BadgeValue
    
    var body: some View {
        Text("Interaction View")
            .onAppear {
                badgeValue.value = .init()
            }
    }
    
}

// MARK: - Preview

struct InteractionView_Previews: PreviewProvider {
    static var previews: some View {
        InteractionView()
    }
}
