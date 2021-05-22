//
//  Created by ktiays on 2021/5/22.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import SwiftUI
import SDWebImageSwiftUI

struct DashboardView: View {
    
    @State private var userInfo: Account.UserInfo?
    
    var body: some View {
        VStack {
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
                        .padding(.vertical, 2)
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
                    .cornerRadius(20)
                    .ignoresSafeArea()
            )
            
            Spacer()
        }
        .redacted(reason: userInfo == nil ? .placeholder : [])
        .onAppear {
            let context = AppContext.shared
            context.requestAccountInformationIfNeeded { _ in
                self.userInfo = context.userInfo
            }
        }
        .statusBar(style: .lightContent)
    }
    
}

// MARK: - Preview

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
