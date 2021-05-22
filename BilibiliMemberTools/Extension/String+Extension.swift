//
//  Created by ktiays on 2021/5/18.
//  Copyright (c) 2021 ktiays. All rights reserved.
//

import Foundation
import CryptoKit


extension String {
    
    var md5: String? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }

        return Insecure.MD5.hash(data: data).prefix(Insecure.MD5.byteCount).map {
            String(format: "%02hhx", $0)
        }.joined()
    }
    
    func jsonDictionary() -> [String : AnyObject] {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: [.init(rawValue: 0)]) as? [String : AnyObject] ?? [:]
            } catch let error as NSError {
                print(error)
            }
        }
        return [:]
    }
    
    init(count: Int) {
        self.init()
        for _ in 0..<count {
            self.append(" ")
        }
    }
    
}
