//
//  Created by ktiays on 2021/5/28.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import SwiftUI
import Introspect
import Kingfisher

// MARK: Interaction View

struct InteractionView: View {
    
    @StateObject private var appContext = AppContext.shared
    
    private var replies: [ReplyItem] { appContext.messageFeed.replies.map { ReplyItem($0) } }
    
    @Environment(\.innerBottomPadding) private var innerBottomPadding;
    
    @EnvironmentObject var badgeValue: BadgeValue
    
    var body: some View {
        VStack {
            List {
                ForEach(replies) { reply in
                    ReplyCard(reply: reply)
                }
                Spacer()
                    .frame(height: innerBottomPadding - 36)
            }
        }
        .ignoresSafeArea()
        .listStyle(.plain)
        .introspectTableView { tableView in
            tableView.automaticallyAdjustsScrollIndicatorInsets = false
            tableView.verticalScrollIndicatorInsets = .init(
                top: 0, left: 0, bottom: innerBottomPadding, right: 0
            )
        }
        .task {
            let overlayInputViewController = OverlayInputViewController()
            overlayInputViewController.modalPresentationStyle = .overFullScreen
            present(overlayInputViewController)
            badgeValue.value = .init()
            if !replies.isEmpty { return }
            appContext.requestReplyFeed { _ in }
        }
    }
    
}

// MARK: - Reply Card

fileprivate struct ReplyItem: Identifiable {
    
    var id: String
    var uid: String
    var username: String
    var avatarURL: String?
    var time: Date
    var content: String
    
    init(_ reply: Reply) {
        self.id = reply.id
        self.uid = reply.user.uid
        self.username = reply.user.username
        self.avatarURL = reply.user.avatarURL
        self.time = reply.time
        self.content = reply.content
    }
    
}

fileprivate struct ReplyCard: View {
    
    var reply: ReplyItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    KFImage(URL(string: reply.avatarURL ?? .init()))
                        .placeholder {
                            Image(uiImage: UIImage())
                                .resizable()
                                .redacted(reason: .placeholder)
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .unredacted()
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(reply.username)
                                .font(.system(size: 13))
                            LoadableView(source: UserDataManager.default.relation(with: reply.uid)) {
                                if $0.state == .friend || $0.state == .followed {
                                    Text("粉丝")
                                        .font(.system(size: 10))
                                        .foregroundColor(.accentColor)
                                        .padding(.vertical, 2)
                                        .padding(.horizontal, 5)
                                        .background(
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke(Color.accentColor, lineWidth: 1)
                                        )
                                        .offset(y: -1)
                                }
                            }
                        }
                        Text(reply.time.stringFrom(format: "yyyy-MM-dd HH:mm"))
                            .font(.system(size: 12))
                            .foregroundColor(Color(.secondaryLabel))
                    }
                }
                Text(reply.content)
                    .font(.system(size: 15))
                    .lineSpacing(4)
            }
            Spacer()
        }
        .padding(.vertical)
    }
    
}

// MARK: - Preview

struct InteractionView_Previews: PreviewProvider {
        
    static var previews: some View {
        PreviewView()
    }
    
    struct PreviewView: View {
        
        @StateObject private var badgeValue = BadgeValue()
        
        var body: some View {
            InteractionView()
                .environmentObject(badgeValue)
            ReplyCard(reply: ReplyItem(Reply(id: UUID().uuidString,
                          user: User(uid: UUID().uuidString,
                                     username: "Username",
                                     avatarURL: ""),
                          content: "Reply Content.",
                          time: Date())))
        }
        
    }
    
}
