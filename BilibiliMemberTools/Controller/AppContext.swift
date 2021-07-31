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

func withAsync(_ handler: @escaping () -> Void) {
    DispatchQueue.global().async {
        handler()
    }
}

final class AppContext: ObservableObject {
    
    static let shared = AppContext()
    
    @Published var account: Account = .init()
    @Published var messageFeed: MessageFeed = .init()
    
    func reset() {
        account = .init()
        messageFeed = .init()
        UserDataManager.default.removeAllCaches()
        UserDataManager.cacher.removeAll()
    }
    
    // MARK: - Account Information
    
    func requestAccountInformationIfNeeded() async {
        
        var memberInfo = account.memberInfo
            
        if memberInfo == nil {
            do {
                memberInfo = try await APIManager.shared.memberInfo()
            } catch {
                guard let error = error as? APIManager.APIError else {
                    assertionFailure("The type of error cannot be recognized")
                    return
                }
                // If user is not logged in,
                // the login view will pop up.
                if error.code == ErrorCode.notAuthorized.rawValue {
                    LoginAssistant.login()
                } else {
                    print("An unknown error occurred while fetching data.")
                }
                return
            }
        }
        
        guard let memberInfo = memberInfo else { return }
        account.memberInfo = memberInfo
        do {
            account.userInfo = try await APIManager.shared.userInfo(uid: memberInfo.uid)
        } catch { print(error) }
    }
    
    // MARK: - UP Status
    
    func requestUpStatus(completion handler: @escaping (String?) -> Void) {
        withAsync {
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
    
    func requestUnreadQuantity(completion handler: @escaping (Int) -> Void) {
        withAsync {
            let quantity = APIManager.shared.numberOfUnread()
            withMainQueue {
                handler(quantity.0 + quantity.1 + quantity.2 + quantity.3 + quantity.4)
            }
        }
    }

    func requestReplyFeed(completion handler: @escaping ([Reply]) -> Void) {
        withAsync {
            guard let replies = try? APIManager.shared.replyFeed().get() else {
                handler([])
                return
            }
            withMainQueue {
                self.messageFeed.replies = replies
                handler(replies)
            }
        }
    }
    
}
