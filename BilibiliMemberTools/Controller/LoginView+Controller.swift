//
//  Created by ktiays on 2021/5/19.
//  Copyright (c) 2021 ktiays. All rights reserved.
//

import WebKit
import SwiftUI

extension LoginView {
    
    class Controller: NSObject {
        
        var telephone: String = .init()
        
        var captchaDidVerifyBlock: (() -> Void)?
        
        fileprivate struct Captcha {
            var key: String = .init()
            var gt: String = .init()
            var challenge: String = .init()
            var validate: String = .init()
            var seccode: String = .init()
        }
        
        struct WebView: UIViewRepresentable {
            
            typealias UIViewType = WKWebView
            
            var webView: WKWebView
            
            func makeUIView(context: Context) -> WKWebView {
                webView
            }
            
            func updateUIView(_ uiView: WKWebView, context: Context) {
                
            }
            
        }
        
        private let geetestHTMLPath: String? = Bundle.main.path(forResource: "Geetest/geetest", ofType: "html")
        
        private lazy var captchaViewConfiguration: WKWebViewConfiguration = {
            let configuration = WKWebViewConfiguration()
            configuration.userContentController.add(self, name: "hostService")
            return configuration
        }()
        lazy var captchaView: WKWebView = {
            let webView = WKWebView(frame: .zero, configuration: captchaViewConfiguration)
            webView.navigationDelegate = self
            guard let path = geetestHTMLPath else {
                assert(false, "The HTML file of the Geetest captcha page was not found.")
            }
            webView.loadFileURL(URL(fileURLWithPath: path),
                                allowingReadAccessTo: URL(fileURLWithPath: (path as NSString).deletingLastPathComponent as String))
            return webView
        }()
        
        private var captcha: Captcha = Captcha()
        
        func requestSMSCode() {
            APIManager.shared.sms(telephone: telephone, captchaCode: (captcha.key, captcha.challenge, captcha.validate, captcha.seccode))
        }
        
        func login(telephone: String, smsCode code: String, completionHandler: @escaping (() -> Void)) {
            APIManager.shared.login(telephone: telephone, smsCode: code) { errorDescription in
                completionHandler()
            }
        }
        
    }
    
}

extension LoginView.Controller: WKNavigationDelegate, WKScriptMessageHandler {
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let args = APIManager.shared.captcha()
        captcha.key = args.key
        captcha.gt = args.gt
        captcha.challenge = args.challenge
        webView.evaluateJavaScript("showGeetest(\"\(args.gt)\", \"\(args.challenge)\")")
    }
    
    // MARK: - WKScriptMessageHandler
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let code = message.body as? [String : String] else { return }
        captcha.validate = code["geetest_validate"] ?? .init()
        captcha.seccode = code["geetest_seccode"] ?? .init()
        captchaDidVerifyBlock?()
        requestSMSCode()
    }
    
}
