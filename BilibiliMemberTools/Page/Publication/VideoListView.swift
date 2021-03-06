//
//  Created by ktiays on 2021/5/26.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import SwiftUI
import Kingfisher
import Introspect

// MARK: Video List View

struct VideoListView: View {
    
    @StateObject private var cacher = UserDataManager.cacher
    private var videos: [VideoModel] { cacher.videos.map { VideoModel(video: $0) } }
    
    @Environment(\.innerBottomPadding) private var innerBottomPadding
    
    var body: some View {
        if videos.isEmpty {
            List {
                ForEach(VideoModel.placeholder) { video in
                    VideoCard(video: video.video)
                        .padding(.bottom, 20)
                }
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .ignoresSafeArea()
            .redacted(reason: cacher.videos.isEmpty ? .placeholder : [])
            .onAppear {
                if !videos.isEmpty { return }
                UserDataManager.default.requestVideos()
            }
        } else {
            List {
                ForEach(videos) { video in
                    VideoCard(video: video.video)
                        .padding(.bottom, 20)
                }
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .ignoresSafeArea()
            .introspectTableView { tableView in
                tableView.automaticallyAdjustsScrollIndicatorInsets = false
                tableView.verticalScrollIndicatorInsets = .init(
                    top: 0, left: 0, bottom: innerBottomPadding, right: 0
                )
                tableView.contentInset = .init(top: 8, left: 0, bottom: innerBottomPadding - 36, right: 0)
            }
        }
    }
    
}

// MARK: - Video Model

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
        danmakus: .init(count: 4),
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
            var placeholder = videoPlaceholder
            placeholder.bv = UUID().uuidString[..<placeholder.bv.count]
            videoModels.append(VideoModel(video: placeholder))
        }
        return videoModels
    }()
    
}

// MARK: - Video Card View

fileprivate struct VideoCard: View {
    
    var video: Video
    
    private let imageSize: CGSize = .init(width: 120, height: 75)
    private let cornerRadius: CGFloat = 8
    
    var body: some View {
        VStack {
            HStack(spacing: 12) {
                KFImage(URL(string: video.coverURL))
                    .placeholder {
                        Image(uiImage: UIImage())
                            .resizable()
                            .redacted(reason: .placeholder)
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: imageSize.width, height: imageSize.height)
                    .unredacted()
                    .overlay {
                        Text(formatDuration(video.duration))
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.black.opacity(0.45))
                            .cornerRadius(cornerRadius, corners: .topLeft)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(video.title)
                        .foregroundColor(.init(.label))
                        .font(.system(size: 13))
                        .lineSpacing(4)
                    Text(video.publishedTime.formattedString)
                        .font(.system(size: 12))
                        .foregroundColor(.init(.label).opacity(0.7))
                    HStack(spacing: 2) {
                        Image(systemName: "play.rectangle.fill")
                        Text(video.status.views.integerDescription)
                    }
                    .font(.system(size: 12))
                    .foregroundColor(.init(.secondaryLabel))
                }
                Spacer()
            }
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ]) {
                InteractiveTag(image: Image(systemName: "text.bubble.fill"),
                               value: video.status.replies.integerDescription)
                InteractiveTag(image: Image(systemName: "list.bullet.indent"),
                               value: video.status.danmakus.integerDescription)
                InteractiveTag(image:Image(systemName: "suit.heart.fill"),
                               value: video.status.likes.integerDescription)
                InteractiveTag(image: Image(systemName: "dollarsign.circle.fill"),
                               value: video.status.coins.integerDescription)
                InteractiveTag(image: Image(systemName: "star.fill"),
                               value: video.status.favorites.integerDescription)
                InteractiveTag(image: Image(systemName: "arrowshape.turn.up.right.fill"),
                               value: video.status.shares.integerDescription)
            }
        }
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
        ScrollView {
            VideoListView()
        }
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
                danmakus: 234,
                replies: 45324,
                likes: 8345,
                coins: 2347,
                favorites: 36,
                shares: 567)
        ))
    }
}
