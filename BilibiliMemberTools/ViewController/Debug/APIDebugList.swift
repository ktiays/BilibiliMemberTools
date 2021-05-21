//
//  Created by ktiays on 2021/5/20.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import SwiftUI

// MARK: API Structure

struct API: Identifiable {
    
    var id: String = UUID().uuidString
    var name: String
    var invokeHandler: () -> AnyView
    
    func call(completionHandler: @escaping (AnyView) -> Void) {
        DispatchQueue.global().async {
            completionHandler(invokeHandler())
        }
    }
    
}

// MARK: - TextView Structure

struct TextView: View {
    
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            Text(title)
                .bold()
            Spacer()
            Text(value)
        }
        .padding(.bottom)
    }
}

let apiList = [
    // MARK: - Account Information
    API(name: "Account Information") {
        guard let info = APIManager.shared.memberInfo().info else { return AnyView(EmptyView()) }
        
        return AnyView(
            VStack {
                TextView(title: "Birthday", value: info.birthday.description)
                TextView(title: "UID", value: info.uid)
                TextView(title: "Username", value: info.username)
                TextView(title: "Signature", value: info.signature)
                TextView(title: "Rank", value: info.rank)
                TextView(title: "User ID", value: info.userID)
            }
            .padding(.horizontal)
        )
    },
    
    // MARK: - UP Status
    API(name: "UP Status") {
        guard let status = APIManager.shared.upStatus().upStatus else { return AnyView(EmptyView()) }
        
        struct Card: View {
            
            var title: String
            var data: Int = 0
            var delta: Int = 0
            
            var body: some View {
                VStack {
                    Text(title)
                        .font(.system(size: 12))
                        .foregroundColor(.init(.secondaryLabel))
                    Text("\(data)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.init(.systemBlue))
                        .padding(.vertical, 1)
                    if (delta != 0) {
                        HStack {
                            if (delta > 0) {
                                Image(systemName: "arrowtriangle.up.fill")
                                    .foregroundColor(Color(.systemRed))
                                Text("\(delta)")
                                    .bold()
                                    .foregroundColor(Color(.systemRed))
                            } else {
                                Image(systemName: "arrowtriangle.down.fill")
                                    .foregroundColor(Color(.systemGreen))
                                Text("\(abs(delta))")
                                    .bold()
                                    .foregroundColor(Color(.systemGreen))
                            }
                        }
                        .font(.system(size: 12))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, 20)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
        
        return AnyView(
            VStack(spacing: 10) {
                Card(title: "Follower", data: status.total.followers, delta: status.delta.followers)
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ], spacing: 10, content: {
                    Card(title: "Video View", data: status.total.videoViews, delta: status.delta.videoViews)
                    Card(title: "Likes", data: status.total.likes, delta: status.delta.likes)
                    Card(title: "Replies", data: status.total.replies, delta: status.delta.replies)
                    Card(title: "Coins", data: status.total.coins, delta: status.delta.coins)
                    Card(title: "Favorites", data: status.total.favorites, delta: status.delta.favorites)
                    Card(title: "Danmakus", data: status.total.danmakus, delta: status.delta.danmakus)
                    Card(title: "Shares", data: status.total.shares, delta: status.delta.shares)
                    Card(title: "Batteries", data: status.total.batteries, delta: status.delta.batteries)
                })
            }
            .padding(.horizontal)
        )
    },
    
    // MARK: - Number of Unread Message
    API(name: "Number Of Unread Message") {
        let unread = APIManager.shared.numberOfUnread()
        return AnyView(
            VStack {
                TextView(title: "Total", value: (unread.0 + unread.1 + unread.2 + unread.3 + unread.4).integerDescription)
                TextView(title: "@Me", value: unread.at.integerDescription)
                TextView(title: "Likes", value: unread.like.integerDescription)
                TextView(title: "Replies", value: unread.reply.integerDescription)
                TextView(title: "System Message", value: unread.systemMessage.integerDescription)
                TextView(title: "UP Message Box", value: unread.up.integerDescription)
            }
            .padding(.horizontal)
        )
    },
    
    // MARK: - User Information
    API(name: "User Information") {
        guard let userInfo = APIManager.shared.userInfo(uid: "13105369").userInfo else { return AnyView(EmptyView()) }
                
        return AnyView(
            HStack {
                WebImageView(url: userInfo.avatarURL)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                VStack(alignment: .leading) {
                    Text(userInfo.username)
                    Text("Big VIP")
                        .padding(.vertical, 1)
                    Text("Coins: \(userInfo.coins)")
                }
            }
        )
    },
]
