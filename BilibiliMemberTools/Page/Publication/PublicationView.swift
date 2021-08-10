//
//  Created by ktiays on 2021/5/24.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import SwiftUI
import CyanKit
import Introspect

struct PublicationView: View {
    
    @State private var selection: Int = 0
    @State private var scrollView: UIScrollView?

    var body: some View {
        VStack {
            SegmentedControl(selection: $selection, content: [
                SegmentItem(id: 0, text: "视频管理"),
                SegmentItem(id: 1, text: "专栏管理"),
                SegmentItem(id: 2, text: "音频管理")
            ], scrollable: false)
            .padding(.top)
            
            switch selection {
            case 0:
                VideoListView()
            case 1:
                ArticleListView()
            case 2:
                EmoticonPanel()
            default:
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
