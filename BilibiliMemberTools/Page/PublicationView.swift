//
//  Created by ktiays on 2021/5/24.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import SwiftUI
import CyanKit

struct PublicationView: View {
    
    @State private var selection: Int = 0

    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    SegmentedControl(selection: $selection, content: [
                        SegmentItem(id: 0, text: "视频管理"),
                        SegmentItem(id: 1, text: "互动视频管理"),
                        SegmentItem(id: 2, text: "专栏管理"),
                        SegmentItem(id: 3, text: "音频管理")
                    ])
                }
                .padding([.horizontal, .top])
            }
            
            if selection == 0 {
                VideoListView()
            } else {
                Spacer()
            }
        }
    }
    
}

// MARK: - Preview

struct VideoDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PublicationView()
    }
}
