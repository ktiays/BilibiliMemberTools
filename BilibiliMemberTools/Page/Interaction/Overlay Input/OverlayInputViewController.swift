//
//  Created by ktiays on 2021/8/13.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import UIKit
import SwiftUI
import SnapKit

class OverlayInputViewController: UIViewController {
    
    /// The corner radius using a continuous corner curve, for the text field background.
    private let _radius: CGFloat = displayCornerRadius - _spacing
    
    private static let _spacing: CGFloat = 8
    private let spacing: CGFloat = OverlayInputViewController._spacing
    
    private let emotePanelHeight: CGFloat = 350
    
    private lazy var textFieldView: InputTextField = { .init() }()
    
    private lazy var emotePanelView: UIHostingView = { .init(rootView: EmotePanel()) }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.cornerRadius = _radius
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 7
        view.layer.shadowOpacity = 0.12
        return view
    }()
    
    private var _keyboardDisplay: Bool = false
    
    private var _keyboardEndFrame: CGRect = .zero
    
    init() {
        super.init(nibName: nil, bundle: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(notify:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @available(*, unavailable) required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = PassthroughView() |> {
            $0.shouldPassthroughPrediction = { [unowned self] in
                self.dismiss(animated: true, completion: nil)
                return true
            }
            return $0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        view.addSubview(contentView)
        contentView.addSubview(textFieldView)
        contentView.addSubview(emotePanelView)
        
        textFieldView.delegate = self
        textFieldView.showsKeyboardIcon = false
        textFieldView.emoteClickAction = { [unowned self] in
            self.textFieldView.textField |> {
                if $0.isEditing {
                    $0.resignFirstResponder()
                } else {
                    $0.becomeFirstResponder()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        textFieldView.textField.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let boundsWidth = view.bounds.width
        let width = _contentWidth()
        let textFieldHeight: CGFloat = _keyboardDisplay ? 44 : (_radius * 2)
        if _keyboardDisplay {
            emotePanelView.alpha = 0
            contentView.frame = .init(x: 0, y: _keyboardEndFrame.minY - textFieldHeight, width: boundsWidth, height: textFieldHeight)
            textFieldView.frame = .init(x: 0, y: 0, width: boundsWidth, height: textFieldHeight)
            contentView.cornerRadius = 0
        } else {
            let contentViewHeight: CGFloat = emotePanelHeight + textFieldHeight
            emotePanelView.alpha = 1
            contentView.frame = .init(x: spacing, y: view.bounds.height - contentViewHeight - spacing, width: width, height: emotePanelHeight + textFieldHeight)
            emotePanelView.frame = .init(x: 0, y: contentView.frame.height - emotePanelHeight, width: width, height: emotePanelHeight)
            textFieldView.frame = .init(x: 0, y: emotePanelView.frame.minY - textFieldHeight, width: width, height: textFieldHeight)
            contentView.cornerRadius = _radius
        }
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool { true }
    
    private func _contentWidth() -> CGFloat { view.bounds.width - spacing * 2 }
    
    // MARK: Actions
    
    @objc private func keyboardWillChangeFrame(notify: Notification) {
        guard let keyboardBeginFrame = (notify.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else { return }
        guard let keyboardEndFrame = (notify.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        _keyboardDisplay = (keyboardBeginFrame.minY > keyboardEndFrame.minY)
        _keyboardEndFrame = keyboardEndFrame
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: []) { [self] in
            view.setNeedsLayout()
            view.layoutIfNeeded()
        } completion: { _ in }
    }
    
}

extension OverlayInputViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textFieldView.showsKeyboardIcon = true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textFieldView.showsKeyboardIcon = false
    }
    
}
