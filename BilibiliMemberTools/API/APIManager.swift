//
//  Created by ktiays on 2021/5/18.
//  Copyright (c) 2021 ktiays. All rights reserved.
//

import Foundation
import Alamofire

final class APIManager {
    
    static let shared = APIManager()
    
    fileprivate let appkey = "bca7e84c2d947ac6"
    fileprivate let salt = "60698ba2f68e01ce44738920a0ffe768"
    
    fileprivate enum InterfaceURL {
        
        static let httpPrefix = "https://"
        
        fileprivate enum Host : String {
            case api = "api.bilibili.com"
            case passport = "passport.bilibili.com"
        }
        
        static let captcha = httpPrefix + Host.passport.rawValue + "/web/captcha/combine"
        
        static let countryList = httpPrefix + Host.passport.rawValue + "/web/generic/country/list"
        
    }
    
    // MARK: - Public Methods
    
    func captcha() -> (challenge: String, gt: String, key: String) {
        let semaphore = DispatchSemaphore()
        
        var captchaArgs: (String, String, String) = (.init(), .init(), .init())
        let responseQueue = DispatchQueue.global(qos: .utility)
        AF.request(InterfaceURL.captcha, parameters: ["plat": 6]).responseJSON(queue: responseQueue) { response in
            guard let result = response.value as? [String : Any] else {
                semaphore.signal()
                return
            }
            guard let args = (result["data"] as? [String : Any])?["result"] as? [String : Any] else {
                semaphore.signal()
                return
            }
            captchaArgs.0 = args["challenge"] as? String ?? .init()
            captchaArgs.1 = args["gt"] as? String ?? .init()
            captchaArgs.2 = args["key"] as? String ?? .init()
            semaphore.signal()
        }
        semaphore.wait()
        
        return captchaArgs
    }
    
    func sms(telephone: String, captchaCode: (key: String, challenge: String, validate: String, seccode: String)) {
        // Get country code of China.
        let semaphore = DispatchSemaphore()
        let responseQueue = DispatchQueue.global(qos: .utility)
        AF.request(InterfaceURL.countryList).responseJSON(queue: responseQueue) { response in
            guard let list = (response.value as? [String : Any])?["data"] as? [String : [[String : Any]]] else {
                semaphore.signal()
                return
            }
            // Filter out the list of country information.
            guard let countries = list["common"] else {
                semaphore.signal()
                return
            }
            for country in countries {
                print(country)
            }
        }
        semaphore.wait()
    }
    
    func login(telephone: String, smsCode: String) {
        
        let params = [
            "access_key": nil,
            "appkey": appkey,
            "ts": Date().timestamp.description
        ]
        
        let args = captcha()
        print(args)
        
        // Load Geetest verify page.
        let geetestHTML = Bundle.main.path(forResource: "Geetest/geetest", ofType: "html")
        print(geetestHTML)
        
    }
    
    // MARK: - Private Methods
    
    private func signature(of params: [String : String?]) -> String {
        ""
    }
    
}
