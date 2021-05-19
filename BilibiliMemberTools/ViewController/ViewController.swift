//
//  Created by ktiays on 2021/5/18.
//  Copyright (c) 2021 ktiays. All rights reserved.
//

import UIKit
import SwiftUI

class ViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    @objc func login(_ sender: UIButton) {
        class ViewControllerWrapper {
            var viewController: UIViewController?
        }
        let wrapper = ViewControllerWrapper()
        
        let loginViewController = UIHostingController(rootView: LoginView {
            wrapper.viewController?.dismiss(animated: true, completion: nil)
        })
        wrapper.viewController = loginViewController
        
        loginViewController.modalPresentationStyle = .fullScreen
        present(loginViewController, animated: true, completion: nil)
    }
    
}
