//
//  Created by ktiays on 2021/5/18.
//  Copyright (c) 2021 ktiays. All rights reserved.
//

import UIKit
import Alamofire

final class APIManager {
    
    static let shared = APIManager()
    
    fileprivate enum InterfaceURL {
        
        static let httpPrefix = "https://"
        
        fileprivate enum Host : String {
            case api = "api.bilibili.com"
            case passport = "passport.bilibili.com"
            case member = "member.bilibili.com"
        }
        
        static let captcha = httpPrefix + Host.passport.rawValue + "/web/captcha/combine"
        
        static let countryList = httpPrefix + Host.passport.rawValue + "/web/generic/country/list"
        
        static let sms = httpPrefix + Host.passport.rawValue + "/web/sms/general/v2/send"
        
        static let loginSMS = httpPrefix + Host.passport.rawValue + "/web/login/rapid"
        
        fileprivate enum User {
            
            static let info = httpPrefix + Host.api.rawValue + "/x/member/web/account"
            
            static let upVideoStatus = httpPrefix + Host.member.rawValue + "/x/web/index/stat"
            
            static let upArticleStatus = httpPrefix + Host.member.rawValue + "/x/web/data/article"
            
            static let numberOfUnread = httpPrefix + Host.api.rawValue + "/x/msgfeed/unread"
        
        }
        
        fileprivate enum Member {
            
            static let info = httpPrefix + Host.api.rawValue + "/x/space/acc/info"
            
        }
        
    }
    
    fileprivate enum ErrorDescription: String {
        case unknown = "Unknown reason."
        case unexcepted = "Unexcepted response."
    }
    
    struct APIError: Error {
        
        let code: Int
        let message: String
        
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
    
    func memberInfo() -> Result<Account.MemberInfo, APIError> {
        return commonRequest(url: InterfaceURL.User.info) { data in
            let birthday = Account.MemberInfo.format(string: data["birthday"] as? String)
            let uid = (data["mid"] as? Int)?.description ?? .init()
            let sign = data["sign"] as? String ?? .init()
            let username = data["uname"] as? String ?? .init()
            let userID = data["userid"] as? String ?? .init()
            let rank = data["rank"] as? String ?? .init()
            let info = Account.MemberInfo(birthday: birthday, uid: uid, signature: sign, username: username, userID: userID, rank: rank)
            return info
        }
    }
    
