//
//  Created by ktiays on 2021/5/22.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import SwiftUI
import Alamofire

struct WebImageView: View {
    
    var url: String
    
    @State private var image: UIImage?
    
    var body: some View {
        Image(uiImage: image ?? .init())
            .resizable()
            .onAppear {
                AF.request(url).responseData { response in
                    guard let imageData = response.value else { return }
                    image = UIImage(data: imageData)
                }
            }
    }
    
}

// MARK: - Preview

struct WebImageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Image:")
            WebImageView(url: "http://i1.hdslb.com/bfs/face/9df79b3dca426ca443baccb78cb1fb399bf91092.jpg")
                .frame(width: 100, height: 100)
        }
    }
}
