//
//  Created by ktiays on 2021/5/22.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import SwiftUI

struct DashboardView: View {
    
    @State private var memberInfo: Account.MemberInfo?
    @State private var userInfo: Account.UserInfo?
    
    var body: some View {
        VStack {
            HStack {
                WebImageView(url: userInfo?.avatarURL ?? .init())
                    .frame(width: 50, height: 50)
            }
        }
        .onAppear {
            DispatchQueue.global().async {
                memberInfo = APIManager.shared.memberInfo().info
                guard let uid = memberInfo?.uid else { return }
                userInfo = APIManager.shared.userInfo(uid: uid).userInfo
            }
        }
    }
    
}

// MARK: - Preview

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
