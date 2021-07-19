//
//  Created by ktiays on 2021/7/4.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import UIKit
import SVGKit
import WebKit
import Combine

// MARK: Login View Controller

class LoginViewController: UIViewController {
    
    private lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["客户端登录", "短信验证码登录"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentDidChange(_:)), for: .valueChanged)
        segmentedControl.sizeToFit()
        return segmentedControl
    }()
    
    private lazy var clientContainerView: UIView = {
        let view = UIView()
        view.addSubview(bilibiliIconImageView)
        view.addSubview(clientLoginDescriptionLabel)
        view.addSubview(clientLoginButton)
        return view
    }()
    
    private lazy var captchaContainerView: UIView = {
        let view = UIView()
        view.addSubview(textFieldIllustrationView)
        view.addSubview(telTextField)
        view.addSubview(captchaTextField)
        view.addSubview(sendButton)
        view.addSubview(captchaLoginButton)
        view.isHidden = true
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
        textField.textContentType = .oneTimeCode
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
    
    private lazy var clientLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("跳转至哔哩哔哩客户端", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundColor(.init(named: "BilibiliAccentColor"), for: .normal)
        button.addTarget(self, action: #selector(redirect(_:)), for: .touchUpInside)
        button.layer.masksToBounds = true
        return button
    }()
    
    private lazy var captchaLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("登录", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(login(_:)), for: .touchUpInside)
        button.layer.masksToBounds = true
        return button
    }()
    
    private lazy var bilibiliIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "BilibiliIcon"))
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private lazy var clientLoginDescriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.text = "通过哔哩哔哩客户端进行登录"
        label.sizeToFit()
        return label
    }()
    
    private lazy var bilibiliView: SVGKFastImageView = { .init(svgkImage: .init(named: "SVG/bilibili.svg")) }()
    private lazy var textFieldIllustrationView: SVGKFastImageView = { .init(svgkImage: .init(named: "SVG/33.svg")) }()
    private lazy var backgroundIllustrationView: SVGKFastImageView = { .init(svgkImage: .init(named: "SVG/6699.svg")) }()
    
    private let phoneNumberLength: Int = 11
    
    private var loginQRCode: LoginQRCode?
    private var oauthTimerCancellable: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(segmentedControl)
        view.addSubview(clientContainerView)
        view.addSubview(captchaContainerView)
        view.addSubview(bilibiliView)
        view.addSubview(backgroundIllustrationView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let padding: CGFloat = 20
        let textFieldHeight: CGFloat = 65
        let loginButtonHeight: CGFloat = 50
        
        let containerSize: CGSize = .init(width: view.bounds.width, height: textFieldHeight * 2 + padding * 2.5 + loginButtonHeight)
        captchaContainerView.frame.size = containerSize
        captchaContainerView.center = view.center
        clientContainerView.frame.size = containerSize
        clientContainerView.center = view.center
        
        // Actual display login content size.
        let contentSize: CGSize = .init(width: containerSize.width - padding * 2, height: containerSize.height)
        
        let backgroundIllustrationSize: CGSize = backgroundIllustrationView.image.size * 0.2
        backgroundIllustrationView.frame = .init(x: 30, y: view.bounds.height - backgroundIllustrationSize.height - view.safeAreaInsets.bottom, width: backgroundIllustrationSize.width, height: backgroundIllustrationSize.height)
        
        // Client Login Layout
        
        let iconSize: CGSize = .init(width: 80, height: 80)
        bilibiliIconImageView.frame.size = iconSize
        bilibiliIconImageView.center = .init(x: containerSize.width / 2, y: iconSize.height / 2 + padding)
        bilibiliIconImageView.continuousCornerRadius = iconSize.width * 0.225
        
        clientLoginButton.frame = .init(x: 0, y: contentSize.height - loginButtonHeight, width: contentSize.width - 60, height: loginButtonHeight)
        clientLoginButton.continuousCornerRadius = loginButtonHeight / 2
        clientLoginButton.center.x = captchaContainerView.center.x
        
        clientLoginDescriptionLabel.center = .init(x: containerSize.width / 2, y: (clientLoginButton.frame.minY + bilibiliIconImageView.frame.maxY) / 2)
        
        // CAPTCHA Login Layout
        
        captchaLoginButton.frame = .init(x: 0, y: contentSize.height - loginButtonHeight, width: contentSize.width, height: loginButtonHeight)
        captchaLoginButton.continuousCornerRadius = loginButtonHeight / 2
        captchaLoginButton.center.x = captchaContainerView.center.x
        
        let textFieldIllustrationSize: CGSize = textFieldIllustrationView.image.size * 0.1
        textFieldIllustrationView.frame = .init(x: view.bounds.width - textFieldIllustrationSize.width - 55, y: -textFieldIllustrationSize.height, width: textFieldIllustrationSize.width, height: textFieldIllustrationSize.height)
        
        segmentedControl.center = .init(x: segmentedControl.frame.width / 2 + padding, y: captchaContainerView.frame.minY - textFieldIllustrationSize.height / 2)
        
        telTextField.frame = .init(x: padding, y: 0, width: view.bounds.width - padding * 2, height: textFieldHeight)
        captchaTextField.frame = .init(x: telTextField.frame.origin.x, y: telTextField.frame.maxY + padding, width: view.bounds.width - padding * 2 - 120, height: textFieldHeight)
        sendButton.frame = .init(x: captchaTextField.frame.maxX, y: captchaTextField.frame.origin.y, width: telTextField.frame.width - captchaTextField.frame.width, height: captchaTextField.frame.height)
        
        let bilibiliLogoSize: CGSize = bilibiliView.image.size * 0.12
        bilibiliView.frame = .init(x: 0, y: view.safeAreaInsets.top + padding * 3, width: bilibiliLogoSize.width, height: bilibiliLogoSize.height)
        bilibiliView.center.x = view.center.x
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) { captchaContainerView.endEditing(false) }
    
    // MARK: Actions
    
    @objc private func textDidChange(_ sender: AnimatedTextField) {
        sendButton.isEnabled = (sender.text?.count == phoneNumberLength)
    }
    
    @objc private func segmentDidChange(_ sender: UISegmentedControl) {
        UIView.transition(with: view, duration: 0.2, options: .transitionCrossDissolve) { [self] in
            switch sender.selectedSegmentIndex {
            case 0:
                clientContainerView.isHidden = false
                captchaContainerView.isHidden = true
            case 1:
                clientContainerView.isHidden = true
                captchaContainerView.isHidden = false
            default:
                break
            }
        } completion: { _ in
            
        }

        
    }
    
    @objc private func sendCode(_ sender: UIButton) {
        guard let telephone = telTextField.text else { return }
        let captchaViewController = CAPTCHAViewController(telephone: telephone)
        captchaViewController.captchaDidVerifyBlock = { captchaViewController.dismiss(animated: true, completion: nil) }
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
    
    @objc private func redirect(_ sender: UIButton) {
        Task.detached { [self] in
            guard let qrCode = try? await APIManager.shared.qrCode() else { return }
            await MainActor.run { loginQRCode = qrCode }
            let encodedURL = qrCode.url.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: ":/?=").inverted) ?? .init()
            guard let url = URL(string: BilibiliURLScheme.browser + "?url=" + encodedURL) else { return }
            
            // Open the bilibili client through the URL scheme.
            let result = await UIApplication.shared.open(url)
            print(result ? "Successfully redirected to bilibili client." : "Redirection to bilibili client failed.")
            guard result else {
                return
            }
            await pollingAuthStatus()
        }
    }
    
    func pollingAuthStatus() {
        guard oauthTimerCancellable == nil else { return }
        
        oauthTimerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                Task.detached { [self] in
                    guard let oauthKey = await loginQRCode?.oauthKey else { return }
                    guard let authStatus = try? await APIManager.shared.authStatus(oauthKey: oauthKey) else {
                        print("An error occurred while obtaining authorization status.")
                        return
                    }
                    do {
                        let _ = try authStatus.status.get()
                        print("Authentication succeeded.")
                        await oauthTimerCancellable?.cancel()
                        await dismiss(animated: true, completion: nil)
                    } catch let error as AuthStatus.AuthError {
                        switch error {
                        case .incorrectKey:
                            print("OAuth key is not correct.")
                        case .expiredKey:
                            print("OAuth key is expired. Please try again.")
                            await oauthTimerCancellable?.cancel()
                        case .notScanned:
                            print("The QR code has not been scanned yet.")
                        case .unauthorized:
                            print("The QR code has been scanned, but the authorization has not been confirmed.")
                        default:
                            print("Unknown reason for failure.")
                        }
                    }
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
    
    @available(*, unavailable) required init?(coder: NSCoder) {
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
    
    @inline(__always) func requestSMSCode() {
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
        
        topViewController?.present(loginViewController, animated: true, completion: nil)
        shared.hasLogged = true
    }
    
}
