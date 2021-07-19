//
//  Created by ktiays on 2021/7/19.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import Foundation

struct AuthStatus {
    
    enum AuthError: Int, Error {
        case unknown = 0        // Unknown reason for failure.
        case incorrectKey = -1  // OAuth key is not correct.
        case expiredKey = -2    // OAuth key is expired.
        case notScanned = -4    // The QR code has not been scanned yet.
        case unauthorized = -5  // The QR code has been scanned, but the authorization has not been confirmed.
    }
    
    // Description of failure reason.
    var message: String?
    var status: Result<String, AuthError>
    
    init(message: String, data: Int) {
        self.message = message
        status = .failure(AuthError(rawValue: data) ?? .unknown)
    }

    init(data: String) {
        status = .success(data)
    }
    
}
