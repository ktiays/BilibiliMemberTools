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
        
        // Authentication related.
        fileprivate enum Auth {
        
            static let captcha = httpPrefix + Host.passport.rawValue + "/web/captcha/combine"
            
            static let countryList = httpPrefix + Host.passport.rawValue + "/web/generic/country/list"
            
            static let sms = httpPrefix + Host.passport.rawValue + "/web/sms/general/v2/send"
            
            static let loginSMS = httpPrefix + Host.passport.rawValue + "/web/login/rapid"
            
            static let qrCode = httpPrefix + Host.passport.rawValue + "/qrcode/getLoginUrl"
            
            static let authStatus = httpPrefix + Host.passport.rawValue + "/qrcode/getLoginInfo"
            
        }
        
        // Bilibili user data APIs.
        fileprivate enum User {
            
            static let info = httpPrefix + Host.api.rawValue + "/x/member/web/account"
            
            static let upVideoStatus = httpPrefix + Host.member.rawValue + "/x/web/index/stat"
            
            static let upArticleStatus = httpPrefix + Host.member.rawValue + "/x/web/data/article"
            
            // Details of video content.
            static let videos = httpPrefix + Host.member.rawValue + "/x/web/archives"
            
            // Details of article content.
            static let articles = httpPrefix + Host.api.rawValue + "/x/article/creative/article/list"
            
            static let relation = httpPrefix + Host.api.rawValue + "/x/space/acc/relation"
            
            fileprivate enum MessageFeed {
                
                private static let prefix = httpPrefix + Host.api.rawValue + "/x/msgfeed"
                
                static let numberOfUnread = `prefix` + "/unread"
                
                static let reply = `prefix` + "/reply"
                
                static let like = `prefix` + "/like"
                
            }
        
        }
        
        // Bilibili account data APIs.
        fileprivate enum Member {
            
            static let info = httpPrefix + Host.api.rawValue + "/x/space/acc/info"
            
        }
        
    }
    
    fileprivate enum ErrorDescription: String {
        case unknown = "Unknown reason."
        case unexcepted = "Unexcepted response."
        case unresolved = "An error occurred while parsing the data."
    }
    
    struct APIError: Error {
        
        let code: Int
        let message: String
        
    }
    
    enum ApprovalStatusOption: String {
        case reviewing = "is_pubing"
        case published = "pubed"
        case rejected = "not_pubed"
    }
    
    private var _countryCode: Int?
    
    private let standardHeaders: HTTPHeaders = [
        .userAgent("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15")
    ]
    
    // MARK: - Public Methods
    
    func captcha() async -> (challenge: String, gt: String, key: String) {
        var captchaArgs: (String, String, String) = (.init(), .init(), .init())
        let response = await AF.request(InterfaceURL.Auth.captcha, parameters: ["plat": 6], headers: standardHeaders).responseJSON()
        guard let result = response.value as? [String : Any] else { return captchaArgs }
        guard let args = (result["data"] as? [String : Any])?["result"] as? [String : Any] else { return captchaArgs }
        captchaArgs.0 = args["challenge"] as? String ?? .init()
        captchaArgs.1 = args["gt"] as? String ?? .init()
        captchaArgs.2 = args["key"] as? String ?? .init()
        return captchaArgs
    }
    
    func sms(telephone: String, captchaCode: (key: String, challenge: String, validate: String, seccode: String)) async {
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
        let response = await AF.request(InterfaceURL.Auth.sms, method: .post, parameters: params, headers: standardHeaders).responseJSON()
        guard let result = response.value as? [String : Any] else { return }
        if let code = result["code"] as? Int, code == 0 {
            print("The SMS code request was successful.")
        } else {
            print("Failed to request SMS code.(\(result["message"] as? String ?? "Unknow reason"))")
        }
    }
    
    func login(telephone: String, smsCode: String) async -> String? {
        let params = [
            "cid": self.countryCode()?.description ?? .init(),
            "tel": telephone,
            "smsCode": smsCode
        ]
        let response = await AF.request(InterfaceURL.Auth.loginSMS, method: .post, parameters: params, headers: standardHeaders).responseJSON()
        guard let result = response.value as? [String : Any] else { return nil }
        if let code = result["code"] as? Int, code == 0 {
            print("Login successful.")
            return nil
        } else {
            let errorDescription = "\(result["message"] as? String ?? "Unknow reason")"
            print("Login failed.(\(errorDescription))")
            return errorDescription
        }
    }
    
    
    func qrCode() async throws -> LoginQRCode {
        let qrCode = try await AF.request(InterfaceURL.Auth.qrCode, headers: standardHeaders).responseJSON().result.get() as? [String : Any]
        // Determine whether there is an error in the status code.
        let statusCode = qrCode?["code"] as? Int ?? -1
        if statusCode != 0 { throw APIError(code: statusCode, message: "An error occurred while requesting to log in to the QR code.") }
        let timestamp = qrCode?["ts"] as? Int ?? .zero
        // Extract url of the QR code.
        let codeData = qrCode?["data"] as? [String : String]
        let url = codeData?["url"] ?? .init()
        let oauthKey = codeData?["oauthKey"] ?? .init()
        return LoginQRCode(url: url, oauthKey: oauthKey, timestamp: timestamp)
    }
    
    func authStatus(oauthKey: String, to redirection: String = "https://www.bilibili.com") async throws -> AuthStatus {
        let statusData = try await AF.request(InterfaceURL.Auth.authStatus, method: .post, parameters: [
            "oauthKey": oauthKey,
            "gourl": redirection
        ], headers: standardHeaders).responseJSON().result.get() as? [String : Any]
        let error = APIError(code: -9999, message: ErrorDescription.unexcepted.rawValue)
        guard let data = statusData?["data"] else { throw error }
        if let errorCode = data as? Int {
            // Authentication failed.
            guard let message = statusData?["message"] as? String else { throw error }
            return .init(message: message, data: errorCode)
        } else if let gameURL = (data as? [String : String])?["url"] {
            // Authentication succeeded.
            return .init(data: gameURL)
        } else {
            throw error
        }
    }
    
    func memberInfo() async throws -> Account.MemberInfo {
        try await commonRequest(url: InterfaceURL.User.info) { data in
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
        
        AF.request(InterfaceURL.User.upVideoStatus, headers: standardHeaders).responseJSON(queue: responseQueue) { response in
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
            let videoDelta = Account.UpStatus.VideoStatus(
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
            let videoTotal = Account.UpStatus.VideoStatus(
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
            
            typealias Article = Account.UpStatus.ArticleStatus
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
    
    func userInfo(uid: String) async throws -> Account.UserInfo {
        try await commonRequest(url: InterfaceURL.Member.info, parameters: ["mid": uid]) { data in
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
            
            return Account.UserInfo(
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
        }
    }
    
    func videos(for options: [ApprovalStatusOption], videoHandler: (Result<[Video], APIError>) -> Void) {
        // Number of videos has requested.
        var count = 0
        // The total number of videos that need to be requested.
        var total = 0
        
        let pageSize = 10
        var pageIndex = 1
        repeat {
            videoHandler(commonRequest(
                url: InterfaceURL.User.videos,
                parameters: ["status": options.map { $0.rawValue }.joined(separator: ","),
                             "pn": pageIndex.description,
                             "ps": pageSize.description]
            ) { data -> [Video]? in
                // Videos data.
                guard let videos = data["arc_audits"] as? [[String : Any]] else { return nil }
                var result: [Video] = []
                for video in videos {
                    // Get the status data of video.
                    guard let statusData = video["stat"] as? [String : Int] else { return nil }
                    let status = Video.Status(
                        views: statusData["view"] ?? .init(),
                        danmakus: statusData["danmaku"] ?? .init(),
                        replies: statusData["reply"] ?? .init(),
                        likes: statusData["like"] ?? .init(),
                        coins: statusData["coin"] ?? .init(),
                        favorites: statusData["favorite"] ?? .init(),
                        shares: statusData["share"] ?? .init()
                    )
                    
                    // Get the base information of video.
                    guard let information = video["Archive"] as? [String : Any] else { return nil }
                    let video = Video(
                        title: information["title"] as? String ?? .init(),
                        coverURL: information["cover"] as? String ?? .init(),
                        publishedTime: Date(timeIntervalSince1970: TimeInterval(information["ptime"] as? Int ?? .init())),
                        av: (statusData["aid"] ?? Int .init()).description,
                        bv: information["bvid"] as? String ?? .init(),
                        description: information["desc"] as? String ?? .init(),
                        duration: information["duration"] as? Int ?? .init(),
                        status: status
                    )
                    result.append(video)
                }
                // Pages data.
                guard let pages = data["page"] as? [String : Int] else { return nil }
                count += result.count
                total = pages["count"] ?? .zero
                pageIndex += 1
                return result
            })
        } while count < total
    }
    
    func articles(_ articlesHandler: (Result<[Article], APIError>) -> Void) {
        // Number of articles has requested.
        var count = 0
        // The total number of articles that need to be requested.
        var total = 0
        
        var pageIndex = 1
        repeat {
            articlesHandler(commonRequest(
                url: InterfaceURL.User.articles,
                parameters: ["group": "0",
                             "pn": pageIndex.description,
                             "sort": "",
                             "mobi_app": "pc"]
            ) { data -> [Article]? in
                // Articles data.
                guard let articles = data["articles"] as? [[String : Any]] else { return nil }
                var result: [Article] = []
                for article in articles {
                    // Get the status data of article.
                    guard let statusData = article["stats"] as? [String : Int] else { return nil }
                    let status = Article.Status(
                        views: statusData["view"] ?? .zero,
                        replies: statusData["reply"] ?? .zero,
                        likes: statusData["like"] ?? .zero,
                        dislikes: statusData["dislike"] ?? .zero,
                        coins: statusData["coin"] ?? .zero,
                        favorites: statusData["favorite"] ?? .zero,
                        shares: statusData["share"] ?? .zero
                    )
                    
                    // Get the base information of article.
                    let id = (article["id"] as? Int ?? .init()).description
                    let title = article["title"] as? String ?? .init()
                    let summary = article["summary"] as? String ?? .init()
                    let publishTime = Date(timeIntervalSince1970: TimeInterval(article["publish_time"] as? Int ?? .init()))
                    let imageURL = (article["origin_image_urls"] as? [String])?.first ?? .init()
                    let viewURL = article["view_url"] as? String ?? .init()
                    
                    result.append(Article(
                        cv: id,
                        title: title,
                        summary: summary,
                        coverURL: imageURL,
                        url: viewURL,
                        publishedTime: publishTime,
                        status: status)
                    )
                }
                // Pages data.
                guard let pages = data["page"] as? [String : Int] else { return nil }
                count += result.count
                total = pages["total"] ?? .zero
                pageIndex += 1
                return result
            })
        } while count < total
    }
    
    // MARK: - Message Feed
    
    func numberOfUnread() -> (at: Int, like: Int, reply: Int, systemMessage: Int, up: Int) {
        (try? commonRequest(url: InterfaceURL.User.MessageFeed.numberOfUnread, dataMapper: { data -> (Int, Int, Int, Int, Int) in
            var numberOfMessage: (Int, Int, Int, Int, Int) = (0, 0, 0, 0, 0)
            guard let value = data as? [String : Int] else { return numberOfMessage }
            numberOfMessage.0 = value["at"] ?? 0
            numberOfMessage.1 = value["like"] ?? 0
            numberOfMessage.2 = value["reply"] ?? 0
            numberOfMessage.3 = value["sys_msg"] ?? 0
            numberOfMessage.4 = value["up"] ?? 0
            return numberOfMessage
        }).get()) ?? (0, 0, 0, 0, 0)
    }
    
    func replyFeed() -> Result<[Reply], APIError> {
        commonRequest(url: InterfaceURL.User.MessageFeed.reply, dataMapper: { replyData -> [Reply] in
            guard let replies = replyData["items"] as? [[String : Any]] else { return [] }
            var result: [Reply] = []
            for reply in replies {
                let id = (reply["id"] as? Int)?.description ?? .init()
                
                guard let userData = reply["user"] as? [String : Any] else { return [] }
                let uid = (userData["mid"] as? Int)?.description ?? .init()
                let username = userData["nickname"] as? String ?? .init()
                let avatarURL = userData["avatar"] as? String ?? .init()
                
                let user = User(uid: uid, username: username, avatarURL: avatarURL)
                
                guard let comment = reply["item"] as? [String : Any] else { return [] }
                let content = comment["source_content"] as? String ?? .init()
                
                let timestamp = Double(reply["reply_time"] as? Int ?? .zero)
                let time = Date(timeIntervalSince1970: timestamp)
                
                result.append(Reply(id: id, user: user, content: content, time: time))
            }
            return result
        })
    }
    
    // MARK: - Relation
    
    func relation(with uid: String, completion: @escaping (Result<TimestampedState<Relation>, APIError>) -> Void)  {
        commonRequest(url: InterfaceURL.User.relation, parameters: ["mid": uid], dataMapper: { relationData -> TimestampedState<Relation> in
            var state: TimestampedState<Relation> = .init(state: .none, timestamp: .zero)
            guard let _relation = relationData["relation"] as? [String : Any] else { return state }
            let attr = _relation["attribute"] as? Int ?? .zero
            switch attr {
            case 2:
                state.state = .following
            case 6:
                state.state = .friend
            case 128...:
                state.state = .blacklist
            default:
                break
            }
            guard let _related = relationData["be_relation"] as? [String : Any] else { return state }
            if state.state == .none && _related["attribute"] as? Int ?? .zero == 2 {
                state.state = .followed
            }
            state.timestamp = TimeInterval(min(_relation["mtime"] as? Int ?? .zero, _related["mtime"] as? Int ?? .zero))
            return state
        }, completion: completion)
    }
    
    // MARK: - Private Methods
    
    private func commonRequest<T>(url: String, parameters: Parameters = [:], dataMapper: @escaping ([String : Any]) -> T?) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            commonRequest(url: url, parameters: parameters, dataMapper: dataMapper) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    private func commonRequest<T>(url: String, parameters: Parameters = [:], dataMapper: @escaping ([String : Any]) -> T?, completion: @escaping (Result<T, APIError>) -> Void) {
        AF.request(url, parameters: parameters, headers: standardHeaders).responseJSON { response in
            let errorHandler = { (code: Int, message: String) in
                completion(.failure(APIError(code: code, message: message)))
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
                errorHandler(-9999, ErrorDescription.unresolved.rawValue)
                return
            }
            
            completion(.success(mappedResult))
        }
    }
    
    private func commonRequest<T>(url: String, parameters: Parameters = [:], dataMapper: @escaping ([String : Any]) -> T?) -> Result<T, APIError> {
        let semaphore = DispatchSemaphore()
        let responseQueue = DispatchQueue.global(qos: .utility)
        
        var result: Result<T, APIError>! = nil
        AF.request(url, parameters: parameters, headers: standardHeaders).responseJSON(queue: responseQueue) { response in
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
            
            // Since the Bilibili interface format is not uniform,
            // an additional filter layer correction data is added.
            let dataInterceptor: () -> Any? = {
                switch url {
                case InterfaceURL.User.articles:
                    return value["artlist"]
                default:
                    return value["data"]
                }
            }
            
            guard let data = dataInterceptor() as? [String : Any] else {
                errorHandler(-9999, ErrorDescription.unexcepted.rawValue)
                return
            }
            guard let mappedResult = dataMapper(data) else {
                errorHandler(-9999, ErrorDescription.unresolved.rawValue)
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
        AF.request(InterfaceURL.Auth.countryList, headers: standardHeaders).responseJSON(queue: handlerQueue) { response in
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
