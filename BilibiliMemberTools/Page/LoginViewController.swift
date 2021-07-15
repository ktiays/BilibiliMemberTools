//
//  Created by ktiays on 2021/7/4.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import UIKit

// MARK: Login View Controller

class LoginViewController: UIViewController {
    
    private lazy var animatedTextField: AnimatedTextField = {
        let textField = AnimatedTextField()
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
            sizeToFit()
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
        
        let labelSize = sizeOfPlaceholder()
        
        if !isTextFieldFocused && !textField.hasText {
            // Change text color of label to placeholder style.
            descrptionLabel.textColor = .secondaryLabel
            
            descrptionLabel.frame = .init(x: padding, y: 0, width: width - padding * 2, height: labelSize.height)
            descrptionLabel.center.y = height / 2
            textField.frame = .init(origin: descrptionLabel.frame.origin, size: .init(width: width - padding * 2, height: labelSize.height))
        } else {
            // Change text color of label to title style.
            descrptionLabel.textColor = .label
            
            descrptionLabel.frame.origin = .init(x: padding, y: padding)
            textField.frame.origin = .init(x: descrptionLabel.frame.origin.x, y: height - padding - labelSize.height)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let textSize = sizeOfPlaceholder()
        return .init(width: textSize.width + padding * 2, height: textSize.height * 2 + padding * 2)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize { intrinsicContentSize }
    
    // MARK: Private Methods
    
    private func sizeOfPlaceholder() -> CGSize {
        let systemFont = UIFont.systemFont(ofSize: 17)
        return (placeholder as NSString?)?.boundingRect(with: bounds.size, options: .usesLineFragmentOrigin, attributes: [.font: systemFont], context: nil).size ?? .zero
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
