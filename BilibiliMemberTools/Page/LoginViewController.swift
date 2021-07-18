//
//  Created by ktiays on 2021/7/4.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import UIKit
import SVGKit
import WebKit

// MARK: Login View Controller

class LoginViewController: UIViewController {
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.addSubview(telTextField)
        view.addSubview(captchaTextField)
        view.addSubview(sendButton)
        view.addSubview(loginButton)
        return view
    }()
    
    private lazy var telTextField: AnimatedTextField = {
        let textField = AnimatedTextField()
        textField.cornerRadius = 10
        textField.placeholder = "手机号码"
        textField.maximumTextLength = phoneNumberLength
        textField.keyboardType = .numberPad
        textField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        return textField
    }()
    
    private lazy var captchaTextField: AnimatedTextField = {
        let textField = AnimatedTextField()
        textField.cornerRadius = 10
        textField.placeholder = "短信验证码"
        textField.keyboardType = .numberPad
        textField.maximumTextLength = 6
        return textField
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("发送验证码", for: .normal)
        button.addTarget(self, action: #selector(sendCode(_:)), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("登录", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(login(_:)), for: .touchUpInside)
        button.layer.masksToBounds = true
        return button
    }()
    
    private lazy var bilibiliView: SVGKFastImageView = { .init(svgkImage: .init(named: "SVG/bilibili.svg")) }()
    
    private lazy var textFieldIllustrationView: SVGKFastImageView = { .init(svgkImage: .init(named: "SVG/33.svg")) }()
    
    private lazy var backgroundIllustrationView: SVGKFastImageView = { .init(svgkImage: .init(named: "SVG/6699.svg")) }()
    
    private let phoneNumberLength: Int = 11
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(containerView)
        view.addSubview(bilibiliView)
        view.addSubview(textFieldIllustrationView)
        view.addSubview(backgroundIllustrationView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let padding: CGFloat = 20
        telTextField.frame = .init(x: padding, y: 0, width: view.bounds.width - padding * 2, height: telTextField.frame.height)
        captchaTextField.frame = .init(x: telTextField.frame.origin.x, y: telTextField.frame.maxY + padding, width: view.bounds.width - padding * 2 - 120, height: captchaTextField.frame.height)
        sendButton.frame = .init(x: captchaTextField.frame.maxX, y: captchaTextField.frame.origin.y, width: telTextField.frame.width - captchaTextField.frame.width, height: captchaTextField.frame.height)
        
        let loginButtonHeight: CGFloat = 50
        loginButton.frame = .init(x: 0, y: captchaTextField.frame.maxY + padding * 1.5, width: telTextField.frame.width, height: loginButtonHeight)
        loginButton.layer.cornerRadius = loginButtonHeight / 2
        loginButton.center.x = telTextField.center.x
        
        containerView.frame.size = .init(width: view.bounds.width, height: loginButton.frame.maxY)
        containerView.center = view.center
        
        let bilibiliLogoSize: CGSize = bilibiliView.image.size * 0.12
        bilibiliView.frame = .init(x: 0, y: view.safeAreaInsets.top + padding * 3, width: bilibiliLogoSize.width, height: bilibiliLogoSize.height)
        bilibiliView.center.x = view.center.x
        
        let textFieldIllustrationSize: CGSize = textFieldIllustrationView.image.size * 0.1
        textFieldIllustrationView.frame = .init(x: view.bounds.width - textFieldIllustrationSize.width - 60, y: containerView.frame.minY - textFieldIllustrationSize.height, width: textFieldIllustrationSize.width, height: textFieldIllustrationSize.height)
        
        let backgroundIllustrationSize: CGSize = backgroundIllustrationView.image.size * 0.2
        backgroundIllustrationView.frame = .init(x: 30, y: view.bounds.height - backgroundIllustrationSize.height - view.safeAreaInsets.bottom, width: backgroundIllustrationSize.width, height: backgroundIllustrationSize.height)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        containerView.endEditing(false)
    }
    
    // MARK: Actions
    
    @objc private func textDidChange(_ sender: AnimatedTextField) {
        sendButton.isEnabled = (sender.text?.count == phoneNumberLength)
    }
    
    @objc private func sendCode(_ sender: UIButton) {
        guard let telephone = telTextField.text else { return }
        let captchaViewController = CAPTCHAViewController(telephone: telephone)
        captchaViewController.captchaDidVerifyBlock = { captchaViewController.dismiss(animated: true, completion: nil) }
        captchaViewController.modalPresentationStyle = .fullScreen
        present(captchaViewController, animated: true, completion: nil)
    }
    
    @objc private func login(_ sender: UIButton) {
        guard let telephone = telTextField.text else { return }
        guard let smsCode = captchaTextField.text else { return }
        if telephone.count != phoneNumberLength || smsCode.count <= 0 { return }
        APIManager.shared.login(telephone: telephone, smsCode: smsCode) { errorDescription in
            if errorDescription == nil {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}

// MARK: - CAPTCHA View Controller

fileprivate class CAPTCHAViewController: UIViewController {
    
    init(telephone: String) {
        self.telephone = telephone
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private(set) var telephone: String
    
    var captchaDidVerifyBlock: (() -> Void)?
    
    fileprivate struct Captcha {
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
    
    fileprivate lazy var captchaView: WKWebView = {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = captchaView
    }
    
    func requestSMSCode() {
        APIManager.shared.sms(telephone: telephone, captchaCode: (captcha.key, captcha.challenge, captcha.validate, captcha.seccode))
    }
    
}

// MARK: WKNavigationDelegate

extension CAPTCHAViewController: WKNavigationDelegate {
    
    fileprivate func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let args = APIManager.shared.captcha()
        captcha.key = args.key
        captcha.gt = args.gt
        captcha.challenge = args.challenge
        webView.evaluateJavaScript("showGeetest(\"\(args.gt)\", \"\(args.challenge)\")")
    }
    
}

// MARK: WKScriptMessageHandler

extension CAPTCHAViewController: WKScriptMessageHandler {
    
    fileprivate func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let code = message.body as? [String : String] else { return }
        captcha.validate = code["geetest_validate"] ?? .init()
        captcha.seccode = code["geetest_seccode"] ?? .init()
        captchaDidVerifyBlock?()
        requestSMSCode()
    }
    
}

// MARK: - Evoke Login View Function

public class LoginAssistant {
    
    private static let shared = LoginAssistant()
    
    private var controller: UIViewController?
    
    private var hasLogged: Bool = false
    
    /// When the information returned by the API interface indicates that the user is not logged in,
    /// call this method to evoke the login page.
    public class func login() {
        if shared.hasLogged { return }
        
        let loginViewController = LoginViewController()
        loginViewController.modalPresentationStyle = .fullScreen
        
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        var topViewController = scene.windows.filter { $0.isKeyWindow }.first?.rootViewController
        while topViewController?.presentedViewController != nil {
            topViewController = topViewController?.presentedViewController
        }
        shared.controller = topViewController
        topViewController?.present(loginViewController, animated: true, completion: nil)
        shared.hasLogged = true
    }
    
}
