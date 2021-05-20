//
//  Created by ktiays on 2021/5/20.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import SwiftUI

// MARK: API

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

let apiList = [
    API(name: "Account Information", invokeHandler: {
        guard let info = APIManager.shared.info().info else { return AnyView(EmptyView()) }
        
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
    }),
    
    API(name: "UP Status", invokeHandler: {
        guard let status = APIManager.shared.upStatus().upStatus else { return AnyView(EmptyView()) }
        
        struct Card: View {
            
            var title: String
            var data: String
            var delta: Int = 0
            
            var body: some View {
                VStack {
                    Text(title)
                        .font(.system(size: 12))
                        .foregroundColor(.init(.secondaryLabel))
                    Text(data)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.init(.systemBlue))
                        .padding(.vertical, 1)
                    if (delta != 0) {
                        HStack {
                            if (delta > 0) {
                                Image(systemName: "arrowtriangle.up.fill")
                                    .foregroundColor(Color(.systemRed))
                                Text(delta.description)
                                    .bold()
                                    .foregroundColor(Color(.systemRed))
                            } else {
                                Image(systemName: "arrowtriangle.down.fill")
                                    .foregroundColor(Color(.systemGreen))
                                Text(abs(delta).description)
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
            VStack {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ], spacing: 20, content: {
                    Card(title: "Video View", data: status.total.videoViews.description, delta: status.delta.videoViews)
                    Card(title: "Likes", data: status.total.likes.description, delta: status.delta.likes)
                    Card(title: "Replies", data: status.total.replies.description, delta: status.delta.replies)
                    Card(title: "Coins", data: status.total.coins.description, delta: status.delta.coins)
                    Card(title: "Favorites", data: status.total.favorites.description, delta: status.delta.favorites)
                    Card(title: "Danmakus", data: status.total.danmakus.description, delta: status.delta.danmakus)
                    Card(title: "Shares", data: status.total.shares.description, delta: status.delta.shares)
                    Card(title: "Batteries", data: status.total.batteries.description, delta: status.delta.batteries)
                })
            }
            .padding(.horizontal)
        )
    })
]
