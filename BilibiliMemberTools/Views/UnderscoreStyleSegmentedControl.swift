//
//  Created by ktiays on 2021/8/6.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import UIKit

class UnderscoreStyleSegmentedControl: UISegmentedControl {
    
    private lazy var lineContainerView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.addSubview(lineView)
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.cornerRadius = lineHeight / 2
        return view
    }()
    
    private let lineHeight: CGFloat = 2
    
    private let UISegmentClass: AnyClass = NSClassFromString("UISegment")!

    private var lineContainerInitialFrame: CGRect = .zero
    private lazy var setupInitialLineContainer: Void = {
        lineContainerView.frame = lineContainerInitialFrame
    }()
    
    private var highlightedSegment: Int { value(forKey: "_highlightedSegment") as! Int }
    
    private var label: UILabel {
        let highlightedSegment = highlightedSegment >= 0 ? highlightedSegment : selectedSegmentIndex
        return (value(forKey: "_segments") as! [UIView])[highlightedSegment].subviews.first as! UILabel
    }

    @available(*, unavailable) required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(items: [Any]?) {
        super.init(items: items)
        self.layer.masksToBounds = false
        addSubview(lineContainerView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        for subview in subviews {
            if !subview.isKind(of: UISegmentClass) {
                if let imageView = subview as? UIImageView {
                    if imageView.layer.sublayers == nil {
                        if highlightedSegment < 0 {
                            lineContainerInitialFrame = imageView.frame
                            _ = setupInitialLineContainer
                        }
                        // FIXME: Animation Error
                        let labelFrame = lineContainerView.convert(label.convert(label.bounds, to: nil), from: nil)
                        withMainQueue {
                            UIView.animate(withDuration: 0.4, delay: 0, options: []) { [self] in
                                lineView.frame = .init(x: labelFrame.minX - (imageView.layer.position.x - imageView.layer.bounds.width / 2 - lineContainerView.frame.minX), y: labelFrame.maxY + 5, width: labelFrame.width, height: lineHeight)
                            } completion: { _ in }
                        }
                        
                        let positionAnimation = CASpringAnimation(keyPath: "position")
                        positionAnimation.toValue = imageView.layer.position
                        positionAnimation.damping = 400;
                        positionAnimation.stiffness = 400;
                        positionAnimation.mass = 1;
                        positionAnimation.initialVelocity = 0;
                        positionAnimation.duration = positionAnimation.settlingDuration
                        let transformAnimation = CASpringAnimation(keyPath: "transform")
                        transformAnimation.toValue = imageView.layer.transform
                        transformAnimation.damping = 400;
                        transformAnimation.stiffness = 400;
                        transformAnimation.mass = 1;
                        transformAnimation.initialVelocity = 0;
                        transformAnimation.duration = transformAnimation.settlingDuration
                        let lineAnimation = CAAnimationGroup()
                        lineAnimation.animations = [positionAnimation, transformAnimation]
                        lineAnimation.duration = max(positionAnimation.settlingDuration, transformAnimation.settlingDuration)
                        lineAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                        lineAnimation.fillMode = .both
                        lineAnimation.isRemovedOnCompletion = false
                        lineContainerView.layer.add(lineAnimation, forKey: nil)
                        
                        imageView.isHidden = true
                    } else {
                        imageView.removeFromSuperview()
                    }
                }
            }
        }
        bringSubviewToFront(lineContainerView)
    }
    
}
