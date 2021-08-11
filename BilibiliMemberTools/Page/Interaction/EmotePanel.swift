//
//  Created by ktiays on 2021/8/11.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import SwiftUI

struct EmotePanel: View {
    
    @State private var emote: EmotePackage? = nil
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                .init(.flexible()),
                .init(.flexible()),
                .init(.flexible()),
                .init(.flexible()),
                .init(.flexible()),
                .init(.flexible())
            ]) {
                ForEach(emote?.packages ?? []) { package in
                    Button(action: {
                        
                    }, label: {
                        AsyncImage(url: URL(string: package.packageImageURL)) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                    })
                    .frame(width: 35, height: 35)
                }
            }
        }
        .task {
            do {
                emote = try await APIManager.shared.emotes().data
            } catch {}
        }
    }
    
}

fileprivate struct EmotePackageControl: View {
    
    @Binding var selection: Int
    
    var body: some View {
        ScrollView {
            HStack {
                
            }
        }
    }
    
}

// MARK: - Preview

struct EmotePanel_Previews: PreviewProvider {
    static var previews: some View {
        EmotePanel()
    }
}
