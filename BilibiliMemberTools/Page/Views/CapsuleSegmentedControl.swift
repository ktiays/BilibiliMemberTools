//
//  Created by ktiays on 2021/5/26.
//  Copyright (c) 2021 ktiays. All rights reserved.
//

import UIKit

// MARK: Operator overloading

func + (lhs: CGSize, rhs: CGSize) -> CGSize {
    .init(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
}

func * (lhs: CGFloat, rhs: Int) -> CGFloat {
    lhs * CGFloat(rhs)
}

func * (lhs: CGSize, rhs: Int) -> CGSize {
    .init(width: lhs.width * CGFloat(rhs), height: lhs.height * CGFloat(rhs))
}

// MARK: - SegmentedControl

public class CapsuleSegmentedControl: UIControl {
    
    public var selectedSegmentIndex: Int = 0 {
        didSet {
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 30, initialSpringVelocity: 0, options: .allowUserInteraction) { [self] in
                let selectedRect = rectOfSegment(at: selectedSegmentIndex)
                selectedBackgroundView.frame = selectedRect
                shapeMaskView.frame = selectedRect
                scrollView.scrollRectToVisible(selectedRect, animated: true)
            } completion: { _ in }
        }
    }
    
    public var selectedSegmentColor: UIColor
    
    private var items: [String]
    
    private let defaultSpacingOfSegments: CGFloat = 12
    
    private lazy var shapeMaskContainerView: UIView = {
        let containerView = UIView()
        containerView.isUserInteractionEnabled = false
        return containerView
    }()
    
    private lazy var shapeMaskView: UIView = {
        let maskView = UIView()
        maskView.backgroundColor = .white
        maskView.isUserInteractionEnabled = false
        return maskView
    }()
    
    private lazy var selectedBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = selectedSegmentColor
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var textMaskView: UIView = {
        let maskView = UIView()
        maskView.isUserInteractionEnabled = false
        return maskView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = false
        scrollView.contentInset = UIEdgeInsets(top: 0, left: defaultSpacingOfSegments, bottom: 0, right: defaultSpacingOfSegments)
        return scrollView
    }()
    
    private var segmentSizeMap: [Int : CGSize] = [:]
    
    required init(items: [String], selectedSegmentColor color: UIColor = .systemBlue) {
        self.items = items
        self.selectedSegmentColor = color
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate typealias SegmentedButton = UIButton
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        addSubview(scrollView)
        
        scrollView.addSubview(selectedBackgroundView)
        shapeMaskContainerView.addSubview(shapeMaskView)
        
        var segmentsSize: CGSize = .zero
        
        for (index, item) in items.enumerated() {
            var isMask: Bool = false
            
            var button: UIButton = .init()
            var buttonSize: CGSize = .zero
            for _ in 0..<2 {
                button = SegmentedButton(type: .system)
                button.tag = index
                button.addTarget(self, action: #selector(segmentDidSelected(_:)), for: .touchUpInside)
                
                let buttonColor = UIColor(lightColor: #colorLiteral(red: 0.368627451, green: 0.3843137255, blue: 0.4470588235, alpha: 1), darkColor: #colorLiteral(red: 0.5098039216, green: 0.5098039216, blue: 0.5333333333, alpha: 1))
                button.setTitle(item, for: .normal)
                button.setTitleColor(buttonColor, for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
                
                let titleSize = button.titleLabel?.textRect(forBounds: .infinite, limitedToNumberOfLines: 1).size ?? .zero
                buttonSize = .init(width: titleSize.width, height: 32) + .init(width: 32, height: 0)
                segmentSizeMap[index] = buttonSize
                
                button.frame = .init(origin: .init(x: segmentsSize.width + defaultSpacingOfSegments * index, y: 0), size: buttonSize)
                if !isMask {
                    scrollView.addSubview(button)
                    isMask.toggle()
                } else {
                    button.isUserInteractionEnabled = false
                    textMaskView.addSubview(button)
                }
            }
            
            segmentsSize = segmentsSize + buttonSize
            
            // Update selected segment background view.
            if index == selectedSegmentIndex {
                scrollView.frame = .init(origin: .zero, size: .init(width: bounds.width, height: buttonSize.height))
                
                selectedBackgroundView.frame = .init(origin: .init(x: button.frame.origin.x, y: 0), size: buttonSize)
                selectedBackgroundView.layer.cornerRadius = min(buttonSize.width, buttonSize.height) / 2
                
                shapeMaskView.frame = .init(origin: .init(x: button.frame.origin.x, y: 0), size: buttonSize)
                shapeMaskView.layer.cornerRadius = min(buttonSize.width, buttonSize.height) / 2
            }
        }
        
        scrollView.addSubview(textMaskView)
        scrollView.addSubview(shapeMaskContainerView)
        shapeMaskContainerView.mask = textMaskView
        
        scrollView.contentSize = segmentsSize + .init(width: defaultSpacingOfSegments, height: 0) * items.count
        shapeMaskContainerView.frame = .init(origin: .zero, size: scrollView.contentSize)
    }
    
    private func rectOfSegment(at index: Int) -> CGRect {
        if !(0..<items.count).contains(index) { return .zero }
        
        var x: CGFloat = .zero
        for index in 0..<index {
            x += (segmentSizeMap[index] ?? .zero).width + defaultSpacingOfSegments
        }
        
        return .init(origin: .init(x: x, y: 0), size: segmentSizeMap[index] ?? .zero)
    }
    
    @objc private func segmentDidSelected(_ sender: SegmentedButton) {
        selectedSegmentIndex = sender.tag
    }
    
}
