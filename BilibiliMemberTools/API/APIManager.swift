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
        
        static let sms = httpPrefix + Host.passport.rawValue + "/web/sms/general/v2/send"
        
        static let loginSMS = httpPrefix + Host.passport.rawValue + "/web/login/rapid"
        
        static let info = httpPrefix + Host.api.rawValue + "/x/member/web/account"
        
    }
    
    private var _countryCode: Int?
    
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
        DispatchQueue.global().async {
            // Send SMS code.
            let params = [
                "tel": telephone,
                "cid": self.countryCode()?.description ?? .init(),
                "type": "21",
                "captchaType": "6",
                "key": captchaCode.key,
                "challenge": captchaCode.challenge,
                "validate": captchaCode.validate,
                "seccode": captchaCode.seccode
            ]
            AF.request(InterfaceURL.sms, method: .post, parameters: params).responseJSON { response in
                guard let result = response.value as? [String : Any] else { return }
                if let code = result["code"] as? Int, code == 0 {
                    print("The SMS code request was successful.")
                } else {
                    print("Failed to request SMS code.(\(result["message"] as? String ?? "Unknow reason"))")
                }
            }
        }
    }
    
    func login(telephone: String, smsCode: String, completion: ((String?) -> Void)? = nil) {
        let params = [
            "cid": self.countryCode()?.description ?? .init(),
            "tel": telephone,
            "smsCode": smsCode
        ]
        AF.request(InterfaceURL.loginSMS, method: .post, parameters: params).responseJSON { response in
            guard let result = response.value as? [String : Any] else { return }
            if let code = result["code"] as? Int, code == 0 {
                print("Login successful.")
                completion?(nil)
            } else {
                let errorDescription = "\(result["message"] as? String ?? "Unknow reason")"
                print("Login failed.(\(errorDescription))")
                completion?(errorDescription)
            }
        }
    }
    
    func info() -> (errorDescription: String?, info: Account.Info?) {
        let semaphore = DispatchSemaphore()
        let responseQueue = DispatchQueue.global(qos: .utility)
        
        var result: (errorDescription: String?, info: Account.Info?) = (nil, nil)
        AF.request(InterfaceURL.info).responseJSON(queue: responseQueue) { response in
            let errorHandler = {
                result.errorDescription = "Unexcepted response."
                semaphore.signal()
            }
            
            guard let value = response.value as? [String : Any] else {
                errorHandler()
                return
            }
            guard let message = value["message"] as? String else {
                errorHandler()
                return
            }
            result.errorDescription = message
            
            guard let data = value["data"] as? [String : Any] else {
                errorHandler()
                return
            }
            let birthday = Account.Info.format(string: data["birthday"] as? String) ?? Date()
            let uid = (data["mid"] as? Int)?.description ?? .init()
            let sign = data["sign"] as? String ?? .init()
            let username = data["uname"] as? String ?? .init()
            let userID = data["userid"] as? String ?? .init()
            let rank = data["rank"] as? String ?? .init()
            let info = Account.Info(birthday: birthday, uid: uid, signature: sign, username: username, userID: userID, rank: rank)
            result.info = info
            semaphore.signal()
        }
        semaphore.wait()
        return result
    }
    
    // MARK: - Private Methods
    
    private func countryCode() -> Int? {
        if let code = _countryCode {
            return code
        }
        let semaphore = DispatchSemaphore()
        let handlerQueue = DispatchQueue.global(qos: .utility)
        
        // Get country code of China.
        AF.request(InterfaceURL.countryList).responseJSON(queue: handlerQueue) { response in
            guard let list = (response.value as? [String : Any])?["data"] as? [String : [[String : Any]]] else {
                semaphore.signal()
                return
            }
            // Filter out the list of common country information.
            guard let countries = list["common"] else {
                semaphore.signal()
                return
            }
            
            for country in countries {
                if let id = country["country_id"] as? String, id == "86" {
                    self._countryCode = country["id"] as? Int
                }
            }
            semaphore.signal()
        }
        semaphore.wait()
        return _countryCode
    }
    
}
