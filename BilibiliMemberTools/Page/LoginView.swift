//
//  Created by ktiays on 2021/5/19.
//  Copyright (c) 2021 ktiays. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    
    fileprivate var loginCompletionHandler: (() -> Void)
    
    @State private var username: String = ""
    @State private var smsCode: String = ""
    
    @State private var controller: Controller = Controller()
    
    @State private var isCaptchaed = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    TextField("电话号码", text: $username)
                }
                .padding(.bottom)
                HStack {
                    TextField("验证码", text: $smsCode)
                    Button(action: {
                        controller.telephone = username
                        controller.captchaDidVerifyBlock = {
                            isCaptchaed.toggle()
                        }
                        withAnimation(.spring()) {
                            isCaptchaed.toggle()
                        }
                    }, label: {
                        Text("发送")
                    })
                    .disabled(username.count != 11)
                }
                .padding(.bottom, 48)
                
                
                Button(action: {
                    controller.login(telephone: username, smsCode: smsCode) {
                        loginCompletionHandler()
                    }
                }, label: {
                    Text("登录")
                        .bold()
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 80)
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

fileprivate struct EditText: View {
    
    @Namespace private var textAnimation
    
    @Binding var text: String
    
    @State private var isEditing: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Text("Placeholder")
                Spacer()
            }
            .onTapGesture {
                withAnimation {
                    isEditing = true
                }
            }
            if isEditing {
                TextField("Placeholder", text: $text) { isEditing in
                    
                }
            }
        }
    }
    
}

// MARK: Evoke Login View Function

public class LoginAssistant {
    
    private static let shared = LoginAssistant()
    
    private var controller: UIViewController?
    
    private var hasLogged: Bool = false
    
    /// When the information returned by the API interface indicates that the user is not logged in,
    /// call this method to evoke the login page.
    public class func login() {
        if shared.hasLogged { return }
        
        let loginViewController = HostingController(wrappedView: LoginView {
            shared.controller?.dismiss(animated: true, completion: nil)
        })
        loginViewController.modalPresentationStyle = .fullScreen
        
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        var topViewController = scene.windows.filter { $0.isKeyWindow }.first?.rootViewController
        while topViewController?.presentedViewController != nil {
            topViewController = topViewController?.presentedViewController
        }
        shared.controller = topViewController
        topViewController?.present(loginViewController, animated: true, completion: nil)
        shared.hasLogged = true
    }
    
}

// MARK: - Preview

fileprivate struct EditTextPreviewView: View {
    
    @State private var text: String = .init()
    
    var body: some View {
        EditText(text: $text)
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView {}
        EditTextPreviewView()
    }
}