    func upStatus() -> (errorDescription: String?, upStatus: Account.UpStatus?) {
        let semaphore = DispatchSemaphore()
        let responseQueue = DispatchQueue.global(qos: .utility)
        
        var result: (String?, Account.UpStatus?) = (nil, nil)
        
        AF.request(InterfaceURL.User.upVideoStatus).responseJSON(queue: responseQueue) { response in
            guard let value = response.value as? [String : Any] else {
                result.0 = ErrorDescription.unexcepted.rawValue
                semaphore.signal()
                return
            }
            
            let unexceptedHandler = {
                result.0 = value["message"] as? String ?? ErrorDescription.unexcepted.rawValue
                semaphore.signal()
            }
            
            if let code = value["code"] as? Int, code != 0 {
                unexceptedHandler()
                return
            }
            guard let data = value["data"] as? [String : Any] else {
                unexceptedHandler()
                return
            }
            let videoDelta = Account.UpStatus.VideoData(
                followers: data["incr_fans"] as? Int ?? 0,
                replies: data["incr_reply"] as? Int ?? 0,
                danmakus: data["incr_dm"] as? Int ?? 0,
                videoViews: data["incr_click"] as? Int ?? 0,
                coins: data["inc_coin"] as? Int ?? 0,
                likes: data["inc_like"] as? Int ?? 0,
                favorites: data["inc_fav"] as? Int ?? 0,
                shares: data["inc_share"] as? Int ?? 0,
                batteries: data["inc_elec"] as? Int ?? 0
            )
            let videoTotal = Account.UpStatus.VideoData(
                followers: data["total_fans"] as? Int ?? 0,
                replies: data["total_reply"] as? Int ?? 0,
                danmakus: data["total_dm"] as? Int ?? 0,
                videoViews: data["total_click"] as? Int ?? 0,
                coins: data["total_coin"] as? Int ?? 0,
                likes: data["total_like"] as? Int ?? 0,
                favorites: data["total_fav"] as? Int ?? 0,
                shares: data["total_share"] as? Int ?? 0,
                batteries: data["total_elec"] as? Int ?? 0
            )
            
            typealias FollowerData = Account.UpStatus.FollowerData
            
            var trend: (FollowerData, FollowerData) = (.init(), .init())
            if let followerData = data["fan_recent_thirty"] as? [String : [String : Int]] {
                trend = (
                    {
                        guard let follow = followerData["follow"] else {
                            return FollowerData()
                        }
                        var followData: FollowerData = .init()
                        for (k, v) in follow {
                            followData[Account.UpStatus.format(string: k)] = v
                        }
                        return followData
                    }(),
                    {
                        guard let unfollow = followerData["unfollow"] else {
                            return FollowerData()
                        }
                        var unfollowData: FollowerData = .init()
                        for (k, v) in unfollow {
                            unfollowData[Account.UpStatus.format(string: k)] = v
                        }
                        return unfollowData
                    }()
                )
            }
            
            typealias Article = Account.UpStatus.ArticleData
            var article: (Article, Article) = (.init(), .init())
            if let articleData = try? self.commonRequest(url: InterfaceURL.User.upArticleStatus, dataMapper: { data -> (Article, Article)? in
                guard let data = data as? [String : Int] else { return nil }
                let total = Article(
                    articleViews: data["view"] ?? .init(),
                    coins: data["coin"] ?? .init(),
                    likes: data["like"] ?? .init(),
                    favorites: data["fav"] ?? .init(),
                    replies: data["reply"] ?? .init(),
                    shares: data["share"] ?? .init()
                )
                let delta = Article(
                    articleViews: data["incr_view"] ?? .init(),
                    coins: data["incr_coin"] ?? .init(),
                    likes: data["incr_like"] ?? .init(),
                    favorites: data["incr_fav"] ?? .init(),
                    replies: data["incr_reply"] ?? .init(),
                    shares: data["incr_share"] ?? .init()
                )
                return (total, delta)
            }).get() {
                article = articleData
            }
            
            result.1 = Account.UpStatus(video: (videoTotal, videoDelta), article: article, followerTrend: trend)
            semaphore.signal()
        }
        semaphore.wait()
        return result
    }
    
    func numberOfUnread() -> (at: Int, like: Int, reply: Int, systemMessage: Int, up: Int) {
        let semaphore = DispatchSemaphore()
        let responseQueue = DispatchQueue.global(qos: .utility)
        
        var numberOfMessage: (Int, Int, Int, Int, Int) = (0, 0, 0, 0, 0)
        AF.request(InterfaceURL.User.numberOfUnread).responseJSON(queue: responseQueue) { response in
            guard let value = (response.value as? [String : Any])?["data"] as? [String : Int] else {
                semaphore.signal()
                return
            }
            numberOfMessage.0 = value["at"] ?? 0
            numberOfMessage.1 = value["like"] ?? 0
            numberOfMessage.2 = value["reply"] ?? 0
            numberOfMessage.3 = value["sys_msg"] ?? 0
            numberOfMessage.4 = value["up"] ?? 0
            semaphore.signal()
        }
        semaphore.wait()
        return numberOfMessage
    }
    
