//
//  Created by ktiays on 2021/5/22.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import Foundation

func withMainQueue(_ handler: @escaping () -> Void) {
    DispatchQueue.main.async {
        handler()
    }
}

final class AppContext: ObservableObject {
    
    static let shared = AppContext()
    
    @Published var account: Account = Account()
    
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
                        // If user is not logged in,
                        // the login view will pop up.
                        if error.code == ErrorCode.notAuthorized.rawValue {
                            DispatchQueue.main.async {
                                #if !targetEnvironment(simulator)
                                showLoginView()
                                #endif
                            }
                        }
                        return nil
                    }
                }() else { return }
                withMainQueue {
                    self.account.memberInfo = info
                }
            }
            
            guard let memberInfo = self.account.memberInfo else { return }
            let userInfo = APIManager.shared.userInfo(uid: memberInfo.uid)
            guard let info = userInfo.userInfo else {
                withMainQueue {
                    handler(userInfo.errorDescription)
                }
                return
            }
            withMainQueue {
                self.account.userInfo = info
                handler(nil)
            }
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
            withMainQueue {
                self.account.upStatus = upStatus
                handler(nil)
            }
        }
    }
    
    func requestVideoData(completion handler: @escaping ([Video]) -> Void) {
        DispatchQueue.global().async {
            let videoResult = APIManager.shared.videos(for: [.published, .rejected, .reviewing])
            guard let videos = try? videoResult.get() else {
                handler([])
                return
            }
            withMainQueue {
                self.account.videos = videos
                handler(videos)
            }
        }
    }
    
    func requestUnreadQuantity(completion handler: @escaping (Int) -> Void) {
        DispatchQueue.global().async {
            let quantity = APIManager.shared.numberOfUnread()
            DispatchQueue.main.async {
                handler(quantity.0 + quantity.1 + quantity.2 + quantity.3 + quantity.4)
            }
        }
    }
    
}
