//
//  Created by ktiays on 2021/5/20.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import SwiftUI

fileprivate let apiList = [
    API(name: "Account Information", invokeHandler: {
        guard let info = APIManager.shared.info().info else { return AnyView(EmptyView()) }
        return AnyView(
            VStack {
                HStack {
                    Text("Birthday")
                        .bold()
                    Spacer()
                    Text(info.birthday.description)
                }
                .padding(.bottom)
                HStack {
                    Text("UID")
                        .bold()
                    Spacer()
                    Text(info.uid)
                }
                .padding(.bottom)
                HStack {
                    Text("Username")
                        .bold()
                    Spacer()
                    Text(info.username)
                }
                .padding(.bottom)
                HStack {
                    Text("Signature")
                        .bold()
                    Spacer()
                    Text(info.signature)
                }
                .padding(.bottom)
                HStack {
                    Text("Rank")
                        .bold()
                    Spacer()
                    Text(info.rank)
                }
                .padding(.bottom)
                HStack {
                    Text("User ID")
                        .bold()
                    Spacer()
                    Text(info.userID)
                }
            }
            .padding(.horizontal)
        )
    })
]

// MARK: - APIDebugView

struct APIDebugView: View {
    
    var body: some View {
        NavigationView {
            List {
                ForEach(apiList) { api in
                    NavigationLink(destination: APIDetailView(api: api)) {
                        Text(api.name)
                    }
                }
            }
            .navigationTitle("API List")
        }
    }
    
}

// MARK: - API

fileprivate struct API: Identifiable {
    
    var id: String = UUID().uuidString
    var name: String
    var invokeHandler: () -> AnyView
    
    func call(completionHandler: @escaping (AnyView) -> Void) {
        DispatchQueue.global().async {
            completionHandler(invokeHandler())
        }
    }
    
}

// MARK: - APIDetailView

fileprivate struct APIDetailView: View {
    
    var api: API
    
    @State private var resultView = AnyView(EmptyView())
    
    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    HStack {
                        Text("Result")
                            .bold()
                        Spacer()
                    }
                    Divider()
                }
                .padding()
                resultView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            api.call { view in
                resultView = view
            }
        }
    }
    
}

// MARK: - Preview

struct APIDebugView_Previews: PreviewProvider {
    static var previews: some View {
        APIDebugView()
//        APIDetailView()
    }
}
