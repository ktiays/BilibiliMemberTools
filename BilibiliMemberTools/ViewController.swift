//
//  Created by ktiays on 2021/5/18.
//  Copyright (c) 2021 ktiays. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        apiTest()
    }
    
    func apiTest() {
        // Load Geetest verify page.
        let geetestHTML = Bundle.main.path(forResource: "Geetest/geetest", ofType: "html")
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self, name: "hostService")
        let geetestView = WKWebView(frame: view.bounds, configuration: configuration)
        geetestView.scrollView.backgroundColor = .clear
        geetestView.navigationDelegate = self
        geetestView.loadFileURL(URL(fileURLWithPath: geetestHTML!), allowingReadAccessTo: URL(fileURLWithPath: (geetestHTML! as NSString).deletingLastPathComponent as String))
        view.addSubview(geetestView)
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let args = APIManager.shared.captcha()
        webView.evaluateJavaScript("showGeetest(\"\(args.gt)\", \"\(args.challenge)\")")
    }
    
    // MARK: - WKScriptMessageHandler
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let code = message.body as? [String : String] else { return }
        let geetestCode: (validate: String, seccode: String) = (code["geetest_validate"] ?? .init(), code["geetest_seccode"] ?? .init())
        let alert = UIAlertController(title: "成功", message: geetestCode.0 + "\n" + geetestCode.1, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}
