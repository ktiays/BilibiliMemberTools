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
    
    func requestAccountInformationIfNeeded(completion handler: @escaping (String?) -> Void) {
        DispatchQueue.global().async {
            if self.memberInfo == nil {
                let memberInfo = APIManager.shared.memberInfo()
                guard let info = try? memberInfo.get() else {
    //                handler(memberInfo.errorDescription)
                    return
                }
                self.memberInfo = info
            }
            
            guard let memberInfo = self.memberInfo else { return }
            let userInfo = APIManager.shared.userInfo(uid: memberInfo.uid)
            guard let info = userInfo.userInfo else {
                handler(userInfo.errorDescription)
                return
            }
            self.userInfo = info
            
            handler(nil)
        }
    }
    
    // MARK: - UP Status
    
    func requestUpStatus(completion handler: @escaping (String?) -> Void) {
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
