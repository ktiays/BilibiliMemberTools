//
//  Created by ktiays on 2021/8/13.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import UIKit
import SnapKit

class InputTextField: UIControl {
    
    var delegate: UITextFieldDelegate? {
        get { textField.delegate }
        set { textField.delegate = newValue }
    }
    
    var emoteClickAction: (() -> ())?
    var showsKeyboardIcon: Bool = false {
        didSet {
            emoteButton.setImage(.init(systemName: showsKeyboardIcon ? "keyboard" : "face.smiling"), for: .normal)
        }
    }
    
    /// The corner radius using a continuous corner curve, for the text field background.
    private let _radius: CGFloat = displayCornerRadius - 16
    
    private(set) lazy var textField: UITextField = {
        let textField = UITextField()
        return textField
    }()
    
    private lazy var emoteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "face.smiling"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.addAction(.init(handler: { [unowned self] _ in
            self.emoteClickAction?()
        }), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    @available(*, unavailable) required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        addSubview(textField)
        addSubview(emoteButton)
        setupConstraints()
    }
    
    func setupConstraints() {
        textField.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(_radius / 1.5)
        }
        emoteButton.snp.makeConstraints { make in
            let padding = _radius * 0.85
            make.width.equalTo(emoteButton.snp.height)
            make.trailing.equalToSuperview().offset(-padding)
            make.leading.equalTo(textField.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
        }
    }
    
}
