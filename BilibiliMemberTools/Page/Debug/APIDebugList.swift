//
//  Created by ktiays on 2021/5/20.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import SwiftUI
import SDWebImageSwiftUI

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
        guard let info = try? APIManager.shared.memberInfo().get() else { return AnyView(EmptyView()) }
        
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
                WebImage(url: URL(string: userInfo.avatarURL))
                    .resizable()
                    .scaledToFit()
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
