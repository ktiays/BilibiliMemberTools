//
//  Created by ktiays on 2021/8/11.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import SwiftUI

struct EmoticonPanel: View {
    
    var body: some View {
        VStack {
            
        }
        .task {
            do {
                let emoticon = try await APIManager.shared.emoticon()
                print(emoticon)
            } catch {}
        }
    }
    
}

// MARK: - Preview

struct EmoticonPanel_Previews: PreviewProvider {
    static var previews: some View {
        EmoticonPanel()
    }
}
