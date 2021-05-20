//
//  Created by ktiays on 2021/5/18.
//  Copyright (c) 2021 ktiays. All rights reserved.
//

import UIKit
import SwiftUI

class ViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var apiListEntryButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.addTarget(self, action: #selector(login(_:)), for: .touchUpInside)
        infoButton.addTarget(self, action: #selector(info(_:)), for: .touchUpInside)
        apiListEntryButton.addTarget(self, action: #selector(apiDebug(_:)), for: .touchUpInside)
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
    
    @objc func info(_ sender: UIButton) {
        let info = APIManager.shared.info()
        print(info.info ?? "")
    }
    
    @objc func apiDebug(_ sender: UIButton) {
        let apiDebugViewControler = UIHostingController(rootView: APIDebugView())
        apiDebugViewControler.modalPresentationStyle = .fullScreen
        present(apiDebugViewControler, animated: true, completion: nil)
    }
    
}
