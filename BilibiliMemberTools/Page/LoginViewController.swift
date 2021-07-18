//
//  Created by ktiays on 2021/7/4.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import UIKit
import SVGKit

// MARK: Login View Controller

class LoginViewController: UIViewController {
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.addSubview(telTextField)
        view.addSubview(passwordTextField)
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
    
    private lazy var passwordTextField: AnimatedTextField = {
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
    
    private lazy var textFieldIllustrationView: SVGKFastImageView = { .init(svgkImage: .init(named: "SVG/33.svg")) }()
    
    private lazy var backgroundIllustrationView: SVGKFastImageView = { .init(svgkImage: .init(named: "SVG/6699.svg")) }()
    
    private let phoneNumberLength: Int = 11
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(containerView)
        view.addSubview(textFieldIllustrationView)
        view.addSubview(backgroundIllustrationView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let padding: CGFloat = 20
        telTextField.frame = .init(x: padding, y: 0, width: view.bounds.width - padding * 2, height: telTextField.frame.height)
        passwordTextField.frame = .init(x: telTextField.frame.origin.x, y: telTextField.frame.maxY + padding, width: view.bounds.width - padding * 2 - 120, height: passwordTextField.frame.height)
        sendButton.frame = .init(x: passwordTextField.frame.maxX, y: passwordTextField.frame.origin.y, width: telTextField.frame.width - passwordTextField.frame.width, height: passwordTextField.frame.height)
        
        let loginButtonHeight: CGFloat = 50
        loginButton.frame = .init(x: 0, y: passwordTextField.frame.maxY + padding * 1.5, width: telTextField.frame.width, height: loginButtonHeight)
        loginButton.layer.cornerRadius = loginButtonHeight / 2
        loginButton.center.x = telTextField.center.x
        
        containerView.frame.size = .init(width: view.bounds.width, height: loginButton.frame.maxY)
        containerView.center = view.center
        
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
        
    }
    
    @objc private func login(_ sender: UIButton) {
        
    }
    
}
