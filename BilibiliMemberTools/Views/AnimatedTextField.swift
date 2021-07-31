//
//  Created by ktiays on 2021/7/18.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import UIKit

public class AnimatedTextField: UIControl, UITextFieldDelegate {
    
    public var placeholder: String? {
        didSet {
            descrptionLabel.text = placeholder
            textField.frame.size = descrptionLabel.bounds.size
            sizeToFit()
        }
    }
    
    public var text: String? {
        set {
            textField.text = newValue
            setNeedsLayout()
        }
        get { textField.text }
    }
    
    public var maximumTextLength: Int = 0 {
        didSet {
            if maximumTextLength < 0 {
                maximumTextLength = oldValue
            }
        }
    }
    
    public var keyboardType: UIKeyboardType {
        set { textField.keyboardType = newValue }
        get { textField.keyboardType }
    }
    
    public var textContentType: UITextContentType {
        set { textField.textContentType = newValue }
        get { textField.textContentType }
    }
    
    public var clearButtonMode: UITextField.ViewMode {
        set { textField.clearButtonMode = newValue }
        get { textField.clearButtonMode }
    }
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        textField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
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
    
    private let padding: CGFloat = 12
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(descrptionLabel)
        addSubview(textField)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = bounds.width
        let height = bounds.height
        
        let labelSize = sizeOfPlaceholder()
        
        descrptionLabel.transform = .identity
        if !isTextFieldFocused && !textField.hasText {
            // Change text color of label to placeholder style.
            descrptionLabel.textColor = .secondaryLabel
            descrptionLabel.frame = .init(x: padding, y: 0, width: width - padding * 2, height: labelSize.height)
            descrptionLabel.center.y = height / 2
            
            textField.frame = .init(origin: descrptionLabel.frame.origin, size: .init(width: width - padding * 2, height: labelSize.height))
            
            backgroundColor = .secondarySystemBackground
        } else {
            // Change text color of label to title style.
            if textField.hasText && !isTextFieldFocused {
                descrptionLabel.textColor = .secondaryLabel
                backgroundColor = .secondarySystemBackground
            } else {
                descrptionLabel.textColor = .systemBlue
                backgroundColor = .systemBlue.withAlphaComponent(0.06)
            }
            
            let labelSize = descrptionLabel.bounds.size
            descrptionLabel.frame.origin = .init(x: padding - 0.1 * labelSize.width, y: padding - 0.1 * labelSize.height)
            descrptionLabel.transform = .init(scaleX: 0.8, y: 0.8)
            
            textField.frame.origin = .init(x: descrptionLabel.frame.origin.x, y: height - padding - labelSize.height)
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        let textSize = sizeOfPlaceholder()
        return .init(width: textSize.width + padding * 2, height: textSize.height * 2 + padding * 2)
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize { intrinsicContentSize }
    
    // MARK: Actions
    
    @objc private func textDidChange(_ sender: UITextField) {
        if let text = sender.text {
            if maximumTextLength > 0 && text.count > maximumTextLength {
                sender.text = text[..<maximumTextLength]
                return
            }
        }
        // FIXME: When pasting text, if the text length exceeds the maximum limit, the action will have a problem.
        sendActions(for: .editingChanged)
    }
    
    // MARK: Private Methods
    
    private func sizeOfPlaceholder() -> CGSize {
        let systemFont = UIFont.systemFont(ofSize: 17)
        return (placeholder as NSString?)?.boundingRect(with: bounds.size, options: .usesLineFragmentOrigin, attributes: [.font: systemFont], context: nil).size ?? .zero
    }
    
    // MARK: UITextFieldDelegate
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        isTextFieldFocused = true
        setNeedsLayout()
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: []) {
            self.layoutIfNeeded()
        } completion: { _ in }
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        isTextFieldFocused = false
        setNeedsLayout()
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: []) {
            self.layoutIfNeeded()
        } completion: { _ in }
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