    func userInfo(uid: String) -> (errorDescription: String?, userInfo: Account.UserInfo?) {
        let semaphore = DispatchSemaphore()
        let responseQueue = DispatchQueue.global(qos: .utility)
        
        var result: (String?, Account.UserInfo?) = (nil, nil)
        AF.request(InterfaceURL.Member.info, parameters: ["mid": uid]).responseJSON(queue: responseQueue) { response in
            guard let value = response.value as? [String : Any] else {
                result.0 = ErrorDescription.unexcepted.rawValue
                semaphore.signal()
                return
            }
            guard let data = value["data"] as? [String : Any] else {
                result.0 = value["message"] as? String ?? ErrorDescription.unknown.rawValue
                semaphore.signal()
                return
            }
            
            let uid = (data["mid"] as? Int)?.description ?? .init()
            let username = data["name"] as? String ?? .init()
            let level = data["level"] as? Int ?? .init()
            let avatar = data["face"] as? String ?? .init()
            let sign = data["sign"] as? String ?? .init()
            let sex: Account.Sex = {
                var sex: Account.Sex = .unknown
                let sexDescription = data["sex"] as? String ?? .init()
                if sexDescription == "男" {
                    sex = .male
                } else if sexDescription == "女" {
                    sex = .female
                }
                return sex
            }()
            let coins = data["coins"] as? Double ?? .init()
            
            typealias Certification = Account.UserInfo.Certification
            let certification: Certification = {
                var cert = Certification(type: .none, description: .init(), remake: .init())
                if let official = data["official"] as? [String : Any] {
                    cert.type = {
                        var type: Certification.Role = .none
                        let typeNumber = official["type"] as? Int ?? .init()
                        switch typeNumber {
                        case 0:
                            type = .none
                        case 1, 2:
                            type = .personal
                        case 3, 4, 5, 6:
                            type = .institutional
                        default:
                            type = .none
                        }
                        return type
                    }()
                    cert.description = official["title"] as? String ?? .init()
                    cert.remake = official["desc"] as? String ?? .init()
                }
                return cert
            }()
            
            typealias VIP = Account.UserInfo.VIP
            let vip: VIP = {
                var vip = VIP(type: .none, expired: .init(), nickNameColor: .clear, description: .init())
                if let vipData = data["vip"] as? [String : Any] {
                    vip.type = VIP.Level(rawValue: vipData["type"] as? Int ?? .init()) ?? .none
                    vip.expired = Date(timeIntervalSince1970: ((vipData["due_date"] as? TimeInterval) ?? .init()) / 1000)
                    vip.nickNameColor = UIColor(hex: vipData["nickname_color"] as? String ?? .init())
                    if let vipLabel = vipData["label"] as? [String : Any] {
                        vip.description = vipLabel["text"] as? String ?? .init()
                    }
                }
                return vip
            }()
            
            result.1 = Account.UserInfo(
                uid: uid,
                username: username,
                sex: sex,
                avatarURL: avatar,
                signature: sign,
                level: level,
                coins: coins,
                certification: certification,
                vip: vip
            )
            semaphore.signal()
        }
        
        semaphore.wait()
        return result
    }
    
    // MARK: - Private Methods
    
    private func commonRequest<T>(url: String, parameters: Parameters = [:], dataMapper: @escaping ([String : Any]) -> T?) -> Result<T, APIError> {
        let semaphore = DispatchSemaphore()
        let responseQueue = DispatchQueue.global(qos: .utility)
        
        var result: Result<T, APIError>! = nil
        AF.request(url, parameters: parameters).responseJSON(queue: responseQueue) { response in
            let errorHandler = { (code: Int, message: String) in
                result = .failure(APIError(code: code, message: message))
                semaphore.signal()
            }
            
            guard let value = response.value as? [String : Any] else {
                errorHandler(-9999, ErrorDescription.unexcepted.rawValue)
                return
            }
            guard let code = value["code"] as? Int else {
                errorHandler(-9999, ErrorDescription.unexcepted.rawValue)
                return
            }
            guard let message = value["message"] as? String else {
                errorHandler(-9999, ErrorDescription.unexcepted.rawValue)
                return
            }
            
            guard code == 0 else {
                errorHandler(code, message)
                return
            }
            
            guard let data = value["data"] as? [String : Any] else {
                errorHandler(-9999, ErrorDescription.unexcepted.rawValue)
                return
            }
            guard let mappedResult = dataMapper(data) else {
                errorHandler(-9999, ErrorDescription.unexcepted.rawValue)
                return
            }
            
            result = .success(mappedResult)
            
            semaphore.signal()
        }
        semaphore.wait()
        return result
    }
    
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
