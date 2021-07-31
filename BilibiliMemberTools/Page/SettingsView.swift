//
//  Created by ktiays on 2021/7/31.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import SwiftUI
import SDWebImageSwiftUI
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
                WebImage(url: URL(string: userInfo?.avatarURL ?? .init()))
                    .placeholder {
                        Image(uiImage: UIImage())
                            .resizable()
                            .foregroundColor(.white)
                            .redacted(reason: .placeholder)
                    }
                    .resizable()
                    .aspectRatio(.init(width: 1, height: 1), contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .unredacted()
                
                Text(userInfo?.username ?? .init())
                    .bold()
                    .font(.system(size: 22))
                
                Spacer(minLength: 36)
                Button {
                    LoginAssistant.signOut()
                    viewController?.dismiss(animated: true) {
                        LoginAssistant.login()
                    }
                } label: {
                    HStack {
                        Text("退出登录")
                            .foregroundColor(.init(.systemPink))
                        Spacer()
                    }
                    .frame(height: 44)
                    .padding(.horizontal, 16)
                    .background(Color(.systemPink).opacity(0.04))
                    
                }
                .cornerRadius(10, style: .continuous)
                .padding(.horizontal, 12)
            }
        }
        .introspectViewController { viewController in
            self.viewController = viewController
        }
    }
    
}

// MARK: - Previews

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
