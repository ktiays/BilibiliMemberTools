//
//  Created by ktiays on 2021/5/22.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import SwiftUI
import SDWebImageSwiftUI
import CyanKit

fileprivate func cardBackgroundColor(for colorScheme: ColorScheme) -> Color {
    .accentColor.opacity(colorScheme == .dark ? 0.08 : 0.04)
}

struct DashboardView: View {
    
    @State private var userInfo: Account.UserInfo?
    @State private var upStatus: Account.UpStatus?
    
    @State private var selection: Int = 0
    
    @Environment(\.colorScheme) private var colorScheme
    
    fileprivate struct SegmentItem: SegmentedControlItem {
        
        var id: Int
        var text: String
        
    }
    
    fileprivate struct SectionItem: Identifiable {
        
        var id: String { title }
        var title: String
        var data: (Int?, Int?)
        
    }
    
    fileprivate struct DataSectionView: View {
        
        var description: String = .init()
        var items: [SectionItem]
        
        @Environment(\.colorScheme) private var colorScheme
        
        var columns: [GridItem] {
            var columns = [GridItem]()
            for _ in 0..<(items.count > 3 ? 3 : items.count) {
                columns.append(GridItem(.flexible(), spacing: 10))
            }
            return columns
        }
        
        var body: some View {
            VStack(spacing: 0) {
                if description.count > 0 {
                    HStack {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.init(.secondaryLabel))
                            .bold()
                        Spacer()
                    }
                    .padding(.vertical)
                }
                
                if items.count > 0 {
                    LazyVGrid(columns: columns, spacing: 24, content: {
                        ForEach(items) { item in
                            DataView(title: item.title,
                                     value: item.data.0 ?? .init(count: 5),
                                     delta: item.data.1 ?? .init(count: 3),
                                     sizeOfValueData: 18)
                        }
                    })
                    .padding(.vertical)
                    .padding(.horizontal, 2)
                    .background(cardBackgroundColor(for: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
        }
        
    }
    
    fileprivate struct DataView: View {
        
        var title: String
        var value: Int
        var delta: Int
        var sizeOfValueData: CGFloat = 24
        
        var body: some View {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(.init(.secondaryLabel))
                Text(value.integerDescription)
                    .font(.system(size: sizeOfValueData, weight: .bold))
                    .foregroundColor(.accentColor)
                if (delta != 0) {
                    HStack(spacing: 3) {
                        if (delta > 0) {
                            Image(systemName: "arrowtriangle.up.fill")
                                .foregroundColor(Color(.systemRed))
                            Text(delta.integerDescription)
                                .bold()
                                .foregroundColor(Color(.systemRed))
                        } else {
                            Image(systemName: "arrowtriangle.down.fill")
                                .foregroundColor(Color(.systemGreen))
                            Text(abs(delta).integerDescription)
                                .bold()
                                .foregroundColor(Color(.systemGreen))
                        }
                    }
                    .font(.system(size: 12))
                }
            }
        }
        
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                WebImage(url: URL(string: userInfo?.avatarURL ?? .init()))
                    .placeholder {
                        Image(uiImage: UIImage())
                            .resizable()
                            .foregroundColor(.white)
                            .redacted(reason: .placeholder)
                    }
                    .resizable()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .unredacted()
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(userInfo?.username ?? .init(count: 5))
                        .foregroundColor(.white)
                        .bold()
                    Text(userInfo?.vip.description ?? .init(count: 5))
                        .font(.system(size: 12))
                        .padding(.horizontal, userInfo == nil ? 0 : 4)
                        .padding(.vertical, 3)
                        .foregroundColor(userInfo == nil ? .white : .accentColor)
                        .background((userInfo == nil ? Color.clear : Color.white).cornerRadius(4))
                    Text("硬币：" + (userInfo?.coins.doubleDescription(maximumFractionDigits: 1) ?? .init(count: 7)))
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(userInfo == nil ? 1 : 0.7))
                }
                .padding(.horizontal, 12)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 36)
            .background(
                Color.accentColor
                    .cornerRadius(12)
                    .ignoresSafeArea()
            )
            .redacted(reason: userInfo == nil ? .placeholder : [])
            
            ScrollView {
                VStack {
                    HStack {
                        DataView(title: "粉丝量",
                                 value: upStatus?.total.followers ?? .init(count: 5),
                                 delta: upStatus?.delta.followers ?? .init(count: 3))
                            .padding(.vertical)
                    }
                    
                    HStack {
                        SegmentedControl(selection: $selection, content: [
                            SegmentItem(id: 0, text: "视频数据"),
                            SegmentItem(id: 1, text: "专栏数据"),
                        ])
                        .selectedBackgroundColor(.accentColor)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    if selection == 0 {
                        VStack(spacing: 4) {
                            HStack {
                                Spacer()
                                DataView(title: "总播放量",
                                         value: upStatus?.total.videoViews ?? .init(count: 5),
                                         delta: upStatus?.delta.videoViews ?? .init(count: 3))
                                Spacer()
                            }
                            .padding(.vertical)
                            .background(cardBackgroundColor(for: colorScheme))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            
                            DataSectionView(description: "三连数据概览", items: {
                                var items = [SectionItem]()
                                items.append(SectionItem(title: "点赞", data: (upStatus?.total.likes, upStatus?.delta.likes)))
                                items.append(SectionItem(title: "评论", data: (upStatus?.total.replies, upStatus?.delta.replies)))
                                items.append(SectionItem(title: "收藏", data: (upStatus?.total.favorites, upStatus?.delta.favorites)))
                                return items
                            }())
                            
                            DataSectionView(description: "其他视频数据", items: {
                                var items = [SectionItem]()
                                items.append(SectionItem(title: "弹幕量", data: (upStatus?.total.danmakus, upStatus?.delta.danmakus)))
                                items.append(SectionItem(title: "分享量", data: (upStatus?.total.shares, upStatus?.delta.shares)))
                                return items
                            }())
                        }
                        .padding()
                    }
                    
                }
            }
            .redacted(reason: upStatus == nil ? .placeholder : [])
        }
        .onAppear {
            let context = AppContext.shared
            context.requestAccountInformationIfNeeded { _ in
                self.userInfo = context.userInfo
                context.requestUpStatusIfNeeded { _ in
                    self.upStatus = context.upStatus
                }
            }
        }
        .statusBar(style: .lightContent)
    }
    
}

// MARK: - Preview

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
        DashboardView.DataView(title: "Data", value: 30123, delta: -6)
        DashboardView.DataSectionView(description: "这是一个 Section", items: [
            DashboardView.SectionItem(title: "点赞", data: (43541351, 1320)),
            DashboardView.SectionItem(title: "分享", data: (421, 21)),
            DashboardView.SectionItem(title: "分享2", data: (421, 21)),
            DashboardView.SectionItem(title: "分享3", data: (421, 21)),
        ])
        .padding()
    }
}
