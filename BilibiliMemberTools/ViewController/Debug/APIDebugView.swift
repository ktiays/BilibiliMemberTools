//
//  Created by ktiays on 2021/5/20.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import SwiftUI

// MARK: APIDebugView

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

// MARK: - PreviewView

fileprivate struct PreviewView: View {
    
    struct Cardd: View {
        
        var title: String
        var data: String
        var delta: Int = 0
        
        var body: some View {
            VStack {
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(.init(.secondaryLabel))
                Text(data)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.init(.systemBlue))
                    .padding(.vertical, 1)
                if (delta != 0) {
                    HStack {
                        if (delta > 0) {
                            Image(systemName: "arrowtriangle.up.fill")
                                .foregroundColor(Color(.systemRed))
                            Text(delta.description)
                                .bold()
                                .foregroundColor(Color(.systemRed))
                        } else {
                            Image(systemName: "arrowtriangle.down.fill")
                                .foregroundColor(Color(.systemGreen))
                            Text(abs(delta).description)
                                .bold()
                                .foregroundColor(Color(.systemGreen))
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical, 20)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
    
    var body: some View {
        VStack {
            Cardd(title: "Text", data: "123")
        }
    }
    
}

// MARK: - Preview

struct APIDebugView_Previews: PreviewProvider {
    static var previews: some View {
        APIDebugView()
        PreviewView()
    }
}
