//
//  Created by ktiays on 2021/7/31.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import SwiftUI
import Kingfisher
import Introspect

struct SettingsView: View {
    
    @State private var viewController: UIViewController?
    
    @StateObject private var appContext = AppContext.shared
    private var userInfo: Account.UserInfo? {
        appContext.account.userInfo
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                Spacer(minLength: 44)
                KFImage(URL(string: userInfo?.avatarURL ?? .init()))
                    .placeholder {
                        Image(uiImage: UIImage())
                            .resizable()
                            .foregroundColor(.white)
                            .redacted(reason: .placeholder)
                    }
                    .resizable()
                    .aspectRatio(.init(width: 1, height: 1), contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .unredacted()
                Text(userInfo?.username ?? .init())
                    .bold()
                    .font(.system(size: 18))
                
                Spacer(minLength: 36)
                LazyVStack(spacing: 24) {
                    _ButtonCell {
                        HStack {
                            Text("退出登录")
                                .foregroundColor(.init(.systemPink))
                            Spacer()
                        }
                    } action: {
                        LoginAssistant.signOut()
                        viewController?.dismiss(animated: true) {
                            LoginAssistant.login()
                        }
                    }
                    .backgroundColor(Color(.systemPink).opacity(0.1))
                    
                    _ButtonCell {
                        HStack {
                            Text("关于")
                                .foregroundColor(Color(uiColor: .label))
                            Spacer()
                        }
                    } action: {
                        
                    }
                }
                .padding(.horizontal, 12)
            }
        }
//        .background(Color(uiColor: .systemGroupedBackground))
        .introspectViewController { viewController in
            self.viewController = viewController
        }
    }
    
}

// MARK: - _ButtonCell

fileprivate struct _ButtonCell<Content>: View where Content: View {
    
    private var content: Content
    private var action: () -> Void
    private var backgroundColor: Color = .init(uiColor: .secondarySystemBackground).opacity(0.5)
    
    init(@ViewBuilder _ content: () -> Content, action: @escaping () -> Void) {
        self.content = content()
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            content
                .frame(height: 44)
                .padding(.horizontal, 16)
                .background(backgroundColor)
        }
        .cornerRadius(10, style: .continuous)
    }
    
    func backgroundColor(_ color: Color) -> some View {
        var view = self
        view.backgroundColor = color
        return view
    }
    
}

// MARK: - Previews

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
