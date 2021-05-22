//
//  Created by ktiays on 2021/5/22.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import Foundation

final class AppContext {
    
    static let shared = AppContext()
    
    var memberInfo: Account.MemberInfo?
    var userInfo: Account.UserInfo?
    var upStatus: Account.UpStatus?
    
    // MARK: - Account Information
    
    private func hasAccountInformation() -> Bool {
        memberInfo != nil && userInfo != nil
    }
    
    func requestAccountInformationIfNeeded(completion handler: @escaping (String?) -> Void) {
        if hasAccountInformation() {
            handler(nil)
            return
        }
        
        DispatchQueue.global().async {
            let memberInfo = APIManager.shared.memberInfo()
            guard let info = memberInfo.info else {
                handler(memberInfo.errorDescription)
                return
            }
            self.memberInfo = info
            
            let userInfo = APIManager.shared.userInfo(uid: info.uid)
            guard let info = userInfo.userInfo else {
                handler(userInfo.errorDescription)
                return
            }
            self.userInfo = info
            
            handler(nil)
        }
    }
    
    // MARK: - UP Status
    
    func requestUpStatusIfNeeded(completion handler: @escaping (String?) -> Void) {
        if upStatus != nil {
            handler(nil)
            return
        }
        
        DispatchQueue.global().async {
            let upStatus = APIManager.shared.upStatus()
            guard let upStatus = upStatus.upStatus else {
                handler(upStatus.errorDescription)
                return
            }
            self.upStatus = upStatus            
            handler(nil)
        }
    }
    
}
