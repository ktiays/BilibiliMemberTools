//
//  Created by ktiays on 2021/5/22.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import SwiftUI

struct StatusBarStyleKey: PreferenceKey {
    
    static var defaultValue: UIStatusBarStyle = .default
  
    static func reduce(value: inout UIStatusBarStyle, nextValue: () -> UIStatusBarStyle) {
        value = nextValue()
    }
    
}

extension View {
    func statusBar(style: UIStatusBarStyle) -> some View {
        preference(key: StatusBarStyleKey.self, value: style)
    }
}

class HostingController: UIHostingController<AnyView> {
    
    var statusBarStyle = UIStatusBarStyle.default {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    // UIKit seems to observe changes on this, perhaps with KVO?
    // In any case, I found changing `statusBarStyle` was sufficient
    // and no other method calls were needed to force the status bar to update
    override var preferredStatusBarStyle: UIStatusBarStyle { statusBarStyle }

    init<T: View>(wrappedView: T) {
        // This observer is necessary to break a dependency cycle - without it
        // onPreferenceChange would need to use self but self can't be used until
        // super.init is called, which can't be done until after onPreferenceChange is set up etc.
        let observer = Observer()

        let observedView = AnyView(wrappedView.onPreferenceChange(StatusBarStyleKey.self) { style in
            observer.value?.statusBarStyle = style
        })

        super.init(rootView: observedView)
        observer.value = self
    }

    private class Observer {
        weak var value: HostingController?
        init() {}
    }

    @available(*, unavailable) required init?(coder aDecoder: NSCoder) {
        // We aren't using storyboards, so this is unnecessary
        fatalError("Unavailable")
    }
}
