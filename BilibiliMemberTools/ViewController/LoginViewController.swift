//
//  Created by ktiays on 2021/5/19.
//  Copyright (c) 2021 ktiays. All rights reserved.
//

import UIKit
import WebKit

class LoginViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    
    private struct Captcha {
        var key: String = .init()
        var gt: String = .init()
        var challenge: String = .init()
        var validate: String = .init()
        var seccode: String = .init()
    }
    
    private let geetestHTMLPath: String? = Bundle.main.path(forResource: "Geetest/geetest", ofType: "html")
    
    private lazy var captchaViewConfiguration: WKWebViewConfiguration = {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self, name: "hostService")
        return configuration
    }()
    private lazy var captchaView: WKWebView = {
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
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(captchaView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        captchaView.frame = view.bounds
    }
    
    // MARK: - Private Methods
    
    func requestSMSCode() {
        APIManager.shared.sms(telephone: "13970005990", captchaCode: (captcha.key, captcha.challenge, captcha.validate, captcha.seccode))
    }
    
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
        captchaView.removeFromSuperview()
        requestSMSCode()
    }
    
}