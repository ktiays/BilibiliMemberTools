//
//  Created by ktiays on 2021/5/22.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import Foundation

fileprivate func withMainQueue(_ handler: @escaping () -> Void) {
    DispatchQueue.main.async {
        handler()
    }
}

final class AppContext: ObservableObject {
    
    static let shared = AppContext()
    
    @Published var account: Account = Account()
    
    // MARK: - Account Information
    
    func requestAccountInformationIfNeeded(completion handler: @escaping (String?) -> Void) {
        DispatchQueue.global().async { [self] in
            var memberInfo = account.memberInfo
            
            if memberInfo == nil {
                let sharedMemberInfo = APIManager.shared.memberInfo()
                
                guard let info: Account.MemberInfo? = {
                    do {
                        return try sharedMemberInfo.get()
                    } catch {
                        guard let error = error as? APIManager.APIError else {
                            withMainQueue { handler(nil) }
                            return nil
                        }
                        // If user is not logged in,
                        // the login view will pop up.
                        if error.code == ErrorCode.notAuthorized.rawValue {
                            withMainQueue {
                                LoginAssistant.login()
                            }
                        }
                        withMainQueue { handler(nil) }
                        return nil
                    }
                }() else {
                    withMainQueue { handler(nil) }
                    return
                }
                memberInfo = info
            }
            
            guard let memberInfo = memberInfo else {
                withMainQueue { handler(nil) }
                return
            }
            let sharedUserInfo = APIManager.shared.userInfo(uid: memberInfo.uid)
            guard let info = sharedUserInfo.userInfo else {
                withMainQueue { handler(sharedUserInfo.errorDescription) }
                return
            }
            
            // The request is complete,
            // throw the data back to the main thread to refresh.
            withMainQueue { [self] in
                account.memberInfo = memberInfo
                account.userInfo = info
                handler("Request Completed.")
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
        self.account.videos = []
        DispatchQueue.global().async {
            APIManager.shared.videos(for: [.published, .rejected, .reviewing]) { result in
                guard let videos = try? result.get() else {
                    handler([])
                    return
                }
                withMainQueue {
                    self.account.videos.append(contentsOf: videos)
                    handler(videos)
                }
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
