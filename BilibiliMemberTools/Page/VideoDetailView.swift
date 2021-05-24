//
//  Created by ktiays on 2021/5/24.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import SwiftUI
import SDWebImageSwiftUI

struct VideoDetailView: View {
    
    @State private var videos: [VideoModel] = []
    
    var body: some View {
        List {
            ForEach(videos) { video in
                VideoCard(video: video.video)
            }
        }
        .onAppear {
            AppContext.shared.requestVideoData { videos in
                self.videos = videos.map { VideoModel(video: $0) }
            }
        }
    }
    
}

fileprivate struct VideoModel: Identifiable {
    
    var id: String { video.bv }
    var video: Video
    
}

// MARK: - VideoCard

fileprivate struct VideoCard: View {
    
    var video: Video
    
    var body: some View {
        HStack {
            WebImage(url: URL(string: video.coverURL))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 80)
            VStack(alignment: .leading) {
                Text(video.title)
                Text(video.publishedTime.description)
            }
            Spacer()
        }
    }
    
}

// MARK: - Preview

struct VideoDetailView_Previews: PreviewProvider {
    static var previews: some View {
        VideoDetailView()
        VideoCard(video: Video(
                    title: "hahahaha",
                    coverURL: "http://i1.hdslb.com/bfs/archive/270c5219bb7a3ecdfad84f72b99501b85ddf5d05.jpg",
                    publishedTime: Date(),
                    av: "1837236854",
                    bv: "BV1Vb4y1f7m4",
                    description: "Description",
                    duration: 125,
                    status: Video.Status(
                        views: 1235134,
                        danmaku: 234,
                        replies: 45324,
                        likes: 8345,
                        coins: 2347,
                        favorites: 36,
                        shares: 567)
        ))
    }
}
