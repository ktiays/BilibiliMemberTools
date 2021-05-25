//
//  Created by ktiays on 2021/5/26.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import SwiftUI
import SDWebImageSwiftUI
import Introspect

struct VideoListView: View {
    
    @State private var videos: [VideoModel] = []
    
    @Environment(\.innerBottomPadding) private var innerBottomPadding;
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer()
                    .frame(height: 0)
                ForEach(videos.isEmpty ? VideoModel.placeholder : videos) { video in
                    VideoCard(video: video.video)
                }
                Spacer()
                    .frame(height: max(0, innerBottomPadding - 24))
            }
            .padding([.horizontal, .bottom])
        }
        .ignoresSafeArea()
        .introspectScrollView(customize: { scrollView in
            scrollView.verticalScrollIndicatorInsets = .init(
                top: 0, left: 0, bottom: innerBottomPadding, right: 0
            )
        })
        .redacted(reason: videos.isEmpty ? .placeholder : [])
        .onAppear {
            AppContext.shared.requestVideoData { videos in
                self.videos = videos.map { VideoModel(video: $0) }
            }
        }
    }
    
}

// MARK: - VideoModel

fileprivate let videoPlaceholder: Video = Video(
    title: .init(count: 8),
    coverURL: .init(),
    publishedTime: Date(),
    av: .init(count: 11),
    bv: .init(count: 12),
    description: .init(count: 20),
    duration: .init(),
    status: .init(
        views: .init(count: 6),
        danmaku: .init(count: 4),
        replies: .init(count: 6),
        likes: .init(count: 5),
        coins: .init(count: 5),
        favorites: .init(count: 3),
        shares: .init(count: 3)
    )
)

fileprivate struct VideoModel: Identifiable {
    
    var id: String { video.bv }
    var video: Video
    
    static let placeholder: [VideoModel] = {
        var videoModels: [VideoModel] = []
        for _ in 0..<10 {
            videoModels.append(VideoModel(video: videoPlaceholder))
        }
        return videoModels
    }()
    
}

// MARK: - VideoCard

fileprivate struct VideoCard: View {
    
    var video: Video
    
    private let imageSize: CGSize = .init(width: 120, height: 75)
    private let cornerRadius: CGFloat = 8
    
    var body: some View {
        HStack {
            ZStack {
                WebImage(url: URL(string: video.coverURL))
                    .placeholder {
                        Image(uiImage: UIImage())
                            .resizable()
                            .redacted(reason: .placeholder)
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .unredacted()
                VStack(spacing: 0) {
                    Spacer()
                    HStack(spacing: 0) {
                        Spacer()
                        Text(formatDuration(video.duration))
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.black.opacity(0.45))
                            .cornerRadius(cornerRadius, corners: .topLeft)
                    }
                }
                .frame(width: imageSize.width, height: imageSize.height)
            }
            .frame(width: imageSize.width, height: imageSize.height)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(video.title)
                    .font(.system(size: 14))
                Text(formatPublishedTime(video.publishedTime))
                    .font(.system(size: 12))
                    .foregroundColor(.init(.secondaryLabel))
            }
            Spacer()
        }
    }
    
    private func formatPublishedTime(_ time: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: time)
    }
    
    private func formatDuration(_ duration: Int) -> String {
        let seconds: Int = duration % 60
        let minutes: Int = duration / 60 % 24
        let hours: Int = duration / (60 * 60)
        if hours == 0 {
            return String(format: "%02d:%02d", minutes, seconds)
        } else {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }
    
}

// MARK: - Preview

struct VideoListView_Previews: PreviewProvider {
    static var previews: some View {
        VideoListView()
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
