//
//  Created by ktiays on 2021/5/22.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import Foundation

final class AppContext {
    
    static let shared = AppContext()
    
    var account: Account = Account()
    
    // MARK: - Account Information
    
    func requestAccountInformationIfNeeded(completion handler: @escaping (String?) -> Void) {
        DispatchQueue.global().async {
            if self.account.memberInfo == nil {
                let memberInfo = APIManager.shared.memberInfo()
                
                guard let info: Account.MemberInfo? = {
                    do {
                        return try memberInfo.get()
                    } catch {
                        guard let error = error as? APIManager.APIError else { return nil }
                        if error.code == ErrorCode.notAuthorized.rawValue {
                            DispatchQueue.main.async {
                                showLoginView()
                            }
                        }
                        return nil
                    }
                }() else { return }
                self.account.memberInfo = info
            }
            
            guard let memberInfo = self.account.memberInfo else { return }
            let userInfo = APIManager.shared.userInfo(uid: memberInfo.uid)
            guard let info = userInfo.userInfo else {
                handler(userInfo.errorDescription)
                return
            }
            self.account.userInfo = info
            
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
            self.account.upStatus = upStatus            
            handler(nil)
        }
    }
    
    func requestVideoData(completion handler: @escaping ([Video]) -> Void) {
        DispatchQueue.global().async {
            let videoResult = APIManager.shared.videos(for: [.published, .rejected, .reviewing])
            guard let videos = try? videoResult.get() else {
                handler([])
                return
            }
            handler(videos)
        }
    }
    
}
