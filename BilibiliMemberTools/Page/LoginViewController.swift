//
//  Created by ktiays on 2021/7/4.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import UIKit

// MARK: Login View Controller

class LoginViewController: UIViewController {
    
    private lazy var animatedTextField: AnimatedTextField = {
        let textField = AnimatedTextField(frame: .init(origin: .zero, size: .init(width: 200, height: 100)))
        textField.placeholder = "Animated Text Field"
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(animatedTextField)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        animatedTextField.center = view.center
    }
    
}

// MARK: - Animated Text Field

class AnimatedTextField: UIControl, UITextFieldDelegate {
    
    var placeholder: String? {
        didSet {
            descrptionLabel.text = placeholder
            
            textField.frame.size = descrptionLabel.bounds.size
        }
    }
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        return textField
    }()
    
    private lazy var descrptionLabel: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = false
        label.textAlignment = .left
        label.textColor = .secondaryLabel
        return label
    }()
    
    private var isTextFieldFocused: Bool = false
    
    private let padding: CGFloat = 20
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(descrptionLabel)
        addSubview(textField)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = bounds.width
        let height = bounds.height
        
        if !isTextFieldFocused && !textField.hasText {
            descrptionLabel.textColor = .secondaryLabel
            descrptionLabel.frame = .init(x: padding, y: 0, width: width - padding * 2, height: height)
            
            textField.frame = descrptionLabel.frame

        } else {
            descrptionLabel.textColor = .label
        }
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        isTextFieldFocused = true
        setNeedsLayout()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        isTextFieldFocused = false
        setNeedsLayout()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
