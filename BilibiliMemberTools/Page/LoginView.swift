//
//  Created by ktiays on 2021/5/19.
//  Copyright (c) 2021 ktiays. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    
    var loginCompletionHandler: (() -> Void)
    
    @State private var username: String = ""
    @State private var smsCode: String = ""
    
    @State private var controller: Controller = Controller()
    
    @State private var isCaptchaed = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    TextField("Username", text: $username)
                }
                .padding(.bottom)
                HStack {
                    TextField("SMS Code", text: $smsCode)
                    Button(action: {
                        controller.telephone = username
                        controller.captchaDidVerifyBlock = {
                            isCaptchaed.toggle()
                        }
                        withAnimation(.spring()) {
                            isCaptchaed.toggle()
                        }
                    }, label: {
                        Text("Send")
                    })
                    .disabled(username.count != 11)
                }
                .padding(.bottom, 48)
                
                Button(action: {
                    controller.login(telephone: username, smsCode: smsCode) {
                        loginCompletionHandler()
                    }
                }, label: {
                    Text("Login")
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                        .padding(.horizontal, 60)
                        .background(Color(.systemBlue))
                        .clipShape(Capsule())
                })
                .background(Color(.systemBlue).opacity(0.7))
                .clipShape(Capsule())
            }
            .padding()
            
            Controller.WebView(webView: controller.captchaView)
                .disabled(!isCaptchaed)
                .opacity(isCaptchaed ? 1 : 0)
        }
    }
    
}

func showLoginView() {
    class Wrapper {
        var controller: UIViewController?
    }
    
    let controllerWrapper = Wrapper()
    
    let loginViewController = HostingController(wrappedView: LoginView {
        controllerWrapper.controller?.dismiss(animated: true, completion: nil)
    })
    loginViewController.modalPresentationStyle = .fullScreen
    
    guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
    var topViewController = scene.windows.filter { $0.isKeyWindow }.first?.rootViewController
    while topViewController?.presentedViewController != nil {
        topViewController = topViewController?.presentedViewController
    }
    controllerWrapper.controller = topViewController
    topViewController?.present(loginViewController, animated: true, completion: nil)
}

// MARK: - Preview

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView {}
    }
}
